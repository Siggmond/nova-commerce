abstract class RecentlyViewedRepository {
  Future<List<String>> loadIds();
  Future<void> saveIds(List<String> ids);
}
