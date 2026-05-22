import 'package:nova_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:nova_commerce/features/checkout/domain/checkout_cart_summary.dart';

class BuildCheckoutSummaryUseCase {
  const BuildCheckoutSummaryUseCase();

  CheckoutCartSummary call(
    List<CartItem> items, {
    double shippingFee = 0,
    double taxAmount = 0,
    double discountAmount = 0,
  }) {
    final currency = items.isNotEmpty ? items.first.product.currency : 'USD';
    final subtotal = items.fold<double>(0, (acc, item) => acc + item.total);
    final total = (subtotal + shippingFee + taxAmount - discountAmount)
        .clamp(0, double.infinity)
        .toDouble();

    return CheckoutCartSummary(
      currency: currency,
      subtotal: subtotal,
      shippingFee: shippingFee,
      total: total,
      hasItems: items.isNotEmpty,
      items: items,
    );
  }
}
