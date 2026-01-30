import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/config/app_env.dart';

import '../../core/security/secure_store.dart';

import '../../core/telemetry/telemetry.dart';

import '../../data/datasources/device_id_datasource.dart';

import '../../data/datasources/firestore_cart_datasource.dart';

import '../../data/datasources/firestore_home_config_datasource.dart';

import '../../data/datasources/firestore_home_super_deals_datasource.dart';

import '../../data/datasources/firestore_product_datasource.dart';

import '../../data/datasources/shared_prefs_cart_datasource.dart';

import '../../data/datasources/shared_prefs_recently_viewed_datasource.dart';

import '../../data/datasources/shared_prefs_wishlist_datasource.dart';

import '../../data/repositories/fake_home_config_repository.dart';

import '../../data/repositories/fake_home_super_deals_repository.dart';

import '../../data/repositories/fake_order_repository.dart';

import '../../data/repositories/fake_orders_repository.dart';

import '../../data/repositories/fake_ai_repository.dart';

import '../../data/repositories/fake_product_repository.dart';

import '../../data/repositories/firestore_cart_repository.dart';

import '../../data/repositories/firestore_home_config_repository.dart';

import '../../data/repositories/firestore_home_super_deals_repository.dart';

import '../../data/repositories/firestore_order_repository.dart';

import '../../data/repositories/firestore_orders_repository.dart';

import '../../data/repositories/firestore_product_repository.dart';

import '../../data/repositories/shared_prefs_cart_repository.dart';

import '../../data/repositories/shared_prefs_recently_viewed_repository.dart';

import '../../data/repositories/shared_prefs_wishlist_repository.dart';

import '../../data/repositories/syncing_cart_repository.dart';

import '../../domain/repositories/ai_repository.dart';

import '../../domain/repositories/cart_repository.dart';

import '../../domain/repositories/home_config_repository.dart';

import '../../domain/repositories/home_super_deals_repository.dart';

import '../../domain/repositories/order_repository.dart';

import '../../domain/repositories/orders_repository.dart';

import '../../domain/repositories/product_repository.dart';

import '../../domain/repositories/recently_viewed_repository.dart';

import '../../domain/repositories/wishlist_repository.dart';

import 'auth_providers.dart';

final deviceIdDataSourceProvider = Provider<DeviceIdDataSource>((ref) {
  return DeviceIdDataSource();
});

final secureStoreProvider = Provider<SecureStore>((ref) {
  if (AppEnv.useFakeRepos) {
    return InMemorySecureStore();
  }

  return FlutterSecureStore();
});

final telemetryProvider = Provider<Telemetry>((ref) {
  return NoopTelemetry();
});

final homeConfigRepositoryProvider = Provider<HomeConfigRepository>((ref) {
  if (AppEnv.useFakeRepos) {
    return FakeHomeConfigRepository();
  }

  return FirestoreHomeConfigRepository(
    FirestoreHomeConfigDataSource(FirebaseFirestore.instance),
  );
});

final homeSuperDealsRepositoryProvider = Provider<HomeSuperDealsRepository>((
  ref,
) {
  if (AppEnv.useFakeRepos) {
    return FakeHomeSuperDealsRepository();
  }

  return FirestoreHomeSuperDealsRepository(
    FirestoreHomeSuperDealsDataSource(FirebaseFirestore.instance),
  );
});

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

  final uid = ref.watch(currentUidProvider);

  if (uid == null || uid.trim().isEmpty) {
    return local;
  }

  final remote = FirestoreCartRepository(
    FirestoreCartDataSource(FirebaseFirestore.instance),

    uid.trim(),
  );

  return SyncingCartRepository(local: local, remote: remote);
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  if (AppEnv.useFakeRepos) {
    return FakeOrderRepository();
  }

  return FirestoreOrderRepository(FirebaseFirestore.instance);
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  if (AppEnv.useFakeRepos) {
    return FakeOrdersRepository();
  }

  return FirestoreOrdersRepository(FirebaseFirestore.instance);
});

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return FakeAiRepository();
});

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return SharedPrefsWishlistRepository(SharedPrefsWishlistDataSource());
});

final recentlyViewedRepositoryProvider = Provider<RecentlyViewedRepository>((
  ref,
) {
  return SharedPrefsRecentlyViewedRepository(
    SharedPrefsRecentlyViewedDataSource(),
  );
});
