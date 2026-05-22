import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nova_commerce/app/di/app_providers.dart';
import 'package:nova_commerce/core/domain/entities/product.dart';
import 'package:nova_commerce/core/domain/entities/variant.dart';
import 'package:nova_commerce/core/perf/perf_markers.dart';
import 'package:nova_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:nova_commerce/features/cart/domain/entities/cart_line.dart';
import 'package:nova_commerce/features/cart/domain/entities/cart_state_model.dart';
import 'package:nova_commerce/features/cart/domain/entities/recommended_item.dart';
import 'package:nova_commerce/features/cart/domain/usecases/recalculate_cart_totals_use_case.dart';

final cartViewModelProvider =
    StateNotifierProvider<CartViewModel, AsyncValue<CartState>>((ref) {
      return CartViewModel(ref);
    });

enum CartLoadStatus { loading, error, ready }

final cartLoadStatusProvider = Provider<CartLoadStatus>((ref) {
  final state = ref.watch(cartViewModelProvider);
  if (state.isLoading) return CartLoadStatus.loading;
  if (state.hasError) return CartLoadStatus.error;
  return CartLoadStatus.ready;
});

final cartLoadErrorProvider = Provider<Object?>((ref) {
  final state = ref.watch(cartViewModelProvider);
  return state.asError?.error;
});

final cartStateProvider = Provider<CartState>((ref) {
  return ref.watch(cartViewModelProvider).valueOrNull ?? CartState.empty();
});

final cartOrderProvider = Provider<List<CartKey>>((ref) {
  return ref.watch(cartStateProvider.select((state) => state.orderedKeys));
});

final cartItemsProvider = Provider<List<CartItem>>((ref) {
  return ref.watch(cartStateProvider.select((state) => state.itemsOrdered));
});

final cartItemByKeyProvider = Provider.family<CartItem?, CartKey>((ref, key) {
  return ref.watch(cartStateProvider.select((state) => state.itemForKey(key)));
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartStateProvider.select((state) => state.totalQuantity));
});

final cartSubtotalProvider = Provider<double>((ref) {
  return ref.watch(cartStateProvider.select((state) => state.totals.subtotal));
});

final cartTotalsProvider = Provider<CartTotals>((ref) {
  return ref.watch(cartStateProvider.select((state) => state.totals));
});

final cartCurrencyProvider = Provider<String>((ref) {
  return ref.watch(
    cartItemsProvider.select(
      (items) => items.isNotEmpty ? items.first.product.currency : 'USD',
    ),
  );
});

final selectedCartItemsProvider = Provider<List<CartItem>>((ref) {
  final state = ref.watch(cartStateProvider);
  if (state.isEmpty) return const <CartItem>[];
  final selectedIds = ref.watch(selectedCartItemIdsProvider);
  if (selectedIds.isEmpty) {
    return state.itemsOrdered;
  }

  final selected = <CartItem>[];
  for (final key in state.orderedKeys) {
    if (!selectedIds.contains(key.productId)) continue;
    final item = state.itemForKey(key);
    if (item != null) {
      selected.add(item);
    }
  }
  return selected;
});

final selectedCartSubtotalProvider = Provider<double>((ref) {
  final items = ref.watch(selectedCartItemsProvider);
  return items.fold<double>(0, (sum, item) => sum + item.total);
});

class CartSelectionSummary {
  const CartSelectionSummary({
    required this.totalCount,
    required this.selectedCount,
  });

  final int totalCount;
  final int selectedCount;

  bool get hasSelection => selectedCount > 0;
  bool get allSelected => totalCount > 0 && selectedCount == totalCount;
}

final cartSelectionSummaryProvider = Provider<CartSelectionSummary>((ref) {
  final totalCount = ref.watch(cartOrderProvider.select((keys) => keys.length));
  final selectedCount = ref.watch(
    selectedCartItemIdsProvider.select((ids) => ids.length),
  );
  final clampedSelected = selectedCount > totalCount
      ? totalCount
      : selectedCount;
  return CartSelectionSummary(
    totalCount: totalCount,
    selectedCount: clampedSelected,
  );
});

final cartClearProvider = Provider<void Function()>((ref) {
  return () => ref.read(cartViewModelProvider.notifier).clear();
});

final selectedCartItemIdsProvider =
    StateNotifierProvider<CartSelectionViewModel, Set<String>>((ref) {
      return CartSelectionViewModel(ref);
    });

final recommendedFilterProvider = StateProvider<RecommendedFilter>(
  (ref) => RecommendedFilter.all,
);

final recommendedItemsProvider = Provider<List<RecommendedItem>>((ref) {
  const items = [
    RecommendedItem(
      id: 'rec_1',
      title: 'Soft Knit Tank',
      imageUrl: 'https://picsum.photos/seed/soft-knit-tank/800/1000',
      price: 6.59,
      rating: 4.7,
      soldCount: 12400,
      tags: ['hot', 'frequent'],
    ),
    RecommendedItem(
      id: 'rec_2',
      title: 'Relaxed Cargo Pants',
      imageUrl: 'https://picsum.photos/seed/relaxed-cargo-pants/800/1000',
      price: 14.99,
      rating: 4.4,
      soldCount: 8900,
      tags: ['frequent'],
    ),
    RecommendedItem(
      id: 'rec_3',
      title: 'Cityline Hoodie',
      imageUrl: 'https://picsum.photos/seed/cityline-hoodie/800/1000',
      price: 18.5,
      rating: 4.6,
      soldCount: 10300,
      tags: ['hot'],
    ),
    RecommendedItem(
      id: 'rec_4',
      title: 'Satin Slip Dress',
      imageUrl: 'https://picsum.photos/seed/satin-slip-dress/800/1000',
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

class CartViewModel extends StateNotifier<AsyncValue<CartState>> {
  static const int minQuantity = 1;
  static const int maxQuantity = 99;
  static const Duration _persistDebounce = Duration(milliseconds: 220);

  CartViewModel(
    this._ref, {
    RecalculateCartTotalsUseCase recalculateCartTotalsUseCase =
        const RecalculateCartTotalsUseCase(),
  }) : _recalculateCartTotalsUseCase = recalculateCartTotalsUseCase,
       super(const AsyncValue.loading()) {
    refresh();

    _ref.listen<String?>(currentUidProvider, (previous, next) {
      final prev = previous ?? '';
      final nextUid = next ?? '';
      if (prev.trim() == nextUid.trim()) return;
      refresh();
    });
  }

  final Ref _ref;
  final RecalculateCartTotalsUseCase _recalculateCartTotalsUseCase;
  Timer? _persistDebounceTimer;
  bool _persistQueued = false;
  bool _persistInFlight = false;

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
        state = AsyncValue.data(CartState.empty());
        return;
      }

      final products = await productRepo.getProductsByIds(
        lines.map((l) => l.productId),
      );
      final productsById = <String, Product>{
        for (final product in products) product.id: product,
      };

      var nextState = CartState.empty(productsById: productsById);
      for (final line in lines) {
        final productId = line.productId.trim();
        if (productId.isEmpty || line.quantity <= 0) continue;
        final resolvedProduct =
            productsById[productId] ?? _unknownProduct(productId);
        nextState = _recalculateCartTotalsUseCase(
          previous: nextState,
          action: AddCartAction(
            line: line,
            product: resolvedProduct,
            quantityDelta: line.quantity,
          ),
        );
      }

      state = AsyncValue.data(nextState);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void _schedulePersist() {
    _persistQueued = true;
    _persistDebounceTimer?.cancel();
    _persistDebounceTimer = Timer(_persistDebounce, () {
      unawaited(_flushPersist());
    });
  }

  Future<void> _flushPersist() async {
    if (_persistInFlight || !_persistQueued) return;

    _persistQueued = false;
    _persistInFlight = true;
    try {
      final repo = _ref.read(cartRepositoryProvider);
      final cartState = state.valueOrNull ?? CartState.empty();
      await repo.saveCartLines(cartState.toPersistedLines());
    } catch (_) {
      // Ignore persistence failures to keep cart interactions responsive.
    } finally {
      _persistInFlight = false;
      if (_persistQueued) {
        _persistDebounceTimer?.cancel();
        _persistDebounceTimer = Timer(_persistDebounce, () {
          unawaited(_flushPersist());
        });
      }
    }
  }

  void add({
    required Product product,
    required String selectedColor,
    required String selectedSize,
  }) {
    final line = CartLine(
      productId: product.id,
      quantity: 1,
      selectedColor: selectedColor,
      selectedSize: selectedSize,
    );
    _applyAction(AddCartAction(line: line, product: product));
  }

  void removeAt(int index) {
    final currentState = state.valueOrNull ?? CartState.empty();
    if (index < 0 || index >= currentState.orderedKeys.length) return;
    removeByKey(currentState.orderedKeys[index]);
  }

  void removeByKey(CartKey key) {
    _applyAction(RemoveCartAction(key: key));
  }

  void removeByProductIds(Set<String> ids) {
    if (ids.isEmpty) return;

    final currentState = state.valueOrNull ?? CartState.empty();
    var nextState = currentState;
    var changed = false;

    PerfMarkers.cartUpdateStart();
    for (final key in currentState.orderedKeys) {
      if (!ids.contains(key.productId)) continue;
      nextState = _recalculateCartTotalsUseCase(
        previous: nextState,
        action: RemoveCartAction(key: key),
      );
      changed = true;
    }
    PerfMarkers.cartUpdateEnd();

    if (!changed) return;
    state = AsyncValue.data(nextState);
    _schedulePersist();
  }

  void updateQuantity(int index, int quantity) {
    final currentState = state.valueOrNull ?? CartState.empty();
    if (index < 0 || index >= currentState.orderedKeys.length) return;
    updateQuantityByKey(currentState.orderedKeys[index], quantity);
  }

  void updateQuantityByKey(CartKey key, int quantity) {
    final clamped = quantity.clamp(minQuantity, maxQuantity);
    _applyAction(UpdateCartQuantityAction(key: key, quantity: clamped));
  }

  void clear() {
    final current = state.valueOrNull ?? CartState.empty();
    final next = CartState.empty(productsById: current.productsById);
    PerfMarkers.cartUpdateStart();
    state = AsyncValue.data(next);
    PerfMarkers.cartUpdateEnd();
    _schedulePersist();
  }

  void _applyAction(CartAction action) {
    final currentState = state.valueOrNull ?? CartState.empty();
    PerfMarkers.cartUpdateStart();
    final nextState = _recalculateCartTotalsUseCase(
      previous: currentState,
      action: action,
    );
    state = AsyncValue.data(nextState);
    PerfMarkers.cartUpdateEnd();
    _schedulePersist();
  }

  double get subtotal =>
      (state.valueOrNull ?? CartState.empty()).totals.subtotal;

  Product _unknownProduct(String id) {
    return Product(
      id: id,
      title: 'Unknown product',
      brand: '',
      price: 0,
      currency: 'USD',
      imageUrls: const <String>[],
      description: '',
      variants: const <Variant>[],
    );
  }

  @override
  void dispose() {
    _persistDebounceTimer?.cancel();
    if (_persistQueued && !_persistInFlight) {
      unawaited(_flushPersist());
    }
    super.dispose();
  }
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
    state = {...state.intersection(ids), ...added};
    _knownIds = ids;
  }
}
