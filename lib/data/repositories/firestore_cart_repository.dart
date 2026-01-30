import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/cart_line.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/firestore_cart_datasource.dart';

class FirestoreCartRepository implements CartRepository {
  FirestoreCartRepository(this._cartDs, this._uid);

  final FirestoreCartDataSource _cartDs;
  final String _uid;

  @override
  Future<List<CartLine>> loadCartLines() async {
    final uid = _uid.trim();
    if (uid.isEmpty) return const [];
    final doc = await _cartDs.loadCart(uid);
    final data = doc.data();
    if (data == null) return const [];

    final items = data['items'];
    if (items is! List) return const [];

    return items
        .whereType<Map>()
        .map((m) => CartLine.fromJson(m.cast<String, dynamic>()))
        .where(
          (l) =>
              l.productId.isNotEmpty &&
              l.quantity > 0 &&
              l.selectedColor.trim().isNotEmpty &&
              l.selectedSize.trim().isNotEmpty,
        )
        .toList(growable: false);
  }

  @override
  Future<void> saveCartLines(List<CartLine> items) async {
    final uid = _uid.trim();
    if (uid.isEmpty) return;

    final sanitized = items
        .where(
          (l) =>
              l.productId.trim().isNotEmpty &&
              l.quantity > 0 &&
              l.selectedColor.trim().isNotEmpty &&
              l.selectedSize.trim().isNotEmpty,
        )
        .toList(growable: false);
    final payload = {
      'uid': uid,
      'items': sanitized.map((e) => e.toJson()).toList(growable: false),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _cartDs.saveCart(uid, payload);
  }
}
