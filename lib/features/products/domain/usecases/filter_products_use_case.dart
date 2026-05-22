import 'package:flutter/foundation.dart';

import 'package:nova_commerce/core/domain/entities/product.dart';

import 'filter_products_isolate.dart';

enum ProductFilterSort { recommended, newest, priceAsc, priceDesc }

class ProductFilterParams {
  const ProductFilterParams({
    this.query = '',
    this.brand,
    this.category = 'all',
    this.inStockOnly = false,
    this.minPrice,
    this.maxPrice,
    this.sort = ProductFilterSort.recommended,
  });

  final String query;
  final String? brand;
  final String category;
  final bool inStockOnly;
  final double? minPrice;
  final double? maxPrice;
  final ProductFilterSort sort;

  bool get isDefault {
    final normalizedQuery = query.trim();
    final normalizedBrand = (brand ?? '').trim();
    final normalizedCategory = category.trim().toLowerCase();
    return normalizedQuery.isEmpty &&
        normalizedBrand.isEmpty &&
        !inStockOnly &&
        minPrice == null &&
        maxPrice == null &&
        sort == ProductFilterSort.recommended &&
        (normalizedCategory.isEmpty || normalizedCategory == 'all');
  }
}

class FilterProductsUseCase {
  FilterProductsUseCase();

  final Map<String, _ProductFilterCacheEntry> _cacheByProductId =
      <String, _ProductFilterCacheEntry>{};

  Future<List<Product>> call({
    required List<Product> products,
    required ProductFilterParams params,
  }) async {
    if (products.isEmpty) return const <Product>[];
    if (params.isDefault) return products;

    final payloadProducts = <Map<String, Object?>>[];
    for (var index = 0; index < products.length; index++) {
      final product = products[index];
      final cached = _cachedEntryFor(product);
      payloadProducts.add({
        'index': index,
        'searchToken': cached.searchToken,
        'brandToken': cached.brandToken,
        'price': cached.price,
        'inStock': cached.inStock,
      });
    }

    final payload = <String, Object?>{
      'products': payloadProducts,
      'params': <String, Object?>{
        'query': params.query.trim().toLowerCase(),
        'brand': (params.brand ?? '').trim().toLowerCase(),
        'category': params.category.trim().toLowerCase(),
        'inStockOnly': params.inStockOnly,
        'minPrice': params.minPrice,
        'maxPrice': params.maxPrice,
        'sort': params.sort.name,
      },
    };

    final filteredIndices = await compute(
      filterProductIndicesInIsolate,
      payload,
    );
    if (filteredIndices.isEmpty) return const <Product>[];

    final filtered = <Product>[];
    for (final index in filteredIndices) {
      if (index < 0 || index >= products.length) continue;
      filtered.add(products[index]);
    }
    return filtered;
  }

  _ProductFilterCacheEntry _cachedEntryFor(Product product) {
    final signature = _productSignature(product);
    final id = product.id.trim();
    if (id.isNotEmpty) {
      final cached = _cacheByProductId[id];
      if (cached != null && cached.signature == signature) {
        return cached;
      }
    }

    final title = product.title.trim().toLowerCase();
    final brandLower = product.brand.trim().toLowerCase();
    final searchToken = '$title $brandLower'.trim();
    final inStock = product.variants.any((variant) => variant.stock > 0);

    final entry = _ProductFilterCacheEntry(
      signature: signature,
      searchToken: searchToken,
      brandToken: brandLower,
      inStock: inStock,
      price: product.price,
    );

    if (id.isNotEmpty) {
      _cacheByProductId[id] = entry;
    }
    return entry;
  }

  String _productSignature(Product product) {
    final title = product.title.trim().toLowerCase();
    final brand = product.brand.trim().toLowerCase();
    var stockSum = 0;
    for (final variant in product.variants) {
      stockSum += variant.stock;
    }
    return '$title|$brand|${product.price}|${product.variants.length}|$stockSum';
  }
}

class _ProductFilterCacheEntry {
  const _ProductFilterCacheEntry({
    required this.signature,
    required this.searchToken,
    required this.brandToken,
    required this.inStock,
    required this.price,
  });

  final String signature;
  final String searchToken;
  final String brandToken;
  final bool inStock;
  final double price;
}
