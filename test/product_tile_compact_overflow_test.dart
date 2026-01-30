import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nova_commerce/core/widgets/product_tile_compact.dart';
import 'package:nova_commerce/domain/entities/product.dart';
import 'package:nova_commerce/domain/entities/variant.dart';

void main() {
  testWidgets('ProductTileCompact does not overflow in grid cell with long text', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final product = Product(
      id: 'p_test',
      title:
          'THIS IS AN EXTREMELY LONG PRODUCT TITLE THAT SHOULD NEVER OVERFLOW EVEN INSIDE A COMPACT TILE WITH SMALLER PADDING',
      brand: 'A VERY VERY VERY VERY VERY VERY VERY VERY VERY LONG BRAND NAME',
      price: 999999.0,
      currency: 'USD',
      imageUrls: const <String>[],
      description: 'desc',
      variants: const [Variant(color: 'Black', size: 'M', stock: 1)],
    );

    FlutterErrorDetails? captured;
    final oldOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      captured ??= details;
    };
    addTearDown(() => FlutterError.onError = oldOnError);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            home: Scaffold(
              body: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.4),
                ),
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  padding: const EdgeInsets.all(16),
                  children: [
                    ProductTileCompact(product: product, onTap: () {}),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    final message = captured?.exceptionAsString() ?? '';
    expect(message.contains('A RenderFlex overflowed by'), isFalse);
  });

  testWidgets('ProductTileCompact does not overflow in horizontal item constraints', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final product = Product(
      id: 'p_test',
      title:
          'THIS IS AN EXTREMELY LONG PRODUCT TITLE THAT SHOULD NEVER OVERFLOW EVEN INSIDE A COMPACT TILE WITH SMALLER PADDING',
      brand: 'A VERY VERY VERY VERY VERY VERY VERY VERY VERY LONG BRAND NAME',
      price: 999999.0,
      currency: 'USD',
      imageUrls: const <String>[],
      description: 'desc',
      variants: const [Variant(color: 'Black', size: 'M', stock: 1)],
    );

    FlutterErrorDetails? captured;
    final oldOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      captured ??= details;
    };
    addTearDown(() => FlutterError.onError = oldOnError);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            home: Scaffold(
              body: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.4),
                ),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(16),
                  children: [
                    SizedBox(
                      width: 170,
                      height: 330,
                      child: ProductTileCompact(product: product, onTap: () {}),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    final message = captured?.exceptionAsString() ?? '';
    expect(message.contains('A RenderFlex overflowed by'), isFalse);
  });
}
