import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/order.dart' as domain;
import '../../domain/repositories/orders_repository.dart';
import '../../features/orders/data/dto/order_dto.dart';
import '../../features/orders/data/mappers/order_mapper.dart';

class FirestoreOrdersRepository implements OrdersRepository {
  FirestoreOrdersRepository(this._db);

  final FirebaseFirestore _db;

  @override
  Stream<List<domain.Order>> watchOrders({
    required String? uid,
    required String deviceId,
  }) {
    if (uid == null || uid.trim().isEmpty) {
      return const Stream<List<domain.Order>>.empty();
    }

    final orders = _db.collection('orders');
    final q = orders.where('uid', isEqualTo: uid.trim());

    return q.orderBy('createdAt', descending: true).limit(50).snapshots().map((
      snap,
    ) {
      return snap.docs
          .map(OrderDto.fromDoc)
          .map(OrderMapper.toDomain)
          .toList(growable: false);
    });
  }

  @override
  Future<domain.Order> fetchOrderById(String id) async {
    final doc = await _db.collection('orders').doc(id).get();
    if (!doc.exists) {
      throw StateError('Order not found.');
    }

    return OrderMapper.toDomain(OrderDto.fromDoc(doc));
  }
}
