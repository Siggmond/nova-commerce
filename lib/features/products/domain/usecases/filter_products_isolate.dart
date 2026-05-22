List<int> filterProductIndicesInIsolate(Map<String, Object?> payload) {
  final rawProducts =
      payload['products'] as List<dynamic>? ?? const <dynamic>[];
  final params =
      payload['params'] as Map<String, Object?>? ?? const <String, Object?>{};

  final query = (params['query'] as String? ?? '').trim().toLowerCase();
  final brand = (params['brand'] as String? ?? '').trim().toLowerCase();
  final category = (params['category'] as String? ?? '').trim().toLowerCase();
  final inStockOnly = params['inStockOnly'] == true;
  final minPrice = _toDouble(params['minPrice']);
  final maxPrice = _toDouble(params['maxPrice']);
  final sort = (params['sort'] as String? ?? 'recommended').trim();

  final hasCategoryFilter = category.isNotEmpty && category != 'all';
  final hasQueryFilter = query.isNotEmpty;
  final hasBrandFilter = brand.isNotEmpty;
  final hasPriceFilter = minPrice != null || maxPrice != null;
  final hasInStockFilter = inStockOnly;

  if (!hasCategoryFilter &&
      !hasQueryFilter &&
      !hasBrandFilter &&
      !hasPriceFilter &&
      !hasInStockFilter &&
      sort == 'recommended') {
    return rawProducts
        .map((raw) => _toStringKeyedMap(raw))
        .whereType<Map<String, Object?>>()
        .map((map) => (map['index'] as num?)?.toInt() ?? -1)
        .where((index) => index >= 0)
        .toList(growable: false);
  }

  final filtered = <_IndexedProductPayload>[];
  for (final rawProduct in rawProducts) {
    final product = _toStringKeyedMap(rawProduct);
    if (product == null) continue;

    final index = (product['index'] as num?)?.toInt() ?? -1;
    if (index < 0) continue;

    final searchToken = (product['searchToken'] as String? ?? '').trim();
    final brandToken = (product['brandToken'] as String? ?? '').trim();
    final price = _toDouble(product['price']) ?? 0;
    final inStock = product['inStock'] == true;

    if (hasCategoryFilter && !searchToken.contains(category)) continue;
    if (hasBrandFilter && brandToken != brand) continue;
    if (hasInStockFilter && !inStock) continue;
    if (hasPriceFilter) {
      if (minPrice != null && price < minPrice) continue;
      if (maxPrice != null && price > maxPrice) continue;
    }
    if (hasQueryFilter && !searchToken.contains(query)) continue;

    filtered.add(_IndexedProductPayload(index: index, price: price));
  }

  switch (sort) {
    case 'priceAsc':
      filtered.sort((a, b) => a.price.compareTo(b.price));
      break;
    case 'priceDesc':
      filtered.sort((a, b) => b.price.compareTo(a.price));
      break;
    default:
      break;
  }

  return filtered.map((entry) => entry.index).toList(growable: false);
}

class _IndexedProductPayload {
  const _IndexedProductPayload({required this.index, required this.price});

  final int index;
  final double price;
}

Map<String, Object?>? _toStringKeyedMap(Object? raw) {
  if (raw is! Map) return null;
  final map = <String, Object?>{};
  for (final entry in raw.entries) {
    final key = entry.key;
    if (key is String) {
      map[key] = entry.value;
    }
  }
  return map;
}

double? _toDouble(Object? value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}
