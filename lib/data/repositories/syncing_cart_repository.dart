import '../../domain/entities/cart_line.dart';
import '../../domain/repositories/cart_repository.dart';

class SyncingCartRepository implements CartRepository {
  SyncingCartRepository({
    required CartRepository local,
    required CartRepository remote,
  }) : _local = local,
       _remote = remote;

  final CartRepository _local;
  final CartRepository _remote;

  @override
  Future<List<CartLine>> loadCartLines() async {
    final localLines = await _local.loadCartLines();

    try {
      final remoteLines = await _remote.loadCartLines();
      if (remoteLines.isEmpty && localLines.isNotEmpty) {
        await _remote.saveCartLines(localLines);
        return localLines;
      }

      if (remoteLines.isNotEmpty && localLines.isEmpty) {
        await _local.saveCartLines(remoteLines);
        return remoteLines;
      }

      if (remoteLines.isNotEmpty && localLines.isNotEmpty) {
        final merged = _merge(localLines: localLines, remoteLines: remoteLines);
        await _remote.saveCartLines(merged);
        await _local.saveCartLines(merged);
        return merged;
      }
    } catch (_) {}

    return localLines;
  }

  List<CartLine> _merge({
    required List<CartLine> localLines,
    required List<CartLine> remoteLines,
  }) {
    final byKey = <String, CartLine>{};

    void add(CartLine l) {
      final key = '${l.productId}::${l.selectedColor}::${l.selectedSize}';
      final existing = byKey[key];
      if (existing == null) {
        byKey[key] = l;
        return;
      }
      byKey[key] = existing.copyWith(quantity: existing.quantity + l.quantity);
    }

    for (final l in remoteLines) {
      if (l.productId.isEmpty || l.quantity <= 0) continue;
      add(l);
    }
    for (final l in localLines) {
      if (l.productId.isEmpty || l.quantity <= 0) continue;
      add(l);
    }

    return byKey.values.where((l) => l.quantity > 0).toList(growable: false);
  }

  @override
  Future<void> saveCartLines(List<CartLine> items) async {
    await _local.saveCartLines(items);
    try {
      await _remote.saveCartLines(items);
    } catch (_) {}
  }
}
