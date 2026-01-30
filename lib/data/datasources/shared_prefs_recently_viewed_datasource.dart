import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsRecentlyViewedDataSource {
  static const _key = 'recently_viewed_ids_v1';

  Future<List<String>> loadIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? const <String>[];
    return list;
  }

  Future<void> saveIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids);
  }
}
