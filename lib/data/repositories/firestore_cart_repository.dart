import '../../domain/entities/cart_line.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/device_id_datasource.dart';
import '../datasources/firestore_cart_datasource.dart';

class FirestoreCartRepository implements CartRepository {
  FirestoreCartRepository(this._cartDs, this._deviceIdDs);

  final FirestoreCartDataSource _cartDs;
  final DeviceIdDataSource _deviceIdDs;

  @override
  Future<List<CartLine>> loadCartLines() async {
    final cartId = await _deviceIdDs.getOrCreate();
    final doc = await _cartDs.loadCart(cartId);
    final data = doc.data();
    if (data == null) return const [];

    final items = data['items'];
    if (items is! List) return const [];

    return items
        .whereType<Map>()
        .map((m) => CartLine.fromJson(m.cast<String, dynamic>()))
        .where((l) => l.productId.isNotEmpty && l.quantity > 0)
        .toList(growable: false);
  }

  @override
  Future<void> saveCartLines(List<CartLine> items) async {
    final cartId = await _deviceIdDs.getOrCreate();
    final payload = {
      'deviceId': cartId,
      'items': items.map((e) => e.toJson()).toList(growable: false),
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
    await _cartDs.saveCart(cartId, payload);
  }
}
