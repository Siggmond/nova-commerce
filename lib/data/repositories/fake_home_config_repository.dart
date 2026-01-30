import '../../domain/repositories/home_config_repository.dart';

class FakeHomeConfigRepository implements HomeConfigRepository {
  @override
  Stream<Map<String, dynamic>> watchHomeConfig() {
    return Stream<Map<String, dynamic>>.value(<String, dynamic>{});
  }
}
