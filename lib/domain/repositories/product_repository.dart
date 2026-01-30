import '../entities/product.dart';

class FeaturedProductsPage {
  const FeaturedProductsPage({required this.items, required this.cursor});

  final List<Product> items;

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
