import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../domain/entities/product.dart';

sealed class WishlistState {
  const WishlistState();

  const factory WishlistState.loading() = WishlistLoading;
  const factory WishlistState.data({
    required Set<String> ids,
    required List<Product> products,
  }) = WishlistData;
  const factory WishlistState.error(Object error) = WishlistError;

  T when<T>({
    required T Function() loading,
    required T Function(Set<String> ids, List<Product> products) data,
    required T Function(Object error) error,
  }) {
    final s = this;
    if (s is WishlistLoading) return loading();
    if (s is WishlistData) return data(s.ids, s.products);
    return error((s as WishlistError).error);
  }
}

class WishlistLoading extends WishlistState {
  const WishlistLoading();
}

class WishlistData extends WishlistState {
  const WishlistData({required this.ids, required this.products});

  final Set<String> ids;
  final List<Product> products;

  WishlistData copyWith({Set<String>? ids, List<Product>? products}) {
    return WishlistData(
      ids: ids ?? this.ids,
      products: products ?? this.products,
    );
  }
}

class WishlistError extends WishlistState {
  const WishlistError(this.error);

  final Object error;
}

final wishlistViewModelProvider =
    StateNotifierProvider<WishlistViewModel, WishlistState>((ref) {
      return WishlistViewModel(ref);
    });

final wishlistIdsProvider = Provider<Set<String>>((ref) {
  final state = ref.watch(wishlistViewModelProvider);
  return state.when(
    loading: () => <String>{},
    error: (_) => <String>{},
    data: (ids, _) => ids,
  );
});

class WishlistViewModel extends StateNotifier<WishlistState> {
  WishlistViewModel(this._ref) : super(const WishlistState.loading()) {
    refresh();
  }

  final Ref _ref;

  Future<void> refresh() async {
    state = const WishlistState.loading();
    try {
      final repo = _ref.read(wishlistRepositoryProvider);
      final productRepo = _ref.read(productRepositoryProvider);

      final ids = await repo.loadWishlistIds();
      if (ids.isEmpty) {
        state = WishlistState.data(ids: ids, products: const []);
        return;
      }

      final wantedOrder = ids.toList(growable: false);
      final byId = <String, Product>{
        for (final p in await productRepo.getProductsByIds(wantedOrder))
          p.id: p,
      };
      final products = <Product>[];
      for (final id in wantedOrder) {
        final p = byId[id];
        if (p != null) products.add(p);
      }

      state = WishlistState.data(ids: ids, products: products);
    } catch (e) {
      state = WishlistState.error(e);
    }
  }

  Future<void> toggle(String productId) async {
    final current = state;
    if (current is! WishlistData) {
      await refresh();
      return;
    }

    final ids = {...current.ids};
    final products = [...current.products];

    final wasIn = ids.contains(productId);

    if (wasIn) {
      ids.remove(productId);
      products.removeWhere((p) => p.id == productId);
    } else {
      ids.add(productId);
      final productRepo = _ref.read(productRepositoryProvider);
      final p = await productRepo.getProductById(productId);
      if (p != null) {
        products.insert(0, p);
      }
    }

    // optimistic update
    state = current.copyWith(ids: ids, products: products);

    try {
      final repo = _ref.read(wishlistRepositoryProvider);
      await repo.saveWishlistIds(ids);
    } catch (e) {
      // rollback on failure
      state = current;
    }
  }
}
