import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:nova_commerce/core/device/device_id_datasource.dart';
import 'package:nova_commerce/features/cart/data/datasources/shared_prefs_cart_datasource.dart';
import 'package:nova_commerce/features/wishlist/data/datasources/shared_prefs_wishlist_datasource.dart';

class LocalDataExporter {
  LocalDataExporter({
    SharedPrefsCartDataSource? cart,
    SharedPrefsWishlistDataSource? wishlist,
    DeviceIdDataSource? deviceId,
  }) : _cart = cart ?? SharedPrefsCartDataSource(),
       _wishlist = wishlist ?? SharedPrefsWishlistDataSource(),
       _deviceId = deviceId ?? DeviceIdDataSource();

  final SharedPrefsCartDataSource _cart;
  final SharedPrefsWishlistDataSource _wishlist;
  final DeviceIdDataSource _deviceId;

  Future<Map<String, dynamic>> exportJson() async {
    final cartLines = await _cart.loadCartLines();
    final wishlistIds = await _wishlist.loadIds();
    final deviceId = await _deviceId.getOrCreate();

    return {
      'deviceId': deviceId,
      'cart': cartLines.map((e) => e.toJson()).toList(growable: false),
      'wishlist': wishlistIds.toList()..sort(),
    };
  }

  Future<String> exportString() async {
    final jsonMap = await exportJson();
    return compute(_encodeExportPayload, jsonMap);
  }
}

String _encodeExportPayload(Map<String, dynamic> payload) {
  return jsonEncode(payload);
}
