import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_env.dart';
import '../../core/security/secure_store.dart';
import '../../core/telemetry/telemetry.dart';
import '../../core/ai_nav/ai_nav_controller.dart';
import '../../core/ai_nav/ai_nav_model_runner.dart';
import '../../core/ai_nav/ai_nav_suggestion.dart';
import 'package:nova_commerce/core/device/device_id_datasource.dart';
import 'package:nova_commerce/features/cart/data/datasources/firestore_cart_datasource.dart';
import 'package:nova_commerce/features/home/data/datasources/firestore_home_config_datasource.dart';
import 'package:nova_commerce/features/home/data/datasources/firestore_home_super_deals_datasource.dart';
import 'package:nova_commerce/features/offers/data/datasources/firestore_offers_datasource.dart';
import 'package:nova_commerce/features/cart/data/datasources/shared_prefs_cart_datasource.dart';
import 'package:nova_commerce/features/search/data/datasources/shared_prefs_recent_searches_datasource.dart';
import 'package:nova_commerce/features/recently_viewed/data/datasources/shared_prefs_recently_viewed_datasource.dart';
import 'package:nova_commerce/features/wishlist/data/datasources/shared_prefs_wishlist_datasource.dart';
import 'package:nova_commerce/features/home/data/datasources/shared_prefs_delivery_location_datasource.dart';
import 'package:nova_commerce/features/checkout/data/datasources/shared_prefs_checkout_address_datasource.dart';
import 'package:nova_commerce/features/ai_assistant/data/ai_chat_storage.dart';
import 'package:nova_commerce/features/ai_assistant/data/repositories/fake_ai_repository.dart';
import 'package:nova_commerce/features/home/data/repositories/fake_home_config_repository.dart';
import 'package:nova_commerce/features/home/data/repositories/fake_home_super_deals_repository.dart';
import 'package:nova_commerce/features/offers/data/repositories/fake_offers_repository.dart';
import 'package:nova_commerce/features/orders/data/repositories/fake_order_repository.dart';
import 'package:nova_commerce/features/orders/data/repositories/fake_orders_repository.dart';
import 'package:nova_commerce/features/cart/data/repositories/firestore_cart_repository.dart';
import 'package:nova_commerce/features/home/data/repositories/firestore_home_config_repository.dart';
import 'package:nova_commerce/features/home/data/repositories/firestore_home_super_deals_repository.dart';
import 'package:nova_commerce/features/offers/data/repositories/firestore_offers_repository.dart';
import 'package:nova_commerce/features/orders/data/repositories/firestore_order_repository.dart';
import 'package:nova_commerce/features/orders/data/repositories/firestore_orders_repository.dart';
import 'package:nova_commerce/features/cart/data/repositories/shared_prefs_cart_repository.dart';
import 'package:nova_commerce/features/search/data/repositories/shared_prefs_recent_searches_repository.dart';
import 'package:nova_commerce/features/recently_viewed/data/repositories/shared_prefs_recently_viewed_repository.dart';
import 'package:nova_commerce/features/wishlist/data/repositories/shared_prefs_wishlist_repository.dart';
import 'package:nova_commerce/features/cart/data/repositories/syncing_cart_repository.dart';
import 'package:nova_commerce/features/ai_assistant/domain/repositories/ai_repository.dart';
import 'package:nova_commerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:nova_commerce/features/home/domain/repositories/home_config_repository.dart';
import 'package:nova_commerce/features/home/domain/repositories/home_super_deals_repository.dart';
import 'package:nova_commerce/features/home/domain/repositories/delivery_location_store.dart';
import 'package:nova_commerce/features/offers/domain/repositories/offers_repository.dart';
import 'package:nova_commerce/features/orders/domain/repositories/order_repository.dart';
import 'package:nova_commerce/features/orders/domain/repositories/orders_repository.dart';
import 'package:nova_commerce/core/domain/repositories/product_repository.dart';
import 'package:nova_commerce/features/checkout/domain/checkout_address_store.dart';
import 'package:nova_commerce/features/search/domain/repositories/recent_searches_repository.dart';
import 'package:nova_commerce/features/recently_viewed/domain/repositories/recently_viewed_repository.dart';
import 'package:nova_commerce/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:nova_commerce/features/ai_assistant/domain/repositories/ai_chat_store.dart';
import 'package:nova_commerce/features/auth/auth.dart';
import 'package:nova_commerce/features/payments/payments.dart';
import 'package:nova_commerce/features/products/products.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppEnv.useFakeRepos) {
    return FakeAuthRepository();
  }

  final firebaseConfigured = Firebase.apps.isNotEmpty;
  if (!firebaseConfigured) {
    throw StateError('Firebase is not configured.');
  }

  return FirebaseAuthRepository(ref.read(firebaseAuthProvider));
});

final authUserProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentUidProvider = Provider<String?>((ref) {
  return ref
      .watch(authUserProvider)
      .maybeWhen(data: (user) => user?.uid, orElse: () => null);
});

final deviceIdDataSourceProvider = Provider<DeviceIdDataSource>((ref) {
  return DeviceIdDataSource();
});

final offersRepositoryProvider = Provider<OffersRepository>((ref) {
  if (AppEnv.useFakeRepos) {
    return FakeOffersRepository();
  }

  return FirestoreOffersRepository(
    FirestoreOffersDataSource(FirebaseFirestore.instance),
  );
});

final deliveryLocationStoreProvider = Provider<DeliveryLocationStore>((ref) {
  return SharedPrefsDeliveryLocationDataSource();
});

final checkoutAddressStoreProvider = Provider<CheckoutAddressStore>((ref) {
  return SharedPrefsCheckoutAddressDataSource();
});

final aiChatStoreProvider = Provider<AiChatStore>((ref) {
  return AiChatStorage();
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
  final base = AppEnv.useFakeRepos
      ? FakeProductRepository()
      : FirestoreProductRepository(
          FirestoreProductDataSource(FirebaseFirestore.instance),
        );
  return CachedProductRepository(base);
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

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final provider = AppEnv.paymentsProvider.trim().toLowerCase();
  final mode = AppEnv.paymentsMode.trim().toLowerCase();
  final outcome = AppEnv.paymentsDemoOutcome.trim().toLowerCase();

  if (AppEnv.useFakeRepos || provider == 'fake') {
    return FakePaymentRepository(outcome: outcome);
  }

  if (provider == 'stripe') {
    return StripePaymentRepository(
      functions: FirebaseFunctions.instance,
      mode: mode,
      demoOutcome: outcome,
    );
  }

  if (provider == 'paypal') {
    return PaypalPaymentRepository(mode: mode, demoOutcome: outcome);
  }

  return FakePaymentRepository(outcome: outcome);
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

final recentSearchesRepositoryProvider = Provider<RecentSearchesRepository>((
  ref,
) {
  return SharedPrefsRecentSearchesRepository(
    SharedPrefsRecentSearchesDataSource(),
  );
});

final aiNavControllerProvider =
    StateNotifierProvider<AiNavController, AiNavSuggestion?>((ref) {
      final runner = AiNavModelRunner(
        // Must match `pubspec.yaml`.
        assetPath: 'assets/models/ai_nav_model_quant.tflite',
      );

      final controller = AiNavController(modelRunner: runner);
      ref.onDispose(controller.disposeController);

      return controller;
    });
