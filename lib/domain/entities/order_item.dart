class OrderItem {
  const OrderItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
    required this.selectedColor,
    required this.selectedSize,
  });

  final String productId;
  final String title;
  final double price;
  final int quantity;
  final String selectedColor;
  final String selectedSize;

  double get total => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: (json['productId'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      selectedColor: (json['selectedColor'] as String?) ?? '',
      selectedSize: (json['selectedSize'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'quantity': quantity,
      'selectedColor': selectedColor,
      'selectedSize': selectedSize,
    };
  }
}
