import '../../../domain/entities/cart_item.dart';

class CheckoutCartSummary {
  const CheckoutCartSummary({
    required this.currency,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.hasItems,
    required this.items,
  });

  final String currency;
  final double subtotal;
  final double shippingFee;
  final double total;
  final bool hasItems;
  final List<CartItem> items;
}
