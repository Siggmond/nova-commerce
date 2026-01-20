import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/config/app_env.dart';
import '../../data/datasources/device_id_datasource.dart';
import '../../data/datasources/firestore_cart_datasource.dart';
import '../../data/datasources/firestore_product_datasource.dart';
import '../../data/datasources/shared_prefs_cart_datasource.dart';
import '../../data/datasources/shared_prefs_wishlist_datasource.dart';
import '../../data/repositories/fake_ai_repository.dart';
import '../../data/repositories/fake_product_repository.dart';
import '../../data/repositories/firestore_cart_repository.dart';
import '../../data/repositories/firestore_product_repository.dart';
import '../../data/repositories/shared_prefs_cart_repository.dart';
import '../../data/repositories/shared_prefs_wishlist_repository.dart';
import '../../data/repositories/syncing_cart_repository.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/wishlist_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  if (AppEnv.useFakeRepos) {
    return FakeProductRepository();
  }

  return FirestoreProductRepository(
    FirestoreProductDataSource(FirebaseFirestore.instance),
  );
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final local = SharedPrefsCartRepository(SharedPrefsCartDataSource());
  if (AppEnv.useFakeRepos) {
    return local;
  }

  final remote = FirestoreCartRepository(
    FirestoreCartDataSource(FirebaseFirestore.instance),
    DeviceIdDataSource(),
  );

  return SyncingCartRepository(local: local, remote: remote);
});

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return FakeAiRepository();
});

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return SharedPrefsWishlistRepository(SharedPrefsWishlistDataSource());
});
