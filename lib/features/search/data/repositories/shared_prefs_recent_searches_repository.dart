import 'package:nova_commerce/features/search/data/datasources/shared_prefs_recent_searches_datasource.dart';
import 'package:nova_commerce/features/search/domain/repositories/recent_searches_repository.dart';

class SharedPrefsRecentSearchesRepository implements RecentSearchesRepository {
  SharedPrefsRecentSearchesRepository(this._ds);

  final SharedPrefsRecentSearchesDataSource _ds;

  @override
  Future<List<String>> loadQueries() => _ds.loadQueries();

  @override
  Future<void> saveQueries(List<String> queries) => _ds.saveQueries(queries);
}
