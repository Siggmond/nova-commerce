import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../domain/entities/product.dart';

const int _recentlyViewedLimit = 12;

final recentlyViewedViewModelProvider =
    StateNotifierProvider<RecentlyViewedViewModel, List<String>>((ref) {
  return RecentlyViewedViewModel(ref);
});

final recentlyViewedProductsProvider = FutureProvider<List<Product>>((ref) async {
  final ids = ref.watch(recentlyViewedViewModelProvider);
  if (ids.isEmpty) return const [];

  final repo = ref.read(productRepositoryProvider);
  final products = await repo.getProductsByIds(ids);
  final byId = {for (final p in products) p.id: p};

  final ordered = <Product>[];
  for (final id in ids) {
    final p = byId[id];
    if (p != null) ordered.add(p);
  }
  return ordered;
});

class RecentlyViewedViewModel extends StateNotifier<List<String>> {
  RecentlyViewedViewModel(this._ref) : super(const []) {
    refresh();
  }

  final Ref _ref;

  Future<void> refresh() async {
    final repo = _ref.read(recentlyViewedRepositoryProvider);
    final ids = await repo.loadIds();
    state = ids;
  }

  Future<void> add(String id) async {
    final trimmed = id.trim();
    if (trimmed.isEmpty) return;

    final current = [...state];
    current.removeWhere((item) => item == trimmed);
    current.insert(0, trimmed);

    if (current.length > _recentlyViewedLimit) {
      current.removeRange(_recentlyViewedLimit, current.length);
    }

    state = current;
    await _ref.read(recentlyViewedRepositoryProvider).saveIds(current);
  }
}
