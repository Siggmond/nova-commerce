import 'dart:async';

import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_result.dart';
import '../../domain/repositories/payment_repository.dart';

class FakePaymentRepository implements PaymentRepository {
  FakePaymentRepository({
    required this.outcome,
    this.delay = const Duration(milliseconds: 450),
  });

  final String outcome;
  final Duration delay;

  @override
  List<PaymentMethod> supportedMethods() {
    return const <PaymentMethod>[
      PaymentMethod(
        type: PaymentMethodType.stripe,
        title: 'Stripe',
        subtitle: 'Card',
      ),
      PaymentMethod(
        type: PaymentMethodType.paypal,
        title: 'PayPal',
        subtitle: 'PayPal checkout',
      ),
    ];
  }

  @override
  Future<PaymentResult> pay({
    required PaymentMethodType method,
    required String uid,
    required String deviceId,
    required Map<String, String> shipping,
  }) async {
    await Future<void>.delayed(delay);

    final next = outcome.trim().toLowerCase();
    if (next == 'cancel') {
      return const PaymentCanceled();
    }
    if (next == 'failure' || next == 'fail') {
      return const PaymentFailure(message: 'Payment failed.');
    }

    return PaymentSuccess(orderId: 'demo_order_success');
  }
}
