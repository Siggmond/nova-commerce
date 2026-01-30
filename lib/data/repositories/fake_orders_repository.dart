import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';

class FakeOrdersRepository implements OrdersRepository {
  @override
  Future<Order> fetchOrderById(String id) {
    throw StateError('Order not found.');
  }

  @override
  Stream<List<Order>> watchOrders({
    required String? uid,
    required String deviceId,
  }) {
    return const Stream<List<Order>>.empty();
  }
}
