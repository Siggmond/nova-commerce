import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../core/config/auth_providers.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/cart_line.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/recommended_item.dart';
import '../../../domain/entities/variant.dart';

final cartViewModelProvider =
    StateNotifierProvider<CartViewModel, AsyncValue<List<CartItem>>>((ref) {
      return CartViewModel(ref);
    });

final cartItemsProvider = Provider<List<CartItem>>((ref) {
  return ref.watch(cartViewModelProvider).valueOrNull ?? const <CartItem>[];
});

final selectedCartItemsProvider = Provider<List<CartItem>>((ref) {
  final items = ref.watch(cartItemsProvider);
  final selectedIds = ref.watch(selectedCartItemIdsProvider);
  if (selectedIds.isEmpty) {
    return items;
  }
  return items
      .where((item) => selectedIds.contains(item.product.id))
      .toList(growable: false);
});

final cartClearProvider = Provider<void Function()>((ref) {
  return () => ref.read(cartViewModelProvider.notifier).clear();
});

final selectedCartItemIdsProvider =
    StateNotifierProvider<CartSelectionViewModel, Set<String>>((ref) {
  return CartSelectionViewModel(ref);
});

final recommendedFilterProvider =
    StateProvider<RecommendedFilter>((ref) => RecommendedFilter.all);

final recommendedItemsProvider = Provider<List<RecommendedItem>>((ref) {
  const items = [
    RecommendedItem(
      id: 'rec_1',
      title: 'Soft Knit Tank',
      imageUrl:
          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=900&q=70',
      price: 6.59,
      rating: 4.7,
      soldCount: 12400,
      tags: ['hot', 'frequent'],
    ),
    RecommendedItem(
      id: 'rec_2',
      title: 'Relaxed Cargo Pants',
      imageUrl:
          'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&w=900&q=70',
      price: 14.99,
      rating: 4.4,
      soldCount: 8900,
      tags: ['frequent'],
    ),
    RecommendedItem(
      id: 'rec_3',
      title: 'Cityline Hoodie',
      imageUrl:
          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=900&q=70',
      price: 18.5,
      rating: 4.6,
      soldCount: 10300,
      tags: ['hot'],
    ),
    RecommendedItem(
      id: 'rec_4',
      title: 'Satin Slip Dress',
      imageUrl:
          'https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&w=900&q=70',
      price: 22.75,
      rating: 4.8,
      soldCount: 6400,
      tags: ['hot', 'frequent'],
    ),
  ];

  final filter = ref.watch(recommendedFilterProvider);
  switch (filter) {
    case RecommendedFilter.hotDeals:
      return [
        for (final item in items)
          if (item.tags.contains('hot')) item,
      ];
    case RecommendedFilter.frequentFavorites:
      return [
        for (final item in items)
          if (item.tags.contains('frequent')) item,
      ];
    case RecommendedFilter.all:
      return items;
  }
});

class CartViewModel extends StateNotifier<AsyncValue<List<CartItem>>> {
  static const int minQuantity = 1;
  static const int maxQuantity = 99;

  CartViewModel(this._ref) : super(const AsyncValue.loading()) {
    refresh();

    _ref.listen<String?>(currentUidProvider, (previous, next) {
      final prev = previous ?? '';
      final nextUid = next ?? '';
      if (prev.trim() == nextUid.trim()) return;
      refresh();
    });
  }

  final Ref _ref;

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _load();
  }

  Future<void> _load() async {
    try {
      final repo = _ref.read(cartRepositoryProvider);
      final productRepo = _ref.read(productRepositoryProvider);

      final lines = await repo.loadCartLines();
      if (lines.isEmpty) {
        state = const AsyncValue.data(<CartItem>[]);
        return;
      }

      final products = await productRepo.getProductsByIds(
        lines.map((l) => l.productId),
      );
      final byId = {for (final p in products) p.id: p};

      final items = lines
          .map((l) {
            final p =
                byId[l.productId] ??
                Product(
                  id: l.productId,
                  title: 'Unknown product',
                  brand: '',
                  price: 0,
                  currency: 'USD',
                  imageUrls: const <String>[],
                  description: '',
                  variants: const <Variant>[],
                );
            return CartItem(
              product: p,
              quantity: l.quantity,
              selectedColor: l.selectedColor,
              selectedSize: l.selectedSize,
            );
          })
          .toList(growable: false);

      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _persist() async {
    try {
      final repo = _ref.read(cartRepositoryProvider);
      final lines = (state.valueOrNull ?? const <CartItem>[])
          .map(
            (i) => CartLine(
              productId: i.product.id,
              quantity: i.quantity,
              selectedColor: i.selectedColor,
              selectedSize: i.selectedSize,
            ),
          )
          .toList(growable: false);
      await repo.saveCartLines(lines);
    } catch (_) {}
  }

  void add({
    required Product product,
    required String selectedColor,
    required String selectedSize,
  }) {
    final currentState = state.valueOrNull ?? const <CartItem>[];
    final existingIndex = currentState.indexWhere(
      (i) =>
          i.product.id == product.id &&
          i.selectedColor == selectedColor &&
          i.selectedSize == selectedSize,
    );

    if (existingIndex >= 0) {
      final updated = [...currentState];
      final current = updated[existingIndex];
      updated[existingIndex] = current.copyWith(quantity: current.quantity + 1);
      state = AsyncValue.data(updated);
      _persist();
      return;
    }

    state = AsyncValue.data([
      ...currentState,
      CartItem(
        product: product,
        quantity: 1,
        selectedColor: selectedColor,
        selectedSize: selectedSize,
      ),
    ]);
    _persist();
  }

  void removeAt(int index) {
    final currentState = state.valueOrNull ?? const <CartItem>[];
    if (index < 0 || index >= currentState.length) return;
    final updated = [...currentState]..removeAt(index);
    state = AsyncValue.data(updated);
    _persist();
  }

  void removeByProductIds(Set<String> ids) {
    if (ids.isEmpty) return;
    final currentState = state.valueOrNull ?? const <CartItem>[];
    state = AsyncValue.data(
      currentState.where((item) => !ids.contains(item.product.id)).toList(
            growable: false,
          ),
    );
    _persist();
  }

  void updateQuantity(int index, int quantity) {
    final clamped = quantity.clamp(minQuantity, maxQuantity);
    final currentState = state.valueOrNull ?? const <CartItem>[];
    if (index < 0 || index >= currentState.length) return;
    final updated = [...currentState];
    updated[index] = updated[index].copyWith(quantity: clamped);
    state = AsyncValue.data(updated);
    _persist();
  }

  void clear() {
    state = const AsyncValue.data(<CartItem>[]);
    _persist();
  }

  double get subtotal =>
      (state.valueOrNull ?? const <CartItem>[]).fold(0, (sum, item) => sum + item.total);
}

class CartSelectionViewModel extends StateNotifier<Set<String>> {
  CartSelectionViewModel(this._ref) : super(<String>{}) {
    _syncWithCart(_ref.read(cartItemsProvider));
    _ref.listen<List<CartItem>>(cartItemsProvider, (_, next) {
      _syncWithCart(next);
    });
  }

  final Ref _ref;
  Set<String> _knownIds = <String>{};
  bool _hasHydrated = false;

  void toggle(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  void selectAll(Iterable<String> ids) {
    state = {...ids};
  }

  void _syncWithCart(List<CartItem> items) {
    final ids = items.map((i) => i.product.id).toSet();
    if (ids.isEmpty) {
      state = <String>{};
      _knownIds = <String>{};
      _hasHydrated = true;
      return;
    }
    if (!_hasHydrated) {
      state = {...ids};
      _knownIds = ids;
      _hasHydrated = true;
      return;
    }
    final added = ids.difference(_knownIds);
    state = {
      ...state.intersection(ids),
      ...added,
    };
    _knownIds = ids;
  }
}
