import 'dart:async';

import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_result.dart';
import '../../domain/repositories/payment_repository.dart';

class PaypalPaymentRepository implements PaymentRepository {
  PaypalPaymentRepository({
    required this.mode,
    required this.demoOutcome,
    this.delay = const Duration(milliseconds: 450),
  });

  final String mode;
  final String demoOutcome;
  final Duration delay;

  @override
  List<PaymentMethod> supportedMethods() {
    return const <PaymentMethod>[
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
    final m = mode.trim().toLowerCase();
    if (m == 'demo') {
      await Future<void>.delayed(delay);

      final next = demoOutcome.trim().toLowerCase();
      if (next == 'cancel') {
        return const PaymentCanceled();
      }
      if (next == 'failure' || next == 'fail') {
        return const PaymentFailure(message: 'PayPal payment failed.');
      }

      return const PaymentSuccess(orderId: 'demo_paypal_success');
    }

    return const PaymentFailure(
      message: 'PayPal real mode is not configured in this build.',
    );
  }
}
