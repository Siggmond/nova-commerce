import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nova_commerce/data/services/local_data_exporter.dart';

void main() {
  test('LocalDataExporter exports cart + wishlist as JSON', () async {
    SharedPreferences.setMockInitialValues({
      'saved_cart_v1': jsonEncode([
        {
          'productId': 'p1',
          'quantity': 1,
          'selectedColor': 'Black',
          'selectedSize': 'M',
        }
      ]),
      'wishlist_ids_v1': ['p1', 'p2'],
    });

    final exporter = LocalDataExporter();
    final data = await exporter.exportJson();

    expect(data['deviceId'], isA<String>());
    expect((data['deviceId'] as String).isNotEmpty, isTrue);

    final cart = data['cart'] as List;
    expect(cart.length, 1);

    final wishlist = data['wishlist'] as List;
    expect(wishlist.toSet().contains('p1'), isTrue);
    expect(wishlist.toSet().contains('p2'), isTrue);

    final asString = await exporter.exportString();
    expect(jsonDecode(asString), isA<Map>());
  });
}
