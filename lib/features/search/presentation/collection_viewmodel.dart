import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/entities/product.dart';
import 'collection_catalog.dart';
import 'search_filters.dart';
import 'search_viewmodel.dart';

final collectionFiltersProvider = StateNotifierProvider.autoDispose
    .family<SearchFiltersController, SearchFilters, String>((
      ref,
      collectionId,
    ) {
      return SearchFiltersController();
    });

final collectionProductsProvider = Provider.autoDispose
    .family<List<Product>, String>((ref, collectionId) {
      final collection = searchCollectionById(collectionId);
      if (collection == null) return const <Product>[];

      final catalog =
          ref.watch(searchViewModelProvider).value ?? const <Product>[];
      final categoryFor = ref.watch(searchCategoryForProductProvider);

      final base = catalog
          .where((p) => categoryFor(p) == collection.categoryId)
          .toList(growable: false);

      final filters = ref.watch(collectionFiltersProvider(collectionId));

      return _applyCollectionFilters(items: base, filters: filters);
    });

List<Product> _applyCollectionFilters({
  required List<Product> items,
  required SearchFilters filters,
}) {
  final q = filters.query.trim().toLowerCase();
  final hasPriceTier = filters.priceTier != null;
  final hasQuery = q.isNotEmpty;
  final hasSort = filters.sort != SearchSort.recommended;

  if (!hasPriceTier && !hasQuery && !hasSort) {
    return items;
  }

  var p33 = 0.0;
  var p66 = 0.0;
  if (hasPriceTier) {
    final prices = items.map((p) => p.price).toList(growable: false)..sort();
    p33 = prices.isEmpty
        ? 0.0
        : prices[(prices.length * 0.33).floor().clamp(0, prices.length - 1)];
    p66 = prices.isEmpty
        ? 0.0
        : prices[(prices.length * 0.66).floor().clamp(0, prices.length - 1)];
  }

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

  final filtered = items
      .where((p) => matchesQuery(p) && matchesPriceTier(p))
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

int _stableScore(String s) {
  var hash = 0;
  for (final u in s.codeUnits) {
    hash = (hash * 31 + u) & 0x7fffffff;
  }
  return hash;
}
