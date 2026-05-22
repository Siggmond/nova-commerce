import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:nova_commerce/features/offers/data/datasources/firestore_offers_datasource.dart';
import 'package:nova_commerce/features/offers/data/repositories/fake_offers_repository.dart';
import 'package:nova_commerce/features/offers/domain/entities/offer.dart';
import 'package:nova_commerce/features/offers/domain/repositories/offers_repository.dart';

class FirestoreOffersRepository implements OffersRepository {
  FirestoreOffersRepository(this._ds);

  final FirestoreOffersDataSource _ds;
  final FakeOffersRepository _fallbackRepo = FakeOffersRepository();

  static const Duration _transientFallbackWindow = Duration(seconds: 90);

  final Map<_OffersPageCacheKey, OffersPage> _pageCache =
      <_OffersPageCacheKey, OffersPage>{};
  final Map<String, Offer?> _offerByIdCache = <String, Offer?>{};

  DateTime? _transientFallbackUntil;

  int _sessionFirestorePageReads = 0;
  int _sessionFirestoreByIdReads = 0;
  int _sessionCacheHits = 0;
  int _sessionCacheMisses = 0;

  @override
  Future<OffersPage> getOffers({
    required OffersQuery query,
    int limit = 20,
    Object? startAfter,
  }) async {
    final cacheKey = _OffersPageCacheKey.from(
      query: query,
      limit: limit,
      startAfter: startAfter,
    );
    final cachedPage = _pageCache[cacheKey];
    if (cachedPage != null) {
      _sessionCacheHits += 1;
      _logReadStats(action: 'page_cache_hit', query: query, cursor: startAfter);
      return cachedPage;
    }

    _sessionCacheMisses += 1;
    _logReadStats(action: 'page_cache_miss', query: query, cursor: startAfter);

    if (_isTransientFallbackActive) {
      final fallbackPage = await _fallbackRepo.getOffers(
        query: query,
        limit: limit,
        startAfter: _fallbackCursor(startAfter),
      );
      _cachePage(cacheKey, fallbackPage);
      _logReadStats(
        action: 'page_fallback_repo',
        query: query,
        cursor: startAfter,
      );
      return fallbackPage;
    }

    final startAfterDoc = startAfter is DocumentSnapshot<Map<String, dynamic>>
        ? startAfter
        : null;

    QuerySnapshot<Map<String, dynamic>> snap;
    try {
      snap = await _fetchOffersFromFirestore(
        query: query,
        limit: limit,
        startAfterDoc: startAfterDoc,
        strategy: 'primary',
      );
      _clearTransientFallbackWindow();
    } on FirebaseException catch (e) {
      if (_isTransientNetworkFailure(e)) {
        _markTransientFallback(
          e,
          context: 'Failed to fetch offers from Firestore.',
        );
        final fallbackPage = await _fallbackRepo.getOffers(
          query: query,
          limit: limit,
          startAfter: _fallbackCursor(startAfter),
        );
        _cachePage(cacheKey, fallbackPage);
        _logReadStats(
          action: 'page_fallback_repo_after_network_error',
          query: query,
          cursor: startAfter,
        );
        return fallbackPage;
      }

      final fallbackQuery = query.copyWith(sort: OfferSort.newest);
      try {
        snap = await _fetchOffersFromFirestore(
          query: fallbackQuery,
          limit: limit,
          startAfterDoc: startAfterDoc,
          strategy: 'fallback_sort_newest',
        );
        _clearTransientFallbackWindow();
      } on FirebaseException catch (fallbackError) {
        if (_isTransientNetworkFailure(fallbackError)) {
          _markTransientFallback(
            fallbackError,
            context: 'Failed to fetch offers from Firestore (fallback query).',
          );
          final fallbackPage = await _fallbackRepo.getOffers(
            query: query,
            limit: limit,
            startAfter: _fallbackCursor(startAfter),
          );
          _cachePage(cacheKey, fallbackPage);
          _logReadStats(
            action: 'page_fallback_repo_after_fallback_network_error',
            query: query,
            cursor: startAfter,
          );
          return fallbackPage;
        }
        rethrow;
      }
    } catch (_) {
      final fallbackQuery = query.copyWith(sort: OfferSort.newest);
      snap = await _fetchOffersFromFirestore(
        query: fallbackQuery,
        limit: limit,
        startAfterDoc: startAfterDoc,
        strategy: 'fallback_after_unknown',
      );
      _clearTransientFallbackWindow();
    }

    final items = snap.docs.map(_fromDoc).toList(growable: false);
    final cursor = snap.docs.isEmpty ? null : snap.docs.last;
    final page = OffersPage(items: items, cursor: cursor);
    _cachePage(cacheKey, page);
    return page;
  }

  @override
  Future<Offer?> getOfferById(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return null;

    if (_offerByIdCache.containsKey(normalizedId)) {
      _sessionCacheHits += 1;
      _logReadStats(action: 'offer_cache_hit', offerId: normalizedId);
      return _offerByIdCache[normalizedId];
    }

    _sessionCacheMisses += 1;
    _logReadStats(action: 'offer_cache_miss', offerId: normalizedId);

    if (_isTransientFallbackActive) {
      final fallbackOffer = await _fallbackRepo.getOfferById(normalizedId);
      _offerByIdCache[normalizedId] = fallbackOffer;
      _logReadStats(action: 'offer_fallback_repo', offerId: normalizedId);
      return fallbackOffer;
    }

    try {
      _sessionFirestoreByIdReads += 1;
      _logReadStats(action: 'offer_firestore_read', offerId: normalizedId);
      final doc = await _ds.fetchById(normalizedId);
      if (!doc.exists) {
        _offerByIdCache[normalizedId] = null;
        return null;
      }

      final data = doc.data();
      if (data == null) {
        _offerByIdCache[normalizedId] = null;
        return null;
      }

      _clearTransientFallbackWindow();
      final offer = _fromMap(id: doc.id, data: data);
      _offerByIdCache[normalizedId] = offer;
      return offer;
    } on FirebaseException catch (e) {
      if (_isTransientNetworkFailure(e)) {
        _markTransientFallback(
          e,
          context: 'Failed to fetch offer by id from Firestore.',
        );
        final fallbackOffer = await _fallbackRepo.getOfferById(normalizedId);
        _offerByIdCache[normalizedId] = fallbackOffer;
        _logReadStats(
          action: 'offer_fallback_repo_after_network_error',
          offerId: normalizedId,
        );
        return fallbackOffer;
      }
      rethrow;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _fetchOffersFromFirestore({
    required OffersQuery query,
    required int limit,
    required DocumentSnapshot<Map<String, dynamic>>? startAfterDoc,
    required String strategy,
  }) {
    _sessionFirestorePageReads += 1;
    _logReadStats(
      action: 'page_firestore_read:$strategy',
      query: query,
      cursor: startAfterDoc,
    );
    return _ds.fetchOffers(
      query: query,
      limit: limit,
      startAfterDoc: startAfterDoc,
    );
  }

  void _cachePage(_OffersPageCacheKey key, OffersPage page) {
    _pageCache[key] = page;
    for (final offer in page.items) {
      _offerByIdCache[offer.id] = offer;
    }
  }

  Offer _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return _fromMap(id: doc.id, data: data);
  }

  Offer _fromMap({required String id, required Map<String, dynamic> data}) {
    final title = (data['title'] as String?) ?? 'Offer';
    final description = (data['description'] as String?) ?? '';
    final brandName = (data['brandName'] as String?) ?? 'Brand';
    final imageUrl = (data['imageUrl'] as String?) ?? '';

    final discountTypeRaw = (data['discountType'] as String?) ?? 'other';
    final discountType =
        OfferDiscountType.values
            .where((e) => e.name == discountTypeRaw)
            .cast<OfferDiscountType?>()
            .firstWhere(
              (e) => e != null,
              orElse: () => OfferDiscountType.other,
            ) ??
        OfferDiscountType.other;

    final discountValue = (data['discountValue'] as num?)?.toDouble() ?? 0;

    final startAt = _parseDateTime(data['startAt']) ?? DateTime.now();
    final endAt = _parseDateTime(data['endAt']) ?? DateTime.now();

    final tags = (data['tags'] is List)
        ? (data['tags'] as List)
              .whereType<String>()
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(growable: false)
        : const <String>[];

    final channelsRaw = (data['channels'] is List)
        ? (data['channels'] as List)
              .whereType<String>()
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(growable: false)
        : const <String>[];

    final channels = <OfferChannel>[];
    for (final c in channelsRaw) {
      final mapped = OfferChannel.values
          .where((e) => e.name == c)
          .cast<OfferChannel?>()
          .firstWhere((e) => e != null, orElse: () => null);
      if (mapped != null) channels.add(mapped);
    }

    final isFeatured = (data['isFeatured'] as bool?) ?? false;
    final promoCode = (data['promoCode'] as String?)?.trim();
    final termsUrl = (data['termsUrl'] as String?)?.trim();

    return Offer(
      id: id,
      title: title,
      description: description,
      brandName: brandName,
      imageUrl: imageUrl,
      discountType: discountType,
      discountValue: discountValue,
      startAt: startAt,
      endAt: endAt,
      tags: tags,
      channels: channels,
      promoCode: (promoCode == null || promoCode.isEmpty) ? null : promoCode,
      termsUrl: (termsUrl == null || termsUrl.isEmpty) ? null : termsUrl,
      isFeatured: isFeatured,
    );
  }

  DateTime? _parseDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  bool _isTransientNetworkFailure(FirebaseException e) {
    final code = e.code.trim().toLowerCase();
    if (code == 'unavailable' ||
        code == 'network-request-failed' ||
        code == 'deadline-exceeded' ||
        code == 'cancelled' ||
        code == 'unknown') {
      return true;
    }

    final message = (e.message ?? '').toLowerCase();
    return message.contains('failed to resolve name') ||
        message.contains('host lookup') ||
        message.contains('network is unreachable') ||
        message.contains('socket') ||
        message.contains('broken pipe') ||
        message.contains('timed out');
  }

  bool get _isTransientFallbackActive {
    final until = _transientFallbackUntil;
    if (until == null) return false;
    if (DateTime.now().isAfter(until)) {
      _transientFallbackUntil = null;
      return false;
    }
    return true;
  }

  Object? _fallbackCursor(Object? startAfter) {
    return startAfter is int ? startAfter : null;
  }

  String _querySummary(OffersQuery query) {
    final tags = _normalizeTags(query.tags);
    final tagsSummary = tags.isEmpty ? '-' : tags.join(',');
    return 'sort=${query.sort.name};channel=${query.channel?.name ?? '-'};'
        'featured=${query.onlyFeatured ?? false};tags=$tagsSummary;'
        'search=${_normalizeSearch(query.searchText)}';
  }

  void _clearTransientFallbackWindow() {
    _transientFallbackUntil = null;
  }

  void _markTransientFallback(
    FirebaseException error, {
    required String context,
  }) {
    _transientFallbackUntil = DateTime.now().add(_transientFallbackWindow);
    developer.log(
      '$context Using local seeded offers fallback for ${_transientFallbackWindow.inSeconds}s.',
      name: 'FirestoreOffersRepository',
      error: error,
    );
  }

  void _logReadStats({
    required String action,
    OffersQuery? query,
    Object? cursor,
    String? offerId,
  }) {
    developer.log(
      '[OffersReadStats] action=$action '
      'firestorePageReads=$_sessionFirestorePageReads '
      'firestoreByIdReads=$_sessionFirestoreByIdReads '
      'cacheHits=$_sessionCacheHits '
      'cacheMisses=$_sessionCacheMisses '
      'query=${query == null ? '-' : _querySummary(query)} '
      'cursor=${_cursorKey(cursor)} '
      'offerId=${offerId ?? '-'}',
      name: 'FirestoreOffersRepository',
    );
  }
}

class _OffersPageCacheKey {
  const _OffersPageCacheKey({
    required this.sort,
    required this.channel,
    required this.onlyFeatured,
    required this.searchText,
    required this.tags,
    required this.limit,
    required this.cursorKey,
  });

  factory _OffersPageCacheKey.from({
    required OffersQuery query,
    required int limit,
    required Object? startAfter,
  }) {
    return _OffersPageCacheKey(
      sort: query.sort,
      channel: query.channel,
      onlyFeatured: query.onlyFeatured ?? false,
      searchText: _normalizeSearch(query.searchText),
      tags: _normalizeTags(query.tags),
      limit: limit,
      cursorKey: _cursorKey(startAfter),
    );
  }

  final OfferSort sort;
  final OfferChannel? channel;
  final bool onlyFeatured;
  final String searchText;
  final List<String> tags;
  final int limit;
  final String cursorKey;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _OffersPageCacheKey) return false;
    return other.sort == sort &&
        other.channel == channel &&
        other.onlyFeatured == onlyFeatured &&
        other.searchText == searchText &&
        _listEquals(other.tags, tags) &&
        other.limit == limit &&
        other.cursorKey == cursorKey;
  }

  @override
  int get hashCode {
    return Object.hash(
      sort,
      channel,
      onlyFeatured,
      searchText,
      Object.hashAll(tags),
      limit,
      cursorKey,
    );
  }
}

String _normalizeSearch(String? value) {
  return value?.trim().toLowerCase() ?? '';
}

List<String> _normalizeTags(List<String>? tags) {
  if (tags == null || tags.isEmpty) return const <String>[];
  final normalized =
      tags
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList(growable: false)
        ..sort();
  return normalized;
}

String _cursorKey(Object? cursor) {
  if (cursor == null) return 'root';
  if (cursor is int) return 'int:$cursor';
  if (cursor is DocumentSnapshot<Map<String, dynamic>>) {
    return 'doc:${cursor.id}';
  }
  return 'obj:${cursor.runtimeType}:${cursor.hashCode}';
}

bool _listEquals(List<String> a, List<String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
