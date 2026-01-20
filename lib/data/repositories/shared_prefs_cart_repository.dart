import '../../domain/entities/cart_line.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/shared_prefs_cart_datasource.dart';

class SharedPrefsCartRepository implements CartRepository {
  SharedPrefsCartRepository(this._ds);

  final SharedPrefsCartDataSource _ds;

  @override
  Future<List<CartLine>> loadCartLines() => _ds.loadCartLines();

  @override
  Future<void> saveCartLines(List<CartLine> items) => _ds.saveCartLines(items);
}
