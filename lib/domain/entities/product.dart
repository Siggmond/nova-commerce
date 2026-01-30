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

  String get imageUrl {
    for (final url in imageUrls) {
      final normalized = _normalizeImageUrl(url);
      if (normalized.isNotEmpty) return normalized;
    }
    return '';
  }

  String _normalizeImageUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('//')) return 'https:$trimmed';
    return trimmed;
  }

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
