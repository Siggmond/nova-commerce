import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/variant.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/firestore_product_datasource.dart';

class FirestoreProductRepository implements ProductRepository {
  FirestoreProductRepository(this._ds);

  final FirestoreProductDataSource _ds;

  @override
  Future<FeaturedProductsPage> getFeaturedProducts({
    int limit = 20,
    Object? startAfter,
  }) async {
    final startAfterDoc = startAfter is DocumentSnapshot<Map<String, dynamic>>
        ? startAfter
        : null;

    try {
      final snap = await _ds.fetchFeatured(
        limit: limit,
        startAfterDoc: startAfterDoc,
        orderByCreatedAt: true,
      );
      final items = snap.docs.map(_fromDoc).toList(growable: false);
      final cursor = snap.docs.isEmpty ? null : snap.docs.last;
      return FeaturedProductsPage(items: items, cursor: cursor);
    } catch (_) {
      final snap = await _ds.fetchFeatured(
        limit: limit,
        startAfterDoc: startAfterDoc,
        orderByCreatedAt: false,
      );
      final items = snap.docs.map(_fromDoc).toList(growable: false);
      final cursor = snap.docs.isEmpty ? null : snap.docs.last;
      return FeaturedProductsPage(items: items, cursor: cursor);
    }
  }

  @override
  Future<Product?> getProductById(String id) async {
    final doc = await _ds.fetchById(id);
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    return _fromMap(id: doc.id, data: data);
  }

  @override
  Future<List<Product>> getProductsByIds(Iterable<String> ids) async {
    final unique = ids.where((e) => e.trim().isNotEmpty).toSet().toList();
    if (unique.isEmpty) return const [];

    const chunkSize = 10;
    final results = <Product>[];
    for (var i = 0; i < unique.length; i += chunkSize) {
      final chunk = unique.sublist(i, (i + chunkSize).clamp(0, unique.length));
      final snap = await _ds.fetchByIds(chunk);
      results.addAll(snap.docs.map(_fromDoc));
    }
    return results;
  }

  Product _fromDoc(doc) {
    final data =
        (doc.data() as Map<String, dynamic>?) ?? const <String, dynamic>{};
    return _fromMap(id: doc.id, data: data);
  }

  Product _fromMap({required String id, required Map<String, dynamic> data}) {
    final title = (data['title'] as String?) ?? 'Product';
    final brand = (data['brand'] as String?) ?? 'Unknown';
    final price = (data['price'] as num?)?.toDouble() ?? 0;
    final currency = (data['currency'] as String?) ?? 'USD';
    final description = (data['description'] as String?) ?? '';

    final imageUrlsRaw = data['imageUrls'];
    final imageUrls = imageUrlsRaw is List
        ? imageUrlsRaw.whereType<String>().toList(growable: false)
        : const <String>[];

    final variantsRaw = data['variants'];
    final variants = <Variant>[];
    if (variantsRaw is List) {
      for (final v in variantsRaw) {
        if (v is Map) {
          variants.add(Variant.fromJson(v.cast<String, dynamic>()));
        }
      }
    }

    return Product(
      id: id,
      title: title,
      brand: brand,
      price: price,
      currency: currency,
      imageUrls: imageUrls,
      description: description.trim().isEmpty
          ? 'No description available.'
          : description,
      variants: variants,
    );
  }
}
