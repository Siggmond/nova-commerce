abstract class WishlistRepository {
  Future<Set<String>> loadWishlistIds();
  Future<void> saveWishlistIds(Set<String> ids);
}
