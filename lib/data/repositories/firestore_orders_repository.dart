import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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

    if (!kReleaseMode) {
      debugPrint(
        'FirestoreOrdersRepository.watchOrders uid=${uid.trim()} path=orders where uid==${uid.trim()}',
      );
    }

    final orders = _db.collection('orders');
    final q = orders.where('uid', isEqualTo: uid.trim());

    return q
        .limit(50)
        .snapshots()
        .handleError((Object e, StackTrace st) {
          if (!kReleaseMode) {
            final code = e is FirebaseException ? e.code : null;
            debugPrint(
              'FirestoreOrdersRepository.watchOrders error code=$code error=$e',
            );
          }
          throw e;
        })
        .map((snap) {
          final list = snap.docs
              .map(OrderDto.fromDoc)
              .map(OrderMapper.toDomain)
              .toList(growable: true);

          list.sort((a, b) {
            final at = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bt = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bt.compareTo(at);
          });

          return list;
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
