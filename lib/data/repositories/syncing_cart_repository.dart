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
      if (remoteLines.isNotEmpty) {
        await _local.saveCartLines(remoteLines);
        return remoteLines;
      }

      if (localLines.isNotEmpty) {
        await _remote.saveCartLines(localLines);
      }
    } catch (_) {}

    return localLines;
  }

  @override
  Future<void> saveCartLines(List<CartLine> items) async {
    await _local.saveCartLines(items);
    try {
      await _remote.saveCartLines(items);
    } catch (_) {}
  }
}
