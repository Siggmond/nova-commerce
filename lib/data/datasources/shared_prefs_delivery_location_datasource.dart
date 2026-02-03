import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsDeliveryLocationDataSource {
  static const _key = 'delivery_location_city_v1';

  Future<String?> loadCity() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_key);
    if (v == null) return null;
    final trimmed = v.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }

  Future<void> saveCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, city);
  }
}
