import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_result.dart';
import '../../domain/repositories/payment_repository.dart';
import 'stripe_runtime.dart';

class StripePaymentRepository implements PaymentRepository {
  StripePaymentRepository({
    required FirebaseFunctions functions,
    required this.mode,
    required this.demoOutcome,
    this.delay = const Duration(milliseconds: 450),
  }) : _functions = functions;

  final FirebaseFunctions _functions;
  final String mode;
  final String demoOutcome;
  final Duration delay;

  @override
  List<PaymentMethod> supportedMethods() {
    return const <PaymentMethod>[
      PaymentMethod(
        type: PaymentMethodType.stripe,
        title: 'Stripe',
        subtitle: 'Card',
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
        return const PaymentFailure(message: 'Stripe payment failed.');
      }

      return const PaymentSuccess(orderId: 'demo_stripe_success');
    }

    if (kIsWeb) {
      return const PaymentFailure(message: 'Stripe is not supported on web.');
    }

    try {
      await StripeRuntime.ensureConfigured();

      final create = _functions.httpsCallable('createPaymentIntent');
      final createRes = await create.call(<String, Object?>{
        'shipping': shipping,
        'deviceId': deviceId,
      });

      final data = (createRes.data as Map).cast<String, dynamic>();
      final clientSecret = (data['clientSecret'] as String?) ?? '';
      final paymentIntentId = (data['paymentIntentId'] as String?) ?? '';
      if (clientSecret.trim().isEmpty || paymentIntentId.trim().isEmpty) {
        return const PaymentFailure(message: 'Stripe is not configured.');
      }

      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Nova Commerce',
        ),
      );

      await stripe.Stripe.instance.presentPaymentSheet();

      final finalize = _functions.httpsCallable(
        'finalizeOrderFromPaymentIntent',
      );
      final finalizeRes = await finalize.call(<String, Object?>{
        'paymentIntentId': paymentIntentId,
        'shipping': shipping,
        'deviceId': deviceId,
      });
      final finalizeData = (finalizeRes.data as Map).cast<String, dynamic>();
      final orderId = (finalizeData['orderId'] as String?) ?? '';
      if (orderId.trim().isEmpty) {
        return const PaymentFailure(message: 'Order finalization failed.');
      }

      return PaymentSuccess(orderId: orderId);
    } on stripe.StripeException catch (e) {
      final code = e.error.code;
      if (code == stripe.FailureCode.Canceled) {
        return const PaymentCanceled();
      }
      return PaymentFailure(
        message: e.error.localizedMessage ?? 'Payment failed.',
      );
    } on FirebaseFunctionsException catch (e) {
      if (!kReleaseMode) {
        debugPrint(
          'StripePaymentRepository FirebaseFunctionsException: ${e.code} ${e.message}',
        );
      }
      return PaymentFailure(message: e.message ?? 'Payment failed.');
    } catch (e) {
      if (!kReleaseMode) {
        debugPrint('StripePaymentRepository error: $e');
      }
      return PaymentFailure(message: 'Payment failed.');
    }
  }
}
