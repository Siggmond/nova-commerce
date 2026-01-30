import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/product.dart';
import 'home_viewmodel.dart';

enum HomeSort { newest, priceAsc, priceDesc }

class HomeBrowseFilters {
  const HomeBrowseFilters({
    this.query = '',
    this.brand,
    this.inStockOnly = false,
    this.priceRange,
    this.sort = HomeSort.newest,
  });

  final String query;
  final String? brand;
  final bool inStockOnly;
  final RangeValues? priceRange;
  final HomeSort sort;

  HomeBrowseFilters copyWith({
    String? query,
    String? brand,
    bool clearBrand = false,
    bool? inStockOnly,
    RangeValues? priceRange,
    bool clearPriceRange = false,
    HomeSort? sort,
  }) {
    return HomeBrowseFilters(
      query: query ?? this.query,
      brand: clearBrand ? null : (brand ?? this.brand),
      inStockOnly: inStockOnly ?? this.inStockOnly,
      priceRange: clearPriceRange ? null : (priceRange ?? this.priceRange),
      sort: sort ?? this.sort,
    );
  }
}

final homeBrowseFiltersProvider =
    StateNotifierProvider<HomeBrowseFiltersController, HomeBrowseFilters>((
      ref,
    ) {
      return HomeBrowseFiltersController();
    });

class HomeBrowseFiltersController extends StateNotifier<HomeBrowseFilters> {
  HomeBrowseFiltersController() : super(const HomeBrowseFilters());

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void setQueryDebounced(
    String q, {
    Duration delay = const Duration(milliseconds: 260),
  }) {
    _debounce?.cancel();
    _debounce = Timer(delay, () {
      state = state.copyWith(query: q);
    });
  }

  void setQueryImmediate(String q) {
    _debounce?.cancel();
    state = state.copyWith(query: q);
  }

  void setBrand(String? brand) {
    state = state.copyWith(brand: brand);
  }

  void setInStockOnly(bool v) {
    state = state.copyWith(inStockOnly: v);
  }

  void setPriceRange(RangeValues? range) {
    state = state.copyWith(priceRange: range);
  }

  void setSort(HomeSort sort) {
    state = state.copyWith(sort: sort);
  }

  void reset() {
    _debounce?.cancel();
    state = const HomeBrowseFilters();
  }
}

class HomeCatalogMeta {
  const HomeCatalogMeta({
    required this.brands,
    required this.minPrice,
    required this.maxPrice,
  });

  final List<String> brands;
  final double minPrice;
  final double maxPrice;
}

final homeCatalogMetaProvider = Provider<HomeCatalogMeta>((ref) {
  final items = ref
      .watch(homeViewModelProvider)
      .when(
        loading: () => const <Product>[],
        error: (_) => const <Product>[],
        data: (items, __, ___, ____) => items,
      );

  final brands =
      items
          .map((p) => p.brand.trim())
          .where((b) => b.isNotEmpty)
          .toSet()
          .toList(growable: true)
        ..sort();

  final minPrice = items.isEmpty
      ? 0.0
      : items.map((p) => p.price).reduce((a, b) => a < b ? a : b);
  final maxPrice = items.isEmpty
      ? 0.0
      : items.map((p) => p.price).reduce((a, b) => a > b ? a : b);

  return HomeCatalogMeta(
    brands: brands,
    minPrice: minPrice,
    maxPrice: maxPrice,
  );
});

final homeFilteredProductsProvider = Provider<List<Product>>((ref) {
  final items = ref
      .watch(homeViewModelProvider)
      .when(
        loading: () => const <Product>[],
        error: (_) => const <Product>[],
        data: (items, __, ___, ____) => items,
      );

  final filters = ref.watch(homeBrowseFiltersProvider);
  final meta = ref.watch(homeCatalogMetaProvider);

  final safeMaxPrice = meta.maxPrice <= meta.minPrice
      ? (meta.minPrice + 1)
      : meta.maxPrice;
  final range = filters.priceRange ?? RangeValues(meta.minPrice, safeMaxPrice);

  final q = filters.query.trim().toLowerCase();
  final brand = filters.brand?.trim();

  final filtered = items
      .where((p) {
        if (brand != null && brand.isNotEmpty) {
          if (p.brand.trim() != brand) return false;
        }
        if (filters.inStockOnly) {
          if (!p.variants.any((v) => v.stock > 0)) return false;
        }
        if (p.price < range.start || p.price > range.end) return false;
        if (q.isNotEmpty) {
          final hay = '${p.title} ${p.brand}'.toLowerCase();
          if (!hay.contains(q)) return false;
        }
        return true;
      })
      .toList(growable: true);

  switch (filters.sort) {
    case HomeSort.priceAsc:
      filtered.sort((a, b) => a.price.compareTo(b.price));
      break;
    case HomeSort.priceDesc:
      filtered.sort((a, b) => b.price.compareTo(a.price));
      break;
    case HomeSort.newest:
      break;
  }

  return filtered;
});

final homePersonalizationEnabledProvider = Provider<bool>((ref) {
  return false;
});

final homeUnder50ProductsProvider = Provider<List<Product>>((ref) {
  final items = ref.watch(homeFilteredProductsProvider);
  return items.where((p) => p.price <= 50).toList(growable: false);
});
