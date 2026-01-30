import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nova_commerce/data/datasources/shared_prefs_cart_datasource.dart';

void main() {
  test('SharedPrefsCartDataSource fresh install loads empty cart', () async {
    SharedPreferences.setMockInitialValues({});

    final ds = SharedPrefsCartDataSource();
    final lines = await ds.loadCartLines();

    expect(lines, isEmpty);
  });

  test('SharedPrefsCartDataSource migrates legacy cart shape to v1 lines', () async {
    SharedPreferences.setMockInitialValues({
      'saved_cart_v1': jsonEncode([
        {
          'product': {'id': 'p1'},
          'quantity': 2,
          'selectedColor': 'Black',
          'selectedSize': 'M',
        }
      ]),
    });

    final ds = SharedPrefsCartDataSource();
    final lines = await ds.loadCartLines();

    expect(lines.length, 1);
    expect(lines.first.productId, 'p1');
    expect(lines.first.quantity, 2);

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('saved_cart_v1');
    expect(raw, isNotNull);

    final decoded = jsonDecode(raw!);
    expect(decoded, isA<List>());
    final first = (decoded as List).first as Map;
    expect(first.containsKey('productId'), isTrue);
    expect(first.containsKey('product'), isFalse);
  });
}
