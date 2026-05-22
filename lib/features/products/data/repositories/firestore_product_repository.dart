import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:nova_commerce/core/domain/entities/product.dart';
import 'package:nova_commerce/core/domain/repositories/product_repository.dart';
import 'package:nova_commerce/features/products/data/datasources/firestore_product_datasource.dart';
import 'package:nova_commerce/features/products/data/repositories/fake_product_repository.dart';
import 'package:nova_commerce/features/products/domain/usecases/parse_products_payload_use_case.dart';

class FirestoreProductRepository implements ProductRepository {
  FirestoreProductRepository(
    this._ds, {
    ParseProductsPayloadUseCase? parseProductsPayloadUseCase,
  }) : _parseProductsPayloadUseCase =
           parseProductsPayloadUseCase ?? const ParseProductsPayloadUseCase();

  final FirestoreProductDataSource _ds;
  final ParseProductsPayloadUseCase _parseProductsPayloadUseCase;
  final FakeProductRepository _fallbackRepo = FakeProductRepository();
  static const Duration _transientFallbackWindow = Duration(seconds: 90);
  DateTime? _transientFallbackUntil;

  @override
  Future<FeaturedProductsPage> getFeaturedProducts({
    int limit = 20,
    Object? startAfter,
  }) async {
    final startAfterDoc = startAfter is DocumentSnapshot<Map<String, dynamic>>
        ? startAfter
        : null;
    if (_isTransientFallbackActive) {
      return _getFallbackFeaturedPage(
        limit: limit,
        startAfter: startAfter,
        startAfterDoc: startAfterDoc,
      );
    }

    try {
      final snap = await _ds.fetchFeatured(
        limit: limit,
        startAfterDoc: startAfterDoc,
        orderByCreatedAt: true,
      );
      final rawPayload = _encodeDocsPayload(snap.docs);
      final items = await _parseProductsPayloadUseCase(rawPayload);
      final cursor = snap.docs.isEmpty ? null : snap.docs.last;
      _clearTransientFallbackWindow();
      return FeaturedProductsPage(items: items, cursor: cursor);
    } on FirebaseException catch (e) {
      if (_shouldUseLocalFallback(e)) {
        _prepareFallback(
          e,
          context: 'Failed to fetch featured products from Firestore.',
        );
        return _getFallbackFeaturedPage(
          limit: limit,
          startAfter: startAfter,
          startAfterDoc: startAfterDoc,
        );
      }
      try {
        final snap = await _ds.fetchFeatured(
          limit: limit,
          startAfterDoc: startAfterDoc,
          orderByCreatedAt: false,
        );
        final rawPayload = _encodeDocsPayload(snap.docs);
        final items = await _parseProductsPayloadUseCase(rawPayload);
        final cursor = snap.docs.isEmpty ? null : snap.docs.last;
        _clearTransientFallbackWindow();
        return FeaturedProductsPage(items: items, cursor: cursor);
      } on FirebaseException catch (fallbackError) {
        if (_shouldUseLocalFallback(fallbackError)) {
          _prepareFallback(
            fallbackError,
            context:
                'Failed to fetch featured products from Firestore (fallback query).',
          );
          return _getFallbackFeaturedPage(
            limit: limit,
            startAfter: startAfter,
            startAfterDoc: startAfterDoc,
          );
        }
        rethrow;
      }
    } catch (_) {
      try {
        final snap = await _ds.fetchFeatured(
          limit: limit,
          startAfterDoc: startAfterDoc,
          orderByCreatedAt: false,
        );
        final rawPayload = _encodeDocsPayload(snap.docs);
        final items = await _parseProductsPayloadUseCase(rawPayload);
        final cursor = snap.docs.isEmpty ? null : snap.docs.last;
        _clearTransientFallbackWindow();
        return FeaturedProductsPage(items: items, cursor: cursor);
      } on FirebaseException catch (fallbackError) {
        if (_shouldUseLocalFallback(fallbackError)) {
          _prepareFallback(
            fallbackError,
            context:
                'Failed to fetch featured products from Firestore (fallback query after unknown error).',
          );
          return _getFallbackFeaturedPage(
            limit: limit,
            startAfter: startAfter,
            startAfterDoc: startAfterDoc,
          );
        }
        rethrow;
      }
    }
  }

  @override
  Future<Product?> getProductById(String id) async {
    if (_isTransientFallbackActive) {
      return _fallbackRepo.getProductById(id);
    }
    try {
      final doc = await _ds.fetchById(id);
      if (!doc.exists) return null;
      final data = doc.data();
      if (data == null) return null;
      final rawPayload = _encodeItemsPayload(<Map<String, Object?>>[
        _serializeProductPayload(id: doc.id, data: data),
      ]);
      final mapped = await _parseProductsPayloadUseCase(rawPayload);
      _clearTransientFallbackWindow();
      return mapped.isEmpty ? null : mapped.first;
    } on FirebaseException catch (e) {
      if (_shouldUseLocalFallback(e)) {
        _prepareFallback(
          e,
          context: 'Failed to fetch product by id from Firestore.',
        );
        return _fallbackRepo.getProductById(id);
      }
      rethrow;
    }
  }

  @override
  Future<List<Product>> getProductsByIds(Iterable<String> ids) async {
    final unique = ids.where((e) => e.trim().isNotEmpty).toSet().toList();
    if (unique.isEmpty) return const [];
    if (_isTransientFallbackActive) {
      return _fallbackRepo.getProductsByIds(unique);
    }

    const chunkSize = 10;
    final results = <Product>[];
    try {
      for (var i = 0; i < unique.length; i += chunkSize) {
        final chunk = unique.sublist(
          i,
          (i + chunkSize).clamp(0, unique.length),
        );
        final snap = await _ds.fetchByIds(chunk);
        final rawPayload = _encodeDocsPayload(snap.docs);
        final mapped = await _parseProductsPayloadUseCase(rawPayload);
        results.addAll(mapped);
      }
      _clearTransientFallbackWindow();
    } on FirebaseException catch (e) {
      if (_shouldUseLocalFallback(e)) {
        _prepareFallback(
          e,
          context: 'Failed to fetch products by ids from Firestore.',
        );
        return _fallbackRepo.getProductsByIds(unique);
      }
      rethrow;
    }
    return results;
  }

  String _encodeDocsPayload(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final items = <Map<String, Object?>>[];
    for (final doc in docs) {
      items.add(_serializeProductPayload(id: doc.id, data: doc.data()));
    }
    return _encodeItemsPayload(items);
  }

  String _encodeItemsPayload(List<Map<String, Object?>> items) {
    return jsonEncode(<String, Object?>{'items': items});
  }

  Map<String, Object?> _serializeProductPayload({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return <String, Object?>{
      'id': id,
      'data': <String, Object?>{
        'title': data['title'] is String ? data['title'] as String : null,
        'brand': data['brand'] is String ? data['brand'] as String : null,
        'price': _toJsonNumber(data['price']),
        'currency': data['currency'] is String
            ? data['currency'] as String
            : null,
        'description': data['description'] is String
            ? data['description'] as String
            : null,
        'imageUrls': _serializeImageUrls(data['imageUrls']),
        'variants': _serializeVariants(data['variants']),
      },
    };
  }

  List<String> _serializeImageUrls(Object? raw) {
    if (raw is! List) return const <String>[];
    return raw
        .whereType<String>()
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
  }

  List<Map<String, Object?>> _serializeVariants(Object? raw) {
    if (raw is! List) return const <Map<String, Object?>>[];
    final variants = <Map<String, Object?>>[];
    for (final entry in raw) {
      final mapped = _serializeVariant(entry);
      if (mapped != null) {
        variants.add(mapped);
      }
    }
    return variants;
  }

  Map<String, Object?>? _serializeVariant(Object? raw) {
    if (raw is! Map) return null;
    Object? color;
    Object? size;
    Object? stock;
    for (final entry in raw.entries) {
      final key = entry.key;
      if (key is! String) continue;
      switch (key) {
        case 'color':
          color = entry.value is String ? (entry.value as String) : null;
          break;
        case 'size':
          size = entry.value is String ? (entry.value as String) : null;
          break;
        case 'stock':
          stock = _toJsonNumber(entry.value);
          break;
      }
    }
    return <String, Object?>{'color': color, 'size': size, 'stock': stock};
  }

  num? _toJsonNumber(Object? value) {
    if (value is int) return value;
    if (value is double) return value;
    if (value is num) return value;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      final asInt = int.tryParse(trimmed);
      if (asInt != null) return asInt;
      return double.tryParse(trimmed);
    }
    return null;
  }

  bool _isPermissionDenied(FirebaseException e) {
    return e.code.trim().toLowerCase() == 'permission-denied';
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

  bool _shouldUseLocalFallback(FirebaseException e) {
    return _isPermissionDenied(e) || _isTransientNetworkFailure(e);
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

  void _clearTransientFallbackWindow() {
    _transientFallbackUntil = null;
  }

  void _prepareFallback(FirebaseException error, {required String context}) {
    if (_isTransientNetworkFailure(error)) {
      _transientFallbackUntil = DateTime.now().add(_transientFallbackWindow);
      _logLocalFallback(
        error,
        context:
            '$context Transient connectivity issue detected; short-circuiting remote reads for ${_transientFallbackWindow.inSeconds}s.',
      );
      return;
    }

    _logLocalFallback(error, context: context);
  }

  Future<FeaturedProductsPage> _getFallbackFeaturedPage({
    required int limit,
    required Object? startAfter,
    required DocumentSnapshot<Map<String, dynamic>>? startAfterDoc,
  }) {
    final startAfterId = switch (startAfter) {
      final String s when s.trim().isNotEmpty => s,
      _ => startAfterDoc?.id,
    };
    return _fallbackRepo.getFeaturedProducts(
      limit: limit,
      startAfter: startAfterId,
    );
  }

  void _logLocalFallback(FirebaseException error, {required String context}) {
    developer.log(
      '$context Using local seeded products fallback for this request.',
      name: 'FirestoreProductRepository',
      error: error,
    );
  }
}
