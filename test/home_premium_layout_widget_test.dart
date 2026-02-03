import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nova_commerce/domain/entities/home_config.dart';
import 'package:nova_commerce/domain/entities/product.dart';
import 'package:nova_commerce/domain/entities/variant.dart';
import 'package:nova_commerce/features/home/presentation/home_premium_providers.dart';
import 'package:nova_commerce/features/home/presentation/home_screen.dart';
import 'package:nova_commerce/features/home/presentation/home_viewmodel.dart';
import 'package:nova_commerce/features/wishlist/presentation/wishlist_viewmodel.dart';
import 'package:nova_commerce/features/trends/presentation/trends_screen.dart';

class TestHomeViewModel extends HomeViewModel {
  TestHomeViewModel(super.ref) {
    state = HomeState.data(
      items: _items,
      isRefreshing: false,
      isLoadingMore: false,
      hasMore: false,
    );
  }

  static final List<Product> _items = [
    Product(
      id: 'p-1',
      title: 'Test Product 1',
      brand: 'Nova',
      price: 42,
      currency: 'USD',
      imageUrls: const [],
      description: 'Test',
      variants: const [Variant(color: 'Black', size: 'M', stock: 3)],
    ),
  ];

  @override
  Future<void> refresh({bool showLoading = false}) async {}
}

void main() {
  testWidgets('Premium Home sections render in order', (
    WidgetTester tester,
  ) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    await binding.setSurfaceSize(const Size(375, 5200));
    addTearDown(() => binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeViewModelProvider.overrideWith((ref) => TestHomeViewModel(ref)),
          wishlistIdsProvider.overrideWith((ref) => const <String>{}),
          trendingProductsProvider.overrideWith(
            (ref) => Future.value(const <Product>[]),
          ),
          homeConfigProvider.overrideWith(
            (ref) => Stream<HomeConfig>.value(HomeConfig.defaults),
          ),
          homeSuperDealsProductsProvider.overrideWith(
            (ref) => Future<List<Product>>.value(const <Product>[]),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return const MaterialApp(home: HomeScreen());
          },
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(milliseconds: 800));

    final categories = find.text('Shop by category');
    final trending = find.text('Trending now');
    final picked = find.text('Picked for you').first;

    expect(categories, findsOneWidget);
    expect(trending, findsOneWidget);
    expect(find.text('Picked for you'), findsWidgets);

    final yCategories = tester.getTopLeft(categories).dy;
    final yTrending = tester.getTopLeft(trending).dy;
    final yPicked = tester.getTopLeft(picked).dy;

    expect(yCategories < yTrending, true);
    expect(yTrending < yPicked, true);
  });
}
