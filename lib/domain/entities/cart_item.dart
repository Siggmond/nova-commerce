import 'product.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.quantity,
    required this.selectedColor,
    required this.selectedSize,
  });

  final Product product;
  final int quantity;
  final String selectedColor;
  final String selectedSize;

  double get total => product.price * quantity;

  CartItem copyWith({
    int? quantity,
    String? selectedColor,
    String? selectedSize,
  }) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
    );
  }
}
