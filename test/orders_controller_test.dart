import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nova_commerce/core/config/auth_providers.dart';
import 'package:nova_commerce/core/config/providers.dart';
import 'package:nova_commerce/data/datasources/device_id_datasource.dart';
import 'package:nova_commerce/domain/entities/order.dart';
import 'package:nova_commerce/domain/entities/order_item.dart';
import 'package:nova_commerce/domain/entities/order_status.dart';
import 'package:nova_commerce/domain/repositories/orders_repository.dart';
import 'package:nova_commerce/features/orders/presentation/orders_controller.dart';

class _TestDeviceIdDataSource extends DeviceIdDataSource {
  @override
  Future<String> getOrCreate() async {
    return 'device_test';
  }
}

class _StreamOrdersRepo implements OrdersRepository {
  _StreamOrdersRepo(this.controller);

  final StreamController<List<Order>> controller;

  @override
  Stream<List<Order>> watchOrders({
    required String? uid,
    required String deviceId,
  }) {
    return controller.stream;
  }

  @override
  Future<Order> fetchOrderById(String id) async {
    throw UnimplementedError();
  }
}

Order _o(String id) {
  return Order(
    id: id,
    uid: 'uid_1',
    deviceId: 'device_test',
    status: OrderStatus.placed,
    statusRaw: 'placed',
    currency: 'USD',
    subtotal: 10,
    shippingFee: 0,
    total: 10,
    shipping: const <String, dynamic>{'fullName': 'A'},
    items: const <OrderItem>[
      OrderItem(
        productId: 'p1',
        title: 'T',
        price: 10,
        quantity: 1,
        selectedColor: 'Black',
        selectedSize: 'M',
      ),
    ],
    createdAt: DateTime.utc(2025, 1, 1),
    updatedAt: DateTime.utc(2025, 1, 1),
  );
}

void main() {
  test('OrdersController emits data from repository stream', () async {
    final controller = StreamController<List<Order>>.broadcast();
    addTearDown(controller.close);

    final repo = _StreamOrdersRepo(controller);

    final container = ProviderContainer(
      overrides: [
        currentUidProvider.overrideWithValue('uid_1'),
        deviceIdDataSourceProvider.overrideWithValue(_TestDeviceIdDataSource()),
        ordersRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    final states = <AsyncValue<List<Order>>>[];
    final sub = container.listen(
      ordersControllerProvider,
      (prev, next) => states.add(next),
      fireImmediately: true,
    );
    addTearDown(sub.close);

    await Future<void>.delayed(const Duration(milliseconds: 1));

    controller.add([_o('o1')]);
    await Future<void>.delayed(const Duration(milliseconds: 1));

    expect(
      states.any((s) => s.hasValue && (s.value?.length ?? 0) == 1),
      isTrue,
    );
    final latest = states.last;
    expect(latest.hasValue, isTrue);
    expect(latest.value?.first.id, 'o1');
  });

  test('OrderDetailsController loads order via repository', () async {
    final order = _o('o99');

    final repo = _FakeFetchRepo(order);

    final container = ProviderContainer(
      overrides: [
        currentUidProvider.overrideWithValue('uid_1'),
        deviceIdDataSourceProvider.overrideWithValue(_TestDeviceIdDataSource()),
        ordersRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    final ctrl = container.read(orderDetailsControllerProvider('o99').notifier);
    await ctrl.load(showLoading: true);

    final state = container.read(orderDetailsControllerProvider('o99'));
    expect(state.hasValue, isTrue);
    expect(state.value?.id, 'o99');
  });
}

class _FakeFetchRepo implements OrdersRepository {
  _FakeFetchRepo(this.order);

  final Order order;

  @override
  Future<Order> fetchOrderById(String id) async {
    return order;
  }

  @override
  Stream<List<Order>> watchOrders({
    required String? uid,
    required String deviceId,
  }) {
    return const Stream<List<Order>>.empty();
  }
}
