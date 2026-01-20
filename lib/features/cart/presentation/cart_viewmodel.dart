import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/cart_line.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/variant.dart';

final cartViewModelProvider =
    StateNotifierProvider<CartViewModel, List<CartItem>>((ref) {
      return CartViewModel(ref);
    });

class CartViewModel extends StateNotifier<List<CartItem>> {
  CartViewModel(this._ref) : super(const []) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    try {
      final repo = _ref.read(cartRepositoryProvider);
      final productRepo = _ref.read(productRepositoryProvider);

      final lines = await repo.loadCartLines();
      if (lines.isEmpty) {
        state = const [];
        return;
      }

      final products = await productRepo.getProductsByIds(
        lines.map((l) => l.productId),
      );
      final byId = {for (final p in products) p.id: p};

      state = lines
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
    } catch (_) {
      state = const [];
    }
  }

  Future<void> _persist() async {
    try {
      final repo = _ref.read(cartRepositoryProvider);
      final lines = state
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
    final existingIndex = state.indexWhere(
      (i) =>
          i.product.id == product.id &&
          i.selectedColor == selectedColor &&
          i.selectedSize == selectedSize,
    );

    if (existingIndex >= 0) {
      final updated = [...state];
      final current = updated[existingIndex];
      updated[existingIndex] = current.copyWith(quantity: current.quantity + 1);
      state = updated;
      _persist();
      return;
    }

    state = [
      ...state,
      CartItem(
        product: product,
        quantity: 1,
        selectedColor: selectedColor,
        selectedSize: selectedSize,
      ),
    ];
    _persist();
  }

  void removeAt(int index) {
    final updated = [...state]..removeAt(index);
    state = updated;
    _persist();
  }

  void updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      removeAt(index);
      return;
    }

    final updated = [...state];
    updated[index] = updated[index].copyWith(quantity: quantity);
    state = updated;
    _persist();
  }

  void clear() {
    state = const [];
    _persist();
  }

  double get subtotal => state.fold(0, (sum, item) => sum + item.total);
}
