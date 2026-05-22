import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsGoldDataSource {
  static const _balanceKey = 'gold_balance';
  static const _creditedOrdersKey = 'gold_credited_orders';

  Future<int> loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_balanceKey) ?? 0;
  }

  Future<void> saveBalance(int balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_balanceKey, balance);
  }

  Future<Set<String>> loadCreditedOrderIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_creditedOrdersKey) ?? const <String>[];
    return list.toSet();
  }

  Future<void> saveCreditedOrderIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_creditedOrdersKey, ids.toList());
  }
}
