import 'package:nova_commerce/core/domain/entities/product.dart';
import 'package:nova_commerce/features/cart/domain/entities/cart_item.dart';

class AddCartItemUseCase {
  const AddCartItemUseCase();

  List<CartItem> call({
    required List<CartItem> items,
    required Product product,
    required String selectedColor,
    required String selectedSize,
  }) {
    final existingIndex = items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedColor == selectedColor &&
          item.selectedSize == selectedSize,
    );

    if (existingIndex >= 0) {
      final updated = <CartItem>[...items];
      final existing = updated[existingIndex];
      updated[existingIndex] = existing.copyWith(
        quantity: existing.quantity + 1,
      );
      return updated;
    }

    return <CartItem>[
      ...items,
      CartItem(
        product: product,
        quantity: 1,
        selectedColor: selectedColor,
        selectedSize: selectedSize,
      ),
    ];
  }
}
