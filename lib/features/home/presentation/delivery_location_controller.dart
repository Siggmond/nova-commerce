import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../data/datasources/shared_prefs_delivery_location_datasource.dart';

final deliveryLocationProvider =
    StateNotifierProvider<DeliveryLocationController, AsyncValue<String>>((
      ref,
    ) {
      final dataSource = ref.watch(deliveryLocationDataSourceProvider);
      return DeliveryLocationController(dataSource)..load();
    });

class DeliveryLocationController extends StateNotifier<AsyncValue<String>> {
  DeliveryLocationController(this._dataSource)
    : super(const AsyncValue<String>.loading());

  final SharedPrefsDeliveryLocationDataSource _dataSource;

  static const String _defaultCity = 'Beirut';

  Future<void> load() async {
    state = const AsyncValue<String>.loading();
    try {
      final city = await _dataSource.loadCity();
      state = AsyncValue<String>.data(city ?? _defaultCity);
    } catch (e, st) {
      state = AsyncValue<String>.error(e, st);
    }
  }

  Future<void> setCity(String city) async {
    final trimmed = city.trim();
    if (trimmed.isEmpty) return;

    state = AsyncValue<String>.data(trimmed);

    try {
      await _dataSource.saveCity(trimmed);
    } catch (e, st) {
      state = AsyncValue<String>.error(e, st);
    }
  }
}
