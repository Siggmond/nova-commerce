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
    await binding.setSurfaceSize(const Size(375, 1800));
    addTearDown(() => binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeViewModelProvider.overrideWith((ref) => TestHomeViewModel(ref)),
          wishlistIdsProvider.overrideWith((ref) => const <String>{}),
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

    final quick = find.byKey(const Key('home_quick_squares_section'));
    final catalog = find.byKey(const Key('home_catalog_section'));
    final styles = find.byKey(const Key('home_styles_section'));
    final deals = find.byKey(const Key('home_super_deals_header'));

    expect(quick, findsOneWidget);
    expect(catalog, findsOneWidget);
    expect(styles, findsOneWidget);
    expect(deals, findsOneWidget);

    final yQuick = tester.getTopLeft(quick).dy;
    final yCatalog = tester.getTopLeft(catalog).dy;
    final yStyles = tester.getTopLeft(styles).dy;
    final yDeals = tester.getTopLeft(deals).dy;

    expect(yQuick < yCatalog, true);
    expect(yCatalog < yStyles, true);
    expect(yStyles < yDeals, true);
  });
}
