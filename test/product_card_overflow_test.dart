import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nova_commerce/core/widgets/product_card.dart';
import 'package:nova_commerce/domain/entities/product.dart';
import 'package:nova_commerce/domain/entities/variant.dart';

void main() {
  testWidgets('ProductCard never overflows in tight constraints', (
    WidgetTester tester,
  ) async {
    final product = Product(
      id: 'p_test',
      title:
          'THIS IS AN EXTREMELY LONG PRODUCT TITLE THAT SHOULD NEVER OVERFLOW EVEN INSIDE A FIXED CARD HEIGHT AND WITH LARGE TEXT SCALE ENABLED',
      brand:
          'A VERY VERY VERY VERY VERY VERY VERY VERY VERY VERY VERY VERY LONG BRAND NAME',
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

    addTearDown(() {
      FlutterError.onError = oldOnError;
    });

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 252,
                height: 272,
                child: ProductCard(
                  product: product,
                  isSaved: false,
                  onToggleSaved: () {},
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final message = captured?.exceptionAsString() ?? '';
    expect(message.contains('A RenderFlex overflowed by'), isFalse);
  });
}
