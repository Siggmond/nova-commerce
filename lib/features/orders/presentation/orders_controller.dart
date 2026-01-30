import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/auth_providers.dart';
import '../../../core/config/providers.dart';
import '../../../domain/entities/order.dart';

final ordersControllerProvider =
    StateNotifierProvider<OrdersController, AsyncValue<List<Order>>>((ref) {
      return OrdersController(ref);
    });

class OrdersController extends StateNotifier<AsyncValue<List<Order>>> {
  OrdersController(this._ref) : super(const AsyncValue.loading()) {
    _uid = _ref.read(currentUidProvider);
    _ref.listen<String?>(currentUidProvider, (previous, next) {
      _uid = next;
      _maybeSubscribe();
    });

    _maybeSubscribe();
  }

  final Ref _ref;

  StreamSubscription<List<Order>>? _sub;
  String? _uid;

  int _requestId = 0;

  void _maybeSubscribe() {
    final uid = _uid;
    if (uid == null || uid.trim().isEmpty) {
      _sub?.cancel();
      state = AsyncValue.error(
        StateError('Sign in required.'),
        StackTrace.current,
      );
      return;
    }

    _subscribe(uid: uid, deviceId: '', showLoading: state.hasError);
  }

  void _subscribe({
    required String? uid,
    required String deviceId,
    required bool showLoading,
  }) {
    final requestId = ++_requestId;

    _sub?.cancel();

    if (showLoading) {
      state = const AsyncValue.loading();
    }

    final repo = _ref.read(ordersRepositoryProvider);
    _sub = repo
        .watchOrders(uid: uid, deviceId: deviceId)
        .listen(
          (orders) {
            if (requestId != _requestId) return;
            state = AsyncValue.data(orders);
          },
          onError: (Object e, StackTrace st) {
            if (requestId != _requestId) return;
            state = AsyncValue.error(e, st);
          },
        );
  }

  void refresh({bool showLoading = false}) {
    final uid = _uid;
    if (uid == null || uid.trim().isEmpty) {
      if (showLoading) state = const AsyncValue.loading();
      return;
    }

    _subscribe(uid: uid, deviceId: '', showLoading: showLoading);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final orderDetailsControllerProvider =
    StateNotifierProvider.family<
      OrderDetailsController,
      AsyncValue<Order>,
      String
    >((ref, id) {
      return OrderDetailsController(ref, id);
    });

class OrderDetailsController extends StateNotifier<AsyncValue<Order>> {
  OrderDetailsController(this._ref, this._orderId)
    : super(const AsyncValue.loading()) {
    load(showLoading: true);
  }

  final Ref _ref;
  final String _orderId;

  int _requestId = 0;

  Future<void> load({bool showLoading = false}) async {
    final requestId = ++_requestId;

    final hasValue = state.hasValue;
    if (showLoading || !hasValue) {
      state = const AsyncValue.loading();
    }

    try {
      final repo = _ref.read(ordersRepositoryProvider);
      final order = await repo.fetchOrderById(_orderId);
      if (requestId != _requestId) return;
      state = AsyncValue.data(order);
    } catch (e, st) {
      if (requestId != _requestId) return;
      state = AsyncValue.error(e, st);
    }
  }

  void refresh() {
    load(showLoading: false);
  }
}
