import '../../domain/repositories/gold_repository.dart';
import '../datasources/shared_prefs_gold_datasource.dart';

class SharedPrefsGoldRepository implements GoldRepository {
  SharedPrefsGoldRepository(this._ds);

  final SharedPrefsGoldDataSource _ds;

  @override
  Stream<int> watchGoldBalance() async* {
    yield await getGoldBalance();
  }

  @override
  Future<int> getGoldBalance() {
    return _ds.loadBalance();
  }

  @override
  Future<int> awardGoldForOrder({
    required String orderId,
    required int goldEarned,
  }) async {
    final trimmedOrderId = orderId.trim();
    if (trimmedOrderId.isEmpty) return getGoldBalance();
    if (goldEarned <= 0) return getGoldBalance();

    final credited = await _ds.loadCreditedOrderIds();
    if (credited.contains(trimmedOrderId)) {
      return getGoldBalance();
    }

    final current = await _ds.loadBalance();
    final next = current + goldEarned;

    credited.add(trimmedOrderId);
    await _ds.saveCreditedOrderIds(credited);
    await _ds.saveBalance(next);

    return next;
  }
}
