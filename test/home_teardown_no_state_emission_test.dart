import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nova_commerce/app/di/app_providers.dart';
import 'package:nova_commerce/app/router/app_routes.dart';
import 'package:nova_commerce/core/domain/entities/product.dart';
import 'package:nova_commerce/core/domain/entities/variant.dart';
import 'package:nova_commerce/core/domain/repositories/product_repository.dart';
import 'package:nova_commerce/features/home/domain/repositories/delivery_location_store.dart';
import 'package:nova_commerce/features/home/presentation/home_v2_screen.dart';
import 'package:nova_commerce/features/home/presentation/home_viewmodel.dart';
import 'package:nova_commerce/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

class _DelayedHomeRepo implements ProductRepository {
  final Completer<void> _firstPageGate = Completer<void>();
  int featuredRequests = 0;

  void completeFirstPage() {
    if (_firstPageGate.isCompleted) return;
    _firstPageGate.complete();
  }

  @override
  Future<FeaturedProductsPage> getFeaturedProducts({
    int limit = 20,
    Object? startAfter,
  }) async {
    featuredRequests += 1;
    if (startAfter == null && featuredRequests == 1) {
      await _firstPageGate.future;
    }

    return FeaturedProductsPage(items: const <Product>[], cursor: null);
  }

  @override
  Future<Product?> getProductById(String id) async {
    return const Product(
      id: 'p-1',
      title: 'Test Product',
      brand: 'Nova',
      price: 10,
      currency: 'USD',
      imageUrls: <String>[],
      description: 'd',
      variants: <Variant>[Variant(color: 'Black', size: 'M', stock: 5)],
    );
  }

  @override
  Future<List<Product>> getProductsByIds(Iterable<String> ids) async {
    return <Product>[
      for (final id in ids)
        Product(
          id: id,
          title: 'Test Product',
          brand: 'Nova',
          price: 10,
          currency: 'USD',
          imageUrls: const <String>[],
          description: 'd',
          variants: const <Variant>[
            Variant(color: 'Black', size: 'M', stock: 5),
          ],
        ),
    ];
  }
}

class _MemoryDeliveryLocationStore implements DeliveryLocationStore {
  String? _city;

  @override
  Future<String?> loadCity() async => _city;

  @override
  Future<void> saveCity(String city) async {
    _city = city;
  }
}

class _InMemoryWishlistRepository implements WishlistRepository {
  Set<String> _ids = <String>{};

  @override
  Future<Set<String>> loadWishlistIds() async => _ids;

  @override
  Future<void> saveWishlistIds(Set<String> ids) async {
    _ids = ids;
  }
}

class _TestHomeApp extends StatelessWidget {
  const _TestHomeApp({required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          initialRoute: AppRoutes.home,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routes: <String, WidgetBuilder>{
            AppRoutes.home: (_) => const HomeV2Screen(),
            AppRoutes.product: (_) => const Scaffold(body: SizedBox.shrink()),
            AppRoutes.cart: (_) => const Scaffold(body: SizedBox.shrink()),
          },
        );
      },
    );
  }
}

Future<void> _pumpUntil({
  required WidgetTester tester,
  required bool Function() condition,
  int maxPumps = 120,
}) async {
  for (var i = 0; i < maxPumps; i++) {
    if (condition()) return;
    await tester.pump(const Duration(milliseconds: 16));
  }
  throw TestFailure('Condition was not met in time.');
}

Future<void> _pushNamed(
  WidgetTester tester,
  GlobalKey<NavigatorState> navigatorKey,
  String routeName,
) async {
  unawaited(navigatorKey.currentState!.pushNamed(routeName));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 320));
}

Future<void> _replaceNamed(
  WidgetTester tester,
  GlobalKey<NavigatorState> navigatorKey,
  String routeName,
) async {
  unawaited(navigatorKey.currentState!.pushReplacementNamed(routeName));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 320));
}

void _expectNoFrameworkException(WidgetTester tester) {
  expect(tester.takeException(), isNull);
}

Future<void> _spinUntil({
  required bool Function() condition,
  int maxTicks = 80,
}) async {
  for (var i = 0; i < maxTicks; i++) {
    if (condition()) return;
    await Future<void>.delayed(Duration.zero);
  }
  throw TestFailure('Condition was not met in time.');
}

void main() {
  test('cancelInFlightPageFetches drops stale fetch completions', () async {
    final delayedRepo = _DelayedHomeRepo();
    final container = ProviderContainer(
      overrides: [productRepositoryProvider.overrideWithValue(delayedRepo)],
    );
    addTearDown(() {
      delayedRepo.completeFirstPage();
      container.dispose();
    });

    container.read(homeViewModelProvider);
    await _spinUntil(condition: () => delayedRepo.featuredRequests > 0);
    expect(container.read(homeViewModelProvider), isA<HomeLoading>());

    container.read(homeViewModelProvider.notifier).cancelInFlightPageFetches();
    delayedRepo.completeFirstPage();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(homeViewModelProvider), isA<HomeLoading>());
  });

  testWidgets(
    'home teardown blocks emissions from in-flight fetches on rapid nav',
    (tester) async {
      final navKey = GlobalKey<NavigatorState>();
      final delayedRepo = _DelayedHomeRepo();
      final flutterErrors = <FlutterErrorDetails>[];
      final oldOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        flutterErrors.add(details);
        oldOnError?.call(details);
      };
      addTearDown(() {
        FlutterError.onError = oldOnError;
        delayedRepo.completeFirstPage();
      });
      final container = ProviderContainer(
        overrides: [
          productRepositoryProvider.overrideWithValue(delayedRepo),
          deliveryLocationStoreProvider.overrideWithValue(
            _MemoryDeliveryLocationStore(),
          ),
          wishlistRepositoryProvider.overrideWithValue(
            _InMemoryWishlistRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _TestHomeApp(navigatorKey: navKey),
        ),
      );

      await _pumpUntil(
        tester: tester,
        condition: () => delayedRepo.featuredRequests > 0,
      );
      _expectNoFrameworkException(tester);

      // Open Home, start fetch, immediately dispose Home.
      await _replaceNamed(tester, navKey, AppRoutes.cart);
      _expectNoFrameworkException(tester);

      // Complete stale fetch after Home teardown; state must not publish.
      delayedRepo.completeFirstPage();
      await tester.pump(const Duration(milliseconds: 80));
      await tester.pump();
      _expectNoFrameworkException(tester);

      // Rapid nav regression windows.
      await _replaceNamed(tester, navKey, AppRoutes.home);
      await _pushNamed(tester, navKey, AppRoutes.product);
      _expectNoFrameworkException(tester);
      navKey.currentState!.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 320));
      _expectNoFrameworkException(tester);

      await _replaceNamed(tester, navKey, AppRoutes.cart);
      await _replaceNamed(tester, navKey, AppRoutes.home);
      _expectNoFrameworkException(tester);

      FlutterError.onError = oldOnError;
      expect(flutterErrors, isEmpty);
    },
  );
}
