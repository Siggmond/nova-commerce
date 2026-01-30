import 'package:cloud_firestore/cloud_firestore.dart';

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

    return _db.runTransaction<String>((tx) async {
      final orderRef = _db.collection('orders').doc();

      final byProductId = <String, List<CartItem>>{};
      for (final item in items) {
        byProductId.putIfAbsent(item.product.id, () => <CartItem>[]).add(item);
      }

      for (final entry in byProductId.entries) {
        final productId = entry.key;
        final productRef = _db.collection('products').doc(productId);
        final snap = await tx.get(productRef);
        final data = snap.data();
        if (!snap.exists || data == null) {
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

        tx.update(productRef, {
          'variants': updated,
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

      return orderRef.id;
    });
  }
}
