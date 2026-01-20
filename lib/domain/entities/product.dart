import 'variant.dart';

class Product {
  const Product({
    required this.id,
    required this.title,
    required this.brand,
    required this.price,
    required this.currency,
    required this.imageUrls,
    required this.description,
    required this.variants,
  });

  final String id;
  final String title;
  final String brand;
  final double price;
  final String currency;
  final List<String> imageUrls;
  final String description;
  final List<Variant> variants;

  String get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  List<String> get availableColors {
    final colors = <String>{};
    for (final v in variants) {
      if (v.color.trim().isNotEmpty) colors.add(v.color);
    }
    return colors.toList()..sort();
  }

  List<String> get availableSizes {
    final sizes = <String>{};
    for (final v in variants) {
      if (v.size.trim().isNotEmpty) sizes.add(v.size);
    }
    return sizes.toList()..sort();
  }
}
