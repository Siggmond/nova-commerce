import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsRecentSearchesDataSource {
  static const _key = 'recent_searches_v1';

  Future<List<String>> loadQueries() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? const <String>[];
  }

  Future<void> saveQueries(List<String> queries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, queries);
  }
}
