import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../domain/entities/product.dart';
import 'search_categories.dart';
import 'search_filters.dart';

final searchViewModelProvider =
    StateNotifierProvider<SearchViewModel, AsyncValue<List<Product>>>((ref) {
      return SearchViewModel(ref);
    });

final searchFeaturedProductsProvider = Provider<List<Product>>((ref) {
  final catalog = ref.watch(searchViewModelProvider).value ?? const <Product>[];
  return catalog.take(10).toList(growable: false);
});

final searchFilteredProductsProvider = Provider<List<Product>>((ref) {
  final catalog = ref.watch(searchViewModelProvider).value ?? const <Product>[];
  final filters = ref.watch(searchFiltersProvider);
  return _applyFilters(items: catalog, filters: filters);
});

final searchCategoryForProductProvider = Provider<String Function(Product)>((
  ref,
) {
  return _categoryForProduct;
});

class SearchViewModel extends StateNotifier<AsyncValue<List<Product>>> {
  SearchViewModel(this._ref) : super(const AsyncValue.loading()) {
    refresh();
  }

  final Ref _ref;

  static const int _catalogSize = 60;

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(productRepositoryProvider);

      final items = <Product>[];
      Object? cursor;
      while (items.length < _catalogSize) {
        final remaining = _catalogSize - items.length;
        final limit = remaining > 20 ? 20 : remaining;
        final page = await repo.getFeaturedProducts(
          limit: limit < 1 ? 1 : limit,
          startAfter: cursor,
        );
        items.addAll(page.items);
        cursor = page.cursor;
        if (page.items.isEmpty || cursor == null) break;
      }

      final seen = <String>{};
      final deduped = <Product>[];
      for (final p in items) {
        if (seen.add(p.id)) deduped.add(p);
      }

      state = AsyncValue.data(deduped);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

List<Product> _applyFilters({
  required List<Product> items,
  required SearchFilters filters,
}) {
  final q = filters.query.trim().toLowerCase();
  final category = filters.category.trim();

  final prices = items.map((p) => p.price).toList(growable: false)..sort();
  final p33 = prices.isEmpty
      ? 0.0
      : prices[(prices.length * 0.33).floor().clamp(0, prices.length - 1)];
  final p66 = prices.isEmpty
      ? 0.0
      : prices[(prices.length * 0.66).floor().clamp(0, prices.length - 1)];

  bool matchesPriceTier(Product p) {
    final tier = filters.priceTier;
    if (tier == null) return true;
    return switch (tier) {
      SearchPriceTier.lowest => p.price <= p33,
      SearchPriceTier.midRange => p.price > p33 && p.price <= p66,
      SearchPriceTier.highEnd => p.price > p66,
    };
  }

  bool matchesQuery(Product p) {
    if (q.isEmpty) return true;
    final hay = '${p.title} ${p.brand}'.toLowerCase();
    return hay.contains(q);
  }

  bool matchesCategory(Product p) {
    if (category.isEmpty || category == 'All') return true;
    return _categoryForProduct(p) == category;
  }

  final filtered = items
      .where(
        (p) => matchesQuery(p) && matchesPriceTier(p) && matchesCategory(p),
      )
      .toList(growable: true);

  switch (filters.sort) {
    case SearchSort.recommended:
      break;
    case SearchSort.popular:
      filtered.sort((a, b) => _stableScore(b.id).compareTo(_stableScore(a.id)));
      break;
    case SearchSort.rating:
      filtered.sort(
        (a, b) => _stableScore(b.title).compareTo(_stableScore(a.title)),
      );
      break;
  }

  return filtered;
}

String _categoryForProduct(Product p) {
  final names = searchCategoryNames
      .where((e) => e != 'All')
      .toList(growable: false);
  if (names.isEmpty) return 'All';

  var hash = 0;
  for (final u in p.id.codeUnits) {
    hash = (hash + u) & 0x7fffffff;
  }
  final idx = hash % names.length;
  return names[idx];
}

int _stableScore(String s) {
  var hash = 0;
  for (final u in s.codeUnits) {
    hash = (hash * 31 + u) & 0x7fffffff;
  }
  return hash;
}
