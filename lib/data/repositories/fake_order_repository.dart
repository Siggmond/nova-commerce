import '../../core/errors/checkout_exceptions.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/order_repository.dart';

class FakeOrderRepository implements OrderRepository {
  @override
  Future<String> placeOrder({
    required String uid,
    required String deviceId,
    required List<CartItem> items,
    required Map<String, String> shipping,
    required double subtotal,
    required double shippingFee,
    required double total,
    required String currency,
  }) async {
    if (items.isEmpty) {
      throw const CheckoutCartEmptyException();
    }
    if (uid.trim().isEmpty) {
      throw const CheckoutSignInRequiredException();
    }
    return 'demo_${DateTime.now().millisecondsSinceEpoch}';
  }
}
