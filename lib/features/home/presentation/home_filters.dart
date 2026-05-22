import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/entities/product.dart';
import '../../products/domain/usecases/filter_products_use_case.dart';
import 'home_viewmodel.dart';

enum HomeSort { recommended, newest, priceAsc, priceDesc }

class HomeBrowseFilters {
  const HomeBrowseFilters({
    this.query = '',
    this.brand,
    this.inStockOnly = false,
    this.priceRange,
    this.sort = HomeSort.recommended,
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
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _debounce?.cancel();
    super.dispose();
  }

  void setQueryDebounced(
    String q, {
    Duration delay = const Duration(milliseconds: 200),
  }) {
    if (_isDisposed) return;
    _debounce?.cancel();
    _debounce = Timer(delay, () {
      if (_isDisposed) return;
      _publish(state.copyWith(query: q));
    });
  }

  void setQueryImmediate(String q) {
    if (_isDisposed) return;
    _debounce?.cancel();
    _publish(state.copyWith(query: q));
  }

  void setBrand(String? brand) {
    if (_isDisposed) return;
    _publish(state.copyWith(brand: brand));
  }

  void setInStockOnly(bool v) {
    if (_isDisposed) return;
    _publish(state.copyWith(inStockOnly: v));
  }

  void setPriceRange(RangeValues? range) {
    if (_isDisposed) return;
    _publish(state.copyWith(priceRange: range));
  }

  void setSort(HomeSort sort) {
    if (_isDisposed) return;
    _publish(state.copyWith(sort: sort));
  }

  void reset() {
    if (_isDisposed) return;
    _debounce?.cancel();
    _publish(const HomeBrowseFilters());
  }

  void _publish(HomeBrowseFilters next) {
    if (_isDisposed) return;
    state = next;
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

final homeItemsProvider = Provider<List<Product>>((ref) {
  return ref
      .watch(homeViewModelProvider)
      .when(
        loading: () => const <Product>[],
        error: (_) => const <Product>[],
        data: (items, __, ___, ____) => items,
      );
});

final homeCatalogMetaProvider = Provider<HomeCatalogMeta>((ref) {
  final items = ref.watch(homeItemsProvider);

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

final homeActiveCategoryProvider = StateProvider<String>((ref) {
  return 'all';
});

final filterProductsUseCaseProvider = Provider<FilterProductsUseCase>((ref) {
  return FilterProductsUseCase();
});

final homeFilteredProductsControllerProvider =
    StateNotifierProvider<HomeFilteredProductsController, List<Product>>((ref) {
      return HomeFilteredProductsController(
        ref,
        ref.watch(filterProductsUseCaseProvider),
      );
    });

final homeFilteredProductsProvider = Provider<List<Product>>((ref) {
  return ref.watch(homeFilteredProductsControllerProvider);
});

class HomeFilteredProductsController extends StateNotifier<List<Product>> {
  HomeFilteredProductsController(this._ref, this._filterProductsUseCase)
    : _items = _ref.read(homeItemsProvider),
      _filters = _ref.read(homeBrowseFiltersProvider),
      _activeCategory = _ref.read(homeActiveCategoryProvider),
      super(const <Product>[]) {
    _scheduleRecompute(queryChanged: false);

    _ref.listen<List<Product>>(homeItemsProvider, (_, next) {
      if (_isDisposed) return;
      _items = next;
      _scheduleRecompute(queryChanged: false);
    });

    _ref.listen<HomeBrowseFilters>(homeBrowseFiltersProvider, (prev, next) {
      if (_isDisposed) return;
      _filters = next;
      final queryChanged = (prev?.query ?? '').trim() != next.query.trim();
      _scheduleRecompute(queryChanged: queryChanged);
    });

    _ref.listen<String>(homeActiveCategoryProvider, (_, next) {
      if (_isDisposed) return;
      _activeCategory = next;
      _scheduleRecompute(queryChanged: false);
    });
  }

  static const Duration _queryDebounce = Duration(milliseconds: 200);

  final Ref _ref;
  final FilterProductsUseCase _filterProductsUseCase;

  List<Product> _items;
  HomeBrowseFilters _filters;
  String _activeCategory;

  Timer? _debounce;
  int _requestId = 0;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _requestId += 1;
    _debounce?.cancel();
    super.dispose();
  }

  void _scheduleRecompute({required bool queryChanged}) {
    if (_isDisposed) return;
    if (_items.isEmpty) {
      _debounce?.cancel();
      _requestId += 1;
      _setStateIfChanged(const <Product>[]);
      return;
    }

    final params = _toFilterParams();
    if (params.isDefault) {
      _debounce?.cancel();
      _requestId += 1;
      _setStateIfChanged(_items);
      return;
    }

    Future<void> run() async {
      if (_isDisposed) return;
      final requestId = ++_requestId;
      final filtered = await _filterProductsUseCase(
        products: _items,
        params: params,
      );
      if (_isDisposed || !mounted || requestId != _requestId) return;
      _setStateIfChanged(filtered);
    }

    if (queryChanged) {
      _debounce?.cancel();
      _debounce = Timer(_queryDebounce, () {
        if (_isDisposed) return;
        unawaited(run());
      });
      return;
    }

    _debounce?.cancel();
    unawaited(run());
  }

  ProductFilterParams _toFilterParams() {
    final prices = _minMaxPrice(_items);
    final min = prices.$1;
    final max = prices.$2;
    final safeMax = max <= min ? (min + 1) : max;
    final range = _filters.priceRange ?? RangeValues(min, safeMax);

    return ProductFilterParams(
      query: _filters.query,
      brand: _filters.brand?.trim(),
      category: _activeCategory,
      inStockOnly: _filters.inStockOnly,
      minPrice: range.start,
      maxPrice: range.end,
      sort: switch (_filters.sort) {
        HomeSort.recommended => ProductFilterSort.recommended,
        HomeSort.newest => ProductFilterSort.newest,
        HomeSort.priceAsc => ProductFilterSort.priceAsc,
        HomeSort.priceDesc => ProductFilterSort.priceDesc,
      },
    );
  }

  (double, double) _minMaxPrice(List<Product> items) {
    if (items.isEmpty) return (0.0, 0.0);
    var min = items.first.price;
    var max = items.first.price;
    for (final product in items.skip(1)) {
      if (product.price < min) min = product.price;
      if (product.price > max) max = product.price;
    }
    return (min, max);
  }

  void _setStateIfChanged(List<Product> next) {
    if (_isDisposed || !mounted) return;
    if (_sameProductList(state, next)) return;
    state = next;
  }

  bool _sameProductList(List<Product> a, List<Product> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final left = a[i];
      final right = b[i];
      if (left.id != right.id || left.price != right.price) {
        return false;
      }
    }
    return true;
  }
}

final homePersonalizationEnabledProvider = Provider<bool>((ref) {
  return false;
});
