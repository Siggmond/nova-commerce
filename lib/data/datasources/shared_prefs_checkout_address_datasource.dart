import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsCheckoutAddressDataSource {
  static const _key = 'checkout_address_v1';

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

  Future<void> saveAddress(Map<String, String> payload) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(payload));
  }
}
