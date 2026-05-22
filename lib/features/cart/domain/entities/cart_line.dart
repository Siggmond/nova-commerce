class CartLine {
  const CartLine({
    required this.productId,
    required this.quantity,
    required this.selectedColor,
    required this.selectedSize,
  });

  final String productId;
  final int quantity;
  final String selectedColor;
  final String selectedSize;

  CartLine copyWith({int? quantity}) {
    return CartLine(
      productId: productId,
      quantity: quantity ?? this.quantity,
      selectedColor: selectedColor,
      selectedSize: selectedSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'selectedColor': selectedColor,
      'selectedSize': selectedSize,
    };
  }

  factory CartLine.fromJson(Map<String, dynamic> json) {
    return CartLine(
      productId: (json['productId'] as String?) ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      selectedColor: (json['selectedColor'] as String?) ?? '',
      selectedSize: (json['selectedSize'] as String?) ?? '',
    );
  }
}
