import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nova_commerce/core/domain/entities/product.dart';
import 'package:nova_commerce/core/domain/repositories/product_repository.dart';

class CachedProductRepository implements ProductRepository {
  CachedProductRepository(this._inner);

  final ProductRepository _inner;

  static const Duration _featuredPageTtl = Duration(seconds: 45);
  static const int _featuredPageCacheCapacity = 24;
  static const Duration _productTtl = Duration(minutes: 5);
  static const Duration _missingProductTtl = Duration(seconds: 45);

  final LinkedHashMap<String, _FeaturedPageEntry> _featuredPageCache =
      LinkedHashMap<String, _FeaturedPageEntry>();
  final Map<String, Future<FeaturedProductsPage>> _featuredPageInFlight =
      <String, Future<FeaturedProductsPage>>{};

  final Map<String, _ProductEntry> _productCache = <String, _ProductEntry>{};
  final Map<String, Future<Product?>> _productInFlight =
      <String, Future<Product?>>{};

  @override
  Future<FeaturedProductsPage> getFeaturedProducts({
    int limit = 20,
    Object? startAfter,
  }) async {
    final cacheKey = _featuredPageKey(limit: limit, startAfter: startAfter);

    final cached = _featuredPageCache[cacheKey];
    if (cached != null) {
      if (!_isExpired(cached.cachedAt, _featuredPageTtl)) {
        _touchFeaturedPage(cacheKey, cached);
        return cached.page;
      }
      _featuredPageCache.remove(cacheKey);
    }

    final inFlight = _featuredPageInFlight[cacheKey];
    if (inFlight != null) {
      return inFlight;
    }

    final future = _inner
        .getFeaturedProducts(limit: limit, startAfter: startAfter)
        .then((page) {
          _cacheFeaturedPage(cacheKey, page);
          _primeProductCache(page.items);
          return page;
        })
        .whenComplete(() {
          _featuredPageInFlight.remove(cacheKey);
        });

    _featuredPageInFlight[cacheKey] = future;
    return future;
  }

  @override
  Future<Product?> getProductById(String id) async {
    final key = id.trim();
    if (key.isEmpty) return null;

    final cached = _productCache[key];
    if (cached != null && !_isExpired(cached.cachedAt, cached.ttl)) {
      return cached.product;
    }

    final inFlight = _productInFlight[key];
    if (inFlight != null) {
      return inFlight;
    }

    final future = _inner
        .getProductById(key)
        .then((product) {
          _cacheProduct(product: product, idOverride: key);
          return product;
        })
        .whenComplete(() {
          _productInFlight.remove(key);
        });

    _productInFlight[key] = future;
    return future;
  }

  @override
  Future<List<Product>> getProductsByIds(Iterable<String> ids) async {
    final orderedIds = <String>[];
    final seen = <String>{};
    for (final raw in ids) {
      final id = raw.trim();
      if (id.isEmpty) continue;
      if (!seen.add(id)) continue;
      orderedIds.add(id);
    }
    if (orderedIds.isEmpty) return const <Product>[];

    final now = DateTime.now();
    final cachedProducts = <String, Product>{};
    final missingIds = <String>[];

    for (final id in orderedIds) {
      final cached = _productCache[id];
      if (cached != null && !_isExpired(cached.cachedAt, cached.ttl)) {
        final product = cached.product;
        if (product != null) {
          cachedProducts[id] = product;
        }
      } else {
        missingIds.add(id);
      }
    }

    if (missingIds.isNotEmpty) {
      final fetched = await _inner.getProductsByIds(missingIds);
      final fetchedById = <String, Product>{for (final p in fetched) p.id: p};

      for (final id in missingIds) {
        final product = fetchedById[id];
        _productCache[id] = _ProductEntry(
          product: product,
          cachedAt: now,
          ttl: product == null ? _missingProductTtl : _productTtl,
        );
        if (product != null) {
          cachedProducts[id] = product;
        }
      }
    }

    final orderedProducts = <Product>[];
    for (final id in orderedIds) {
      final product = cachedProducts[id];
      if (product != null) {
        orderedProducts.add(product);
      }
    }
    return orderedProducts;
  }

  void _primeProductCache(List<Product> items) {
    if (items.isEmpty) return;
    final now = DateTime.now();
    for (final item in items) {
      _productCache[item.id] = _ProductEntry(
        product: item,
        cachedAt: now,
        ttl: _productTtl,
      );
    }
  }

  void _cacheProduct({required Product? product, String? idOverride}) {
    final key = (idOverride ?? product?.id ?? '').trim();
    if (key.isEmpty) return;

    _productCache[key] = _ProductEntry(
      product: product,
      cachedAt: DateTime.now(),
      ttl: product == null ? _missingProductTtl : _productTtl,
    );
  }

  static bool _isExpired(DateTime cachedAt, Duration ttl) {
    return DateTime.now().difference(cachedAt) > ttl;
  }

  void _cacheFeaturedPage(String key, FeaturedProductsPage page) {
    _featuredPageCache.remove(key);
    _featuredPageCache[key] = _FeaturedPageEntry(
      page: page,
      cachedAt: DateTime.now(),
    );

    while (_featuredPageCache.length > _featuredPageCacheCapacity) {
      _featuredPageCache.remove(_featuredPageCache.keys.first);
    }
  }

  void _touchFeaturedPage(String key, _FeaturedPageEntry entry) {
    _featuredPageCache.remove(key);
    _featuredPageCache[key] = entry;
  }

  String _featuredPageKey({required int limit, required Object? startAfter}) {
    final cursorKey = switch (startAfter) {
      null => 'root',
      final String value => 'id:${value.trim()}',
      final DocumentSnapshot<Object?> doc => 'doc:${doc.reference.path}',
      _ => 'obj:${startAfter.hashCode}',
    };
    return 'limit:$limit|cursor:$cursorKey';
  }
}

class _FeaturedPageEntry {
  const _FeaturedPageEntry({required this.page, required this.cachedAt});

  final FeaturedProductsPage page;
  final DateTime cachedAt;
}

class _ProductEntry {
  const _ProductEntry({
    required this.product,
    required this.cachedAt,
    required this.ttl,
  });

  final Product? product;
  final DateTime cachedAt;
  final Duration ttl;
}
