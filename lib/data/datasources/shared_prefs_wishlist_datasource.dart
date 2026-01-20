import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsWishlistDataSource {
  static const _key = 'wishlist_ids_v1';

  Future<Set<String>> loadIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? const <String>[];
    return list.toSet();
  }

  Future<void> saveIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final sorted = ids.toList()..sort();
    await prefs.setStringList(_key, sorted);
  }
}
