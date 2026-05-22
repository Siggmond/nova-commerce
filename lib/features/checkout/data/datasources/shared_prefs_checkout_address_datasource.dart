import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:nova_commerce/features/checkout/domain/checkout_address_store.dart';

class SharedPrefsCheckoutAddressDataSource implements CheckoutAddressStore {
  static const _key = 'checkout_address_v1';

  @override
  Future<Map<String, String>?> loadAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;

    return decoded.map(
      (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
    );
  }

  @override
  Future<void> saveAddress(Map<String, String> payload) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(payload));
  }
}
