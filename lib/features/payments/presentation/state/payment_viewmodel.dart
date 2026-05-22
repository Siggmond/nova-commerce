import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nova_commerce/app/di/app_providers.dart';
import 'package:nova_commerce/features/cart/domain/state/cart_state.dart';
import 'package:nova_commerce/features/checkout/domain/checkout_cart_summary.dart';
import 'package:nova_commerce/features/loyalty/gold_controller.dart';

import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_result.dart';
import '../../domain/repositories/payment_repository.dart';

class PaymentFlowArgs {
  const PaymentFlowArgs({
    required this.summary,
    required this.uid,
    required this.deviceId,
    required this.shipping,
  });

  final CheckoutCartSummary summary;
  final String uid;
  final String deviceId;
  final Map<String, String> shipping;
}

class PaymentConfirmArgs {
  const PaymentConfirmArgs({required this.flow, required this.method});

  final PaymentFlowArgs flow;
  final PaymentMethodType method;
}

class PaymentSuccessArgs {
  const PaymentSuccessArgs({required this.orderId, required this.summary});

  final String orderId;
  final CheckoutCartSummary summary;
}

sealed class PaymentEvent {
  const PaymentEvent();
}

class PaymentGoToConfirm extends PaymentEvent {
  const PaymentGoToConfirm({required this.method});

  final PaymentMethodType method;
}

class PaymentGoToSuccess extends PaymentEvent {
  const PaymentGoToSuccess({required this.orderId});

  final String orderId;
}

class PaymentGoToFailure extends PaymentEvent {
  const PaymentGoToFailure({required this.message});

  final String message;
}

class PaymentGoBack extends PaymentEvent {
  const PaymentGoBack();
}

class PaymentState {
  const PaymentState({
    this.selectedMethod,
    this.isProcessing = false,
    this.event,
    this.eventId = 0,
  });

  final PaymentMethodType? selectedMethod;
  final bool isProcessing;
  final PaymentEvent? event;
  final int eventId;

  static const Object _unset = Object();

  PaymentState copyWith({
    PaymentMethodType? selectedMethod,
    bool? isProcessing,
    Object? event = _unset,
    int? eventId,
  }) {
    return PaymentState(
      selectedMethod: selectedMethod ?? this.selectedMethod,
      isProcessing: isProcessing ?? this.isProcessing,
      event: event == _unset ? this.event : event as PaymentEvent?,
      eventId: eventId ?? this.eventId,
    );
  }
}

final paymentViewModelProvider =
    StateNotifierProvider.family<
      PaymentViewModel,
      PaymentState,
      PaymentFlowArgs
    >((ref, args) {
      final repo = ref.watch(paymentRepositoryProvider);
      return PaymentViewModel(ref: ref, repository: repo, args: args);
    });

class PaymentViewModel extends StateNotifier<PaymentState> {
  PaymentViewModel({
    required Ref ref,
    required PaymentRepository repository,
    required PaymentFlowArgs args,
  }) : _ref = ref,
       _repo = repository,
       _args = args,
       _supportedMethods = repository.supportedMethods(),
       super(
         PaymentState(
           selectedMethod: repository.supportedMethods().isNotEmpty
               ? repository.supportedMethods().first.type
               : null,
         ),
       );

  final Ref _ref;
  final PaymentRepository _repo;
  final PaymentFlowArgs _args;
  final List<PaymentMethod> _supportedMethods;

  CheckoutCartSummary get summary => _args.summary;

  List<PaymentMethod> get supportedMethods => _supportedMethods;

  void selectMethod(PaymentMethodType method) {
    state = state.copyWith(selectedMethod: method);
  }

  void _emit(PaymentEvent event) {
    state = state.copyWith(event: event, eventId: state.eventId + 1);
  }

  void goToConfirm() {
    final method = state.selectedMethod;
    if (method == null) return;
    _emit(PaymentGoToConfirm(method: method));
  }

  Future<void> pay({required PaymentMethodType method}) async {
    state = state.copyWith(isProcessing: true);

    final result = await _repo.pay(
      method: method,
      uid: _args.uid,
      deviceId: _args.deviceId,
      shipping: _args.shipping,
    );

    state = state.copyWith(isProcessing: false);

    switch (result) {
      case PaymentSuccess(:final orderId):
        try {
          await _ref
              .read(goldControllerProvider.notifier)
              .awardForOrder(orderId: orderId, orderTotal: _args.summary.total);
        } catch (_) {}

        final selectedIds = _ref.read(selectedCartItemIdsProvider);
        final cartItems = _ref.read(cartItemsProvider);
        final allIds = cartItems.map((i) => i.product.id).toSet();
        if (selectedIds.isEmpty ||
            (allIds.isNotEmpty && selectedIds.length == allIds.length)) {
          _ref.read(cartClearProvider).call();
        } else {
          _ref
              .read(cartViewModelProvider.notifier)
              .removeByProductIds(selectedIds);
        }
        _ref.read(selectedCartItemIdsProvider.notifier).selectAll(const []);

        _emit(PaymentGoToSuccess(orderId: orderId));
      case PaymentFailure(:final message):
        _emit(PaymentGoToFailure(message: message));
      case PaymentCanceled():
        _emit(const PaymentGoBack());
    }
  }
}
