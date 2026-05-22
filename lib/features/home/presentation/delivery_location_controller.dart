import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nova_commerce/app/di/app_providers.dart';
import 'package:nova_commerce/features/home/domain/repositories/delivery_location_store.dart';

final deliveryLocationProvider =
    StateNotifierProvider<DeliveryLocationController, AsyncValue<String>>((
      ref,
    ) {
      final store = ref.watch(deliveryLocationStoreProvider);
      return DeliveryLocationController(store)..load();
    });

class DeliveryLocationController extends StateNotifier<AsyncValue<String>> {
  DeliveryLocationController(this._dataSource)
    : super(const AsyncValue<String>.loading());

  final DeliveryLocationStore _dataSource;

  static const String _defaultCity = 'beirut';
  bool _isDisposed = false;

  Future<void> load() async {
    _publish(const AsyncValue<String>.loading());
    try {
      final city = await _dataSource.loadCity();
      _publish(AsyncValue<String>.data(city ?? _defaultCity));
    } catch (e, st) {
      _publish(AsyncValue<String>.error(e, st));
    }
  }

  Future<void> setCity(String city) async {
    if (_isDisposed) return;
    final trimmed = city.trim();
    if (trimmed.isEmpty) return;

    _publish(AsyncValue<String>.data(trimmed));

    try {
      await _dataSource.saveCity(trimmed);
    } catch (e, st) {
      _publish(AsyncValue<String>.error(e, st));
    }
  }

  void _publish(AsyncValue<String> next) {
    if (_isDisposed || !mounted) return;
    state = next;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
