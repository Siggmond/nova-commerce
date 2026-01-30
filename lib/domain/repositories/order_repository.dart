import '../entities/cart_item.dart';

abstract class OrderRepository {
  Future<String> placeOrder({
    required String uid,
    required String deviceId,
    required List<CartItem> items,
    required Map<String, String> shipping,
    required double subtotal,
    required double shippingFee,
    required double total,
    required String currency,
  });
}
