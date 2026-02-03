import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../core/errors/checkout_exceptions.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/order_repository.dart';

class FirestoreOrderRepository implements OrderRepository {
  FirestoreOrderRepository(this._db);

  final FirebaseFirestore _db;

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
    if (uid.trim().isEmpty) {
      throw const CheckoutSignInRequiredException();
    }
    if (items.isEmpty) {
      throw const CheckoutCartEmptyException();
    }

    if (!kReleaseMode) {
      debugPrint(
        'FirestoreOrderRepository.placeOrder uid=${uid.trim()} deviceId=${deviceId.trim()} path=orders',
      );
    }

    return _db.runTransaction<String>((tx) async {
      final orderRef = _db.collection('orders').doc();

      // Firestore requires all transaction reads to happen before any writes.
      final byProductId = <String, List<CartItem>>{};
      for (final item in items) {
        byProductId.putIfAbsent(item.product.id, () => <CartItem>[]).add(item);
      }

      // READS FIRST
      final productRefs = <String, DocumentReference<Map<String, dynamic>>>{};
      final productSnaps = <String, DocumentSnapshot<Map<String, dynamic>>>{};
      for (final productId in byProductId.keys) {
        final ref = _db.collection('products').doc(productId);
        productRefs[productId] = ref;
        productSnaps[productId] = await tx.get(ref);
      }

      // Compute variant updates (pure in-memory) after reads.
      final updatesByProductId = <String, List<Map<String, dynamic>>>{};

      for (final entry in byProductId.entries) {
        final productId = entry.key;
        final snap = productSnaps[productId];
        final data = snap?.data();
        if (snap == null || !snap.exists || data == null) {
          throw const CheckoutOutOfStockException(
            'A product is no longer available.',
          );
        }

        final title = (data['title'] as String?) ?? 'Product';
        final variantsRaw = data['variants'];
        if (variantsRaw is! List) {
          throw CheckoutOutOfStockException(
            '$title is not available in the selected variant.',
          );
        }

        final variants = variantsRaw
            .whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m.cast<String, dynamic>()))
            .toList(growable: false);

        final updated = variants
            .map((v) => Map<String, dynamic>.from(v))
            .toList(growable: false);

        for (final item in entry.value) {
          final color = item.selectedColor.trim();
          final size = item.selectedSize.trim();
          final qty = item.quantity;

          final idx = updated.indexWhere((v) {
            final c = (v['color'] as String?) ?? '';
            final s = (v['size'] as String?) ?? '';
            return c.trim() == color && s.trim() == size;
          });

          if (idx < 0) {
            throw CheckoutOutOfStockException(
              '$title ($color • $size) is no longer available.',
            );
          }

          final currentStock = (updated[idx]['stock'] as num?)?.toInt() ?? 0;
          if (currentStock < qty) {
            throw CheckoutOutOfStockException(
              '$title ($color • $size) has only $currentStock left.',
            );
          }

          updated[idx]['stock'] = currentStock - qty;
        }

        updatesByProductId[productId] = updated;
      }

      // WRITES AFTER ALL READS
      for (final entry in updatesByProductId.entries) {
        final productId = entry.key;
        final productRef = productRefs[productId];
        if (productRef == null) continue;
        tx.update(productRef, {
          'variants': entry.value,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      final payload = {
        'uid': uid,
        'deviceId': deviceId,
        'status': 'placed',
        'currency': currency,
        'subtotal': subtotal,
        'shippingFee': shippingFee,
        'total': total,
        'shipping': {
          'fullName': shipping['fullName'] ?? '',
          'phone': shipping['phone'] ?? '',
          'address': shipping['address'] ?? '',
          'city': shipping['city'] ?? '',
          'country': shipping['country'] ?? '',
        },
        'items': items
            .map(
              (i) => {
                'productId': i.product.id,
                'title': i.product.title,
                'price': i.product.price,
                'quantity': i.quantity,
                'selectedColor': i.selectedColor,
                'selectedSize': i.selectedSize,
              },
            )
            .toList(growable: false),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      tx.set(orderRef, payload);

      if (!kReleaseMode) {
        debugPrint(
          'FirestoreOrderRepository.placeOrder created orderId=${orderRef.id}',
        );
      }

      return orderRef.id;
    });
  }
}
