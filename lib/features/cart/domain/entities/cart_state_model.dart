import 'package:nova_commerce/core/domain/entities/product.dart';
import 'package:nova_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:nova_commerce/features/cart/domain/entities/cart_line.dart';

class CartKey {
  const CartKey({required this.productId, required this.variantId});

  final String productId;
  final String variantId;

  static CartKey fromLine(CartLine line) {
    return CartKey(
      productId: line.productId.trim(),
      variantId: variantIdFor(
        selectedColor: line.selectedColor,
        selectedSize: line.selectedSize,
      ),
    );
  }

  static CartKey fromSelection({
    required String productId,
    required String selectedColor,
    required String selectedSize,
  }) {
    return CartKey(
      productId: productId.trim(),
      variantId: variantIdFor(
        selectedColor: selectedColor,
        selectedSize: selectedSize,
      ),
    );
  }

  static String variantIdFor({
    required String selectedColor,
    required String selectedSize,
  }) {
    return '${selectedColor.trim()}::${selectedSize.trim()}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartKey &&
        other.productId == productId &&
        other.variantId == variantId;
  }

  @override
  int get hashCode => Object.hash(productId, variantId);
}

class CartTotals {
  const CartTotals({
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
  });

  static const CartTotals zero = CartTotals(
    subtotal: 0,
    discount: 0,
    tax: 0,
    total: 0,
  );

  final double subtotal;
  final double discount;
  final double tax;
  final double total;
}

class CartState {
  const CartState({
    required this.linesByKey,
    required this.orderedKeys,
    required this.productsById,
    required this.itemsByKey,
    required this.totals,
    required this.totalQuantity,
  });

  final Map<CartKey, CartLine> linesByKey;
  final List<CartKey> orderedKeys;
  final Map<String, Product> productsById;
  final Map<CartKey, CartItem> itemsByKey;
  final CartTotals totals;
  final int totalQuantity;

  factory CartState.empty({
    Map<String, Product> productsById = const <String, Product>{},
  }) {
    return CartState(
      linesByKey: const <CartKey, CartLine>{},
      orderedKeys: const <CartKey>[],
      productsById: productsById,
      itemsByKey: const <CartKey, CartItem>{},
      totals: CartTotals.zero,
      totalQuantity: 0,
    );
  }

  bool get isEmpty => orderedKeys.isEmpty;

  List<CartItem> get itemsOrdered {
    if (orderedKeys.isEmpty) return const <CartItem>[];
    final ordered = <CartItem>[];
    for (final key in orderedKeys) {
      final item = itemsByKey[key];
      if (item == null) continue;
      ordered.add(item);
    }
    return ordered;
  }

  CartLine? lineForKey(CartKey key) => linesByKey[key];

  CartItem? itemForKey(CartKey key) => itemsByKey[key];

  List<CartLine> toPersistedLines() {
    if (orderedKeys.isEmpty) return const <CartLine>[];
    final lines = <CartLine>[];
    for (final key in orderedKeys) {
      final line = linesByKey[key];
      if (line == null || line.quantity <= 0) continue;
      lines.add(line);
    }
    return lines;
  }
}
