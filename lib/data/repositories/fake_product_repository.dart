import '../../domain/entities/product.dart';
import '../../domain/entities/variant.dart';
import '../../domain/repositories/product_repository.dart';

class FakeProductRepository implements ProductRepository {
  static const _lorem =
      'Premium fabric, clean silhouette, built for everyday wear. Designed to feel expensive without the markup.';

  static const List<Product> _products = [
    Product(
      id: 'demo-hoodie-001',
      title: 'Oversized Hoodie',
      brand: 'Nova Studio',
      price: 59.0,
      currency: 'USD',
      imageUrls: [
        'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?auto=format&fit=crop&w=1200&q=60',
      ],
      description:
          'Premium heavyweight cotton hoodie with a relaxed fit, designed for everyday comfort.',
      variants: [
        Variant(color: 'Black', size: 'M', stock: 10),
        Variant(color: 'Black', size: 'L', stock: 8),
        Variant(color: 'Gray', size: 'M', stock: 6),
      ],
    ),
    Product(
      id: 'p1',
      title: 'Black Oversized Hoodie',
      brand: 'Nova Basics',
      price: 44.0,
      currency: 'USD',
      imageUrls: [
        'https://images.unsplash.com/photo-1520975693416-35a0d50c1bb9?auto=format&fit=crop&w=1200&q=60',
      ],
      description: _lorem,
      variants: [
        Variant(color: 'Black', size: 'S', stock: 12),
        Variant(color: 'Black', size: 'M', stock: 18),
        Variant(color: 'Black', size: 'L', stock: 10),
        Variant(color: 'Black', size: 'XL', stock: 6),
        Variant(color: 'Charcoal', size: 'M', stock: 14),
        Variant(color: 'Cream', size: 'L', stock: 9),
      ],
    ),
    Product(
      id: 'p2',
      title: 'Minimal Sneakers',
      brand: 'Nova Street',
      price: 59.0,
      currency: 'USD',
      imageUrls: [
        'https://images.unsplash.com/photo-1528701800489-20be3c2ea0dd?auto=format&fit=crop&w=1200&q=60',
      ],
      description: _lorem,
      variants: [
        Variant(color: 'White', size: '40', stock: 4),
        Variant(color: 'White', size: '41', stock: 7),
        Variant(color: 'White', size: '42', stock: 9),
        Variant(color: 'Black', size: '42', stock: 8),
        Variant(color: 'Black', size: '43', stock: 5),
        Variant(color: 'Black', size: '44', stock: 3),
      ],
    ),
    Product(
      id: 'p3',
      title: 'Everyday Cargo Pants',
      brand: 'Nova Utility',
      price: 39.0,
      currency: 'USD',
      imageUrls: [
        'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?auto=format&fit=crop&w=1200&q=60',
      ],
      description: _lorem,
      variants: [
        Variant(color: 'Olive', size: '28', stock: 6),
        Variant(color: 'Olive', size: '30', stock: 10),
        Variant(color: 'Olive', size: '32', stock: 14),
        Variant(color: 'Black', size: '32', stock: 8),
        Variant(color: 'Black', size: '34', stock: 5),
        Variant(color: 'Black', size: '36', stock: 4),
      ],
    ),
  ];

  @override
  Future<FeaturedProductsPage> getFeaturedProducts({
    int limit = 20,
    Object? startAfter,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final startAfterId = startAfter is String ? startAfter : null;
    if (startAfterId == null || startAfterId.trim().isEmpty) {
      final items = _products.take(limit).toList(growable: false);
      final cursor = items.isEmpty ? null : items.last.id;
      return FeaturedProductsPage(items: items, cursor: cursor);
    }
    final startIndex = _products.indexWhere((p) => p.id == startAfterId);
    final from = startIndex < 0 ? 0 : (startIndex + 1);
    final items = _products.skip(from).take(limit).toList(growable: false);
    final cursor = items.isEmpty ? null : items.last.id;
    return FeaturedProductsPage(items: items, cursor: cursor);
  }

  @override
  Future<Product?> getProductById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Product>> getProductsByIds(Iterable<String> ids) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final wanted = ids.toSet();
    return _products
        .where((p) => wanted.contains(p.id))
        .toList(growable: false);
  }
}
