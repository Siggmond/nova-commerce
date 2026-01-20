import 'package:cloud_firestore/cloud_firestore.dart';

import 'order_item.dart';

class Order {
  const Order({
    required this.id,
    required this.uid,
    required this.deviceId,
    required this.status,
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
  final String status;
  final String currency;
  final double subtotal;
  final double shippingFee;
  final double total;
  final Map<String, dynamic> shipping;
  final List<OrderItem> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Order.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Order.fromJson(id: doc.id, json: data);
  }

  factory Order.fromJson({
    required String id,
    required Map<String, dynamic> json,
  }) {
    final rawItems = json['items'];
    final items = <OrderItem>[];
    if (rawItems is List) {
      for (final e in rawItems) {
        if (e is Map) {
          items.add(OrderItem.fromJson(e.cast<String, dynamic>()));
        }
      }
    }

    final createdAtRaw = json['createdAt'];
    DateTime? createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    }

    final updatedAtRaw = json['updatedAt'];
    DateTime? updatedAt;
    if (updatedAtRaw is Timestamp) {
      updatedAt = updatedAtRaw.toDate();
    }

    final shippingRaw = json['shipping'];

    return Order(
      id: id,
      uid: (json['uid'] as String?) ?? '',
      deviceId: (json['deviceId'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      currency: (json['currency'] as String?) ?? 'USD',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      shipping: shippingRaw is Map
          ? shippingRaw.cast<String, dynamic>()
          : const <String, dynamic>{},
      items: items,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
