import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/cart_line.dart';

class SharedPrefsCartDataSource {
  static const _key = 'saved_cart_v1';

  Future<List<CartLine>> loadCartLines() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    final lines = <CartLine>[];
    for (final item in decoded) {
      if (item is! Map) continue;
      final json = item.cast<String, dynamic>();

      if (json.containsKey('productId')) {
        final line = CartLine.fromJson(json);
        if (line.productId.isNotEmpty && line.quantity > 0) {
          lines.add(line);
        }
        continue;
      }

      final product = json['product'];
      if (product is Map && product['id'] is String) {
        final productId = product['id'] as String;
        final quantity = (json['quantity'] as num?)?.toInt() ?? 0;
        final selectedColor = (json['selectedColor'] as String?) ?? '';
        final selectedSize = (json['selectedSize'] as String?) ?? '';
        if (productId.isEmpty || quantity <= 0) continue;
        lines.add(
          CartLine(
            productId: productId,
            quantity: quantity,
            selectedColor: selectedColor,
            selectedSize: selectedSize,
          ),
        );
      }
    }

    if (lines.isNotEmpty) {
      await saveCartLines(lines);
    }

    return lines;
  }

  Future<void> saveCartLines(List<CartLine> items) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = items.map((i) => i.toJson()).toList(growable: false);
    await prefs.setString(_key, jsonEncode(payload));
  }
}
