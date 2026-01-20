import '../entities/product.dart';

class FeaturedProductsPage {
  const FeaturedProductsPage({required this.items, required this.cursor});

  final List<Product> items;

  /// Repository-specific pagination cursor.
  ///
  /// - Firestore implementation: `DocumentSnapshot<Map<String, dynamic>>`
  /// - Fake implementation: last product id (`String`)
  final Object? cursor;
}

abstract class ProductRepository {
  Future<FeaturedProductsPage> getFeaturedProducts({
    int limit = 20,
    Object? startAfter,
  });
  Future<Product?> getProductById(String id);
  Future<List<Product>> getProductsByIds(Iterable<String> ids);
}
