import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/offer.dart';
import '../../domain/repositories/offers_repository.dart';
import '../datasources/firestore_offers_datasource.dart';

class FirestoreOffersRepository implements OffersRepository {
  FirestoreOffersRepository(this._ds);

  final FirestoreOffersDataSource _ds;

  @override
  Future<OffersPage> getOffers({
    required OffersQuery query,
    int limit = 20,
    Object? startAfter,
  }) async {
    final startAfterDoc = startAfter is DocumentSnapshot<Map<String, dynamic>>
        ? startAfter
        : null;

    QuerySnapshot<Map<String, dynamic>> snap;
    try {
      snap = await _ds.fetchOffers(
        query: query,
        limit: limit,
        startAfterDoc: startAfterDoc,
      );
    } catch (_) {
      final fallback = query.copyWith(sort: OfferSort.newest);
      snap = await _ds.fetchOffers(
        query: fallback,
        limit: limit,
        startAfterDoc: startAfterDoc,
      );
    }

    final items = snap.docs.map(_fromDoc).toList(growable: false);
    final cursor = snap.docs.isEmpty ? null : snap.docs.last;
    return OffersPage(items: items, cursor: cursor);
  }

  @override
  Future<Offer?> getOfferById(String id) async {
    final doc = await _ds.fetchById(id);
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    return _fromMap(id: doc.id, data: data);
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
}
