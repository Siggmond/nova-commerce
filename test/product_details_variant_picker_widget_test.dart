import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nova_commerce/app/di/app_providers.dart';
import 'package:nova_commerce/core/domain/entities/product.dart';
import 'package:nova_commerce/core/domain/entities/variant.dart';
import 'package:nova_commerce/core/domain/repositories/product_repository.dart';
import 'package:nova_commerce/features/cart/cart.dart';
import 'package:nova_commerce/features/products/presentation/product_details_screen.dart';
import 'package:nova_commerce/features/wishlist/wishlist.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

class _TestProductRepo implements ProductRepository {
  @override
  Future<Product?> getProductById(String id) async {
    return const Product(
      id: 'p_test',
      title: 'Tee',
      brand: 'Brand',
      price: 10,
      currency: 'USD',
      imageUrls: <String>[],
      description: 'd',
      variants: [
        Variant(color: 'Black', size: 'S', stock: 1),
        Variant(color: 'Black', size: 'M', stock: 1),
        Variant(color: 'White', size: 'S', stock: 1),
        Variant(color: 'White', size: 'M', stock: 1),
      ],
    );
  }

  @override
  Future<FeaturedProductsPage> getFeaturedProducts({
    int limit = 20,
    Object? startAfter,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Product>> getProductsByIds(Iterable<String> ids) {
    throw UnimplementedError();
  }
}

class _InMemoryCartRepository implements CartRepository {
  List<CartLine> _lines = const <CartLine>[];

  @override
  Future<List<CartLine>> loadCartLines() async => _lines;

  @override
  Future<void> saveCartLines(List<CartLine> items) async {
    _lines = items;
  }
}

class _TestWishlistViewModel extends WishlistViewModel {
  _TestWishlistViewModel(super.ref);

  @override
  Future<void> refresh() async {
    state = const WishlistState.data(ids: {}, products: []);
  }

  @override
  Future<void> toggle(String productId) async {}
}

void main() {
  testWidgets('ProductDetails selection can change; chips remain tappable', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repo = _TestProductRepo();
    final cartRepo = _InMemoryCartRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(repo),
          cartRepositoryProvider.overrideWithValue(cartRepo),
          wishlistViewModelProvider.overrideWith(
            (ref) => _TestWishlistViewModel(ref),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: ProductDetailsScreen(productId: 'p_test'),
            );
          },
        ),
      ),
    );

    // Wait for ProductDetailsViewModel to load product and render options.
    // (Bounded retries to avoid hangs if something goes wrong.)
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.text('Black').evaluate().isNotEmpty) break;
    }

    final blackText = find.text('Black');
    final whiteText = find.text('White');
    final sizeSText = find.text('S');

    expect(blackText, findsOneWidget);
    expect(whiteText, findsOneWidget);
    expect(sizeSText, findsOneWidget);

    await tester.tap(blackText);
    await tester.pump();

    await tester.ensureVisible(sizeSText);
    await tester.pump();
    await tester.tap(sizeSText);
    await tester.pump();

    expect(find.text('Color: Black'), findsOneWidget);
    expect(find.text('Size: S'), findsOneWidget);

    // Changing to another color should remain tappable and update selection.
    await tester.ensureVisible(find.text('White'));
    await tester.pump();
    await tester.tap(find.text('White'));
    await tester.pump();

    expect(find.text('Color: White'), findsOneWidget);
    expect(find.text('Size: S'), findsOneWidget);
  });
}
