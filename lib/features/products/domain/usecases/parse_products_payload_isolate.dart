import 'dart:convert';
import 'dart:developer' as developer;

import 'package:nova_commerce/core/domain/entities/product.dart';
import 'package:nova_commerce/core/domain/entities/variant.dart';

List<Product> parseProductsPayloadInIsolate(String rawJson) {
  final decoded = jsonDecode(rawJson);
  final productItems = _extractProductItems(decoded);
  if (productItems.isEmpty) return const <Product>[];

  final products = <Product>[];
  for (final item in productItems) {
    final product = _mapProduct(item);
    if (product != null) {
      products.add(product);
    }
  }
  return products;
}

List<Map<String, dynamic>> _extractProductItems(Object? decoded) {
  if (decoded is List) {
    return decoded
        .map(_toStringKeyedMap)
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  final root = _toStringKeyedMap(decoded);
  if (root == null) return const <Map<String, dynamic>>[];

  final items = root['items'];
  if (items is List) {
    return items
        .map(_toStringKeyedMap)
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  return <Map<String, dynamic>>[root];
}

Map<String, dynamic>? _toStringKeyedMap(Object? raw) {
  if (raw is! Map) return null;
  final map = <String, dynamic>{};
  for (final entry in raw.entries) {
    final key = entry.key;
    if (key is String) {
      map[key] = entry.value;
    }
  }
  return map;
}

Product? _mapProduct(Map<String, dynamic> item) {
  final data = _toStringKeyedMap(item['data']) ?? item;
  final topId = _readString(item, 'id');
  final id = topId.isEmpty ? _readString(data, 'id') : topId;
  if (id.isEmpty) return null;

  final imageUrlsRaw = data['imageUrls'];
  final imageUrls = imageUrlsRaw is List
      ? imageUrlsRaw
            .whereType<String>()
            .map(_normalizeImageUrl)
            .whereType<String>()
            .toList(growable: false)
      : const <String>[];

  final variantsRaw = data['variants'];
  final variants = <Variant>[];
  if (variantsRaw is List) {
    for (final rawVariant in variantsRaw) {
      final parsed = Variant.tryFromJson(rawVariant);
      if (parsed != null) {
        variants.add(parsed);
      } else {
        developer.log(
          'Skipping invalid variant payload during isolate parsing',
          name: 'ParseProductsPayloadIsolate',
          error: {'productId': id},
        );
      }
    }
  }

  final description = _readString(data, 'description');

  return Product(
    id: id,
    title: _readString(data, 'title', fallback: 'Product'),
    brand: _readString(data, 'brand', fallback: 'Unknown'),
    price: _toDouble(data['price']),
    currency: _readString(data, 'currency', fallback: 'USD'),
    imageUrls: imageUrls,
    description: description.isEmpty
        ? 'No description available.'
        : description,
    variants: variants,
  );
}

String _readString(
  Map<String, dynamic> map,
  String key, {
  String fallback = '',
}) {
  final value = map[key];
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) return trimmed;
    return fallback;
  }
  return fallback;
}

double _toDouble(Object? value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) {
    return double.tryParse(value.trim()) ?? 0;
  }
  return 0;
}

String? _normalizeImageUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.startsWith('//')) return 'https:$trimmed';
  return trimmed;
}
