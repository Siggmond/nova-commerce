import 'order_item.dart';
import 'order_status.dart';

class Order {
  const Order({
    required this.id,
    required this.uid,
    required this.deviceId,
    required this.status,
    required this.statusRaw,
    required this.currency,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.shipping,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String uid;
  final String deviceId;
  final OrderStatus status;
  final String statusRaw;
  final String currency;
  final double subtotal;
  final double shippingFee;
  final double total;
  final Map<String, dynamic> shipping;
  final List<OrderItem> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
