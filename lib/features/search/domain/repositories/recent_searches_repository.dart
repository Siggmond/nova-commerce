abstract class RecentSearchesRepository {
  Future<List<String>> loadQueries();
  Future<void> saveQueries(List<String> queries);
}
