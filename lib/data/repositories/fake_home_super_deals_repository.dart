import '../../domain/repositories/home_super_deals_repository.dart';

class FakeHomeSuperDealsRepository implements HomeSuperDealsRepository {
  @override
  Future<List<String>> fetchSuperDealsProductIds() async {
    return const <String>[];
  }
}
