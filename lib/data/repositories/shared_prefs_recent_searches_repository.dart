import '../../domain/repositories/recent_searches_repository.dart';
import '../datasources/shared_prefs_recent_searches_datasource.dart';

class SharedPrefsRecentSearchesRepository implements RecentSearchesRepository {
  SharedPrefsRecentSearchesRepository(this._ds);

  final SharedPrefsRecentSearchesDataSource _ds;

  @override
  Future<List<String>> loadQueries() => _ds.loadQueries();

  @override
  Future<void> saveQueries(List<String> queries) => _ds.saveQueries(queries);
}
