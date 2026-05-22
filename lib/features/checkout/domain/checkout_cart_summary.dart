import 'package:nova_commerce/features/cart/domain/entities/cart_item.dart';

class CheckoutCartSummary {
  const CheckoutCartSummary({
    required this.currency,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.hasItems,
    required this.items,
  });

  const CheckoutCartSummary.empty()
    : currency = 'USD',
      subtotal = 0,
      shippingFee = 0,
      total = 0,
      hasItems = false,
      items = const <CartItem>[];

  final String currency;
  final double subtotal;
  final double shippingFee;
  final double total;
  final bool hasItems;
  final List<CartItem> items;
}
