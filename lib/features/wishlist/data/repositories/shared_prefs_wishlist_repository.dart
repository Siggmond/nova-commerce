import 'package:nova_commerce/features/wishlist/data/datasources/shared_prefs_wishlist_datasource.dart';
import 'package:nova_commerce/features/wishlist/domain/repositories/wishlist_repository.dart';

class SharedPrefsWishlistRepository implements WishlistRepository {
  SharedPrefsWishlistRepository(this._ds);

  final SharedPrefsWishlistDataSource _ds;

  @override
  Future<Set<String>> loadWishlistIds() => _ds.loadIds();

  @override
  Future<void> saveWishlistIds(Set<String> ids) => _ds.saveIds(ids);
}
