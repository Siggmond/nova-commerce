import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDto {
  const OrderDto({
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
  final List<Map<String, dynamic>> items;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  factory OrderDto.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return OrderDto.fromJson(id: doc.id, json: data);
  }

  factory OrderDto.fromJson({
    required String id,
    required Map<String, dynamic> json,
  }) {
    final rawItems = json['items'];
    final items = <Map<String, dynamic>>[];
    if (rawItems is List) {
      for (final e in rawItems) {
        if (e is Map) {
          items.add(e.cast<String, dynamic>());
        }
      }
    }

    final createdAtRaw = json['createdAt'];
    final updatedAtRaw = json['updatedAt'];

    final shippingRaw = json['shipping'];

    return OrderDto(
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
      createdAt: createdAtRaw is Timestamp ? createdAtRaw : null,
      updatedAt: updatedAtRaw is Timestamp ? updatedAtRaw : null,
    );
  }
}
