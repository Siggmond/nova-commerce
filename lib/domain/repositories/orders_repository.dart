import '../entities/order.dart';

abstract class OrdersRepository {
  Stream<List<Order>> watchOrders({
    required String? uid,
    required String deviceId,
  });

  Future<Order> fetchOrderById(String id);
}
