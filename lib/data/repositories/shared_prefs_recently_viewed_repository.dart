import '../../domain/repositories/recently_viewed_repository.dart';
import '../datasources/shared_prefs_recently_viewed_datasource.dart';

class SharedPrefsRecentlyViewedRepository implements RecentlyViewedRepository {
  SharedPrefsRecentlyViewedRepository(this._ds);

  final SharedPrefsRecentlyViewedDataSource _ds;

  @override
  Future<List<String>> loadIds() => _ds.loadIds();

  @override
  Future<void> saveIds(List<String> ids) => _ds.saveIds(ids);
}
