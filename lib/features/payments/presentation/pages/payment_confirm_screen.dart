import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nova_commerce/app/router/app_routes.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

import '../../domain/entities/payment_method.dart';
import '../state/payment_viewmodel.dart';
import '../widgets/payment_summary_card.dart';

class PaymentConfirmScreen extends ConsumerWidget {
  const PaymentConfirmScreen({super.key, required this.args});

  final PaymentConfirmArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final paymentProvider = paymentViewModelProvider(args.flow);
    final state = ref.watch(paymentProvider);
    final notifier = ref.read(paymentProvider.notifier);

    ref.listen<int>(paymentProvider.select((s) => s.eventId), (_, __) {
      final event = ref.read(paymentProvider).event;
      if (event is PaymentGoToSuccess) {
        context.push(
          AppRoutes.paymentSuccess,
          extra: PaymentSuccessArgs(
            orderId: event.orderId,
            summary: args.flow.summary,
          ),
        );
      } else if (event is PaymentGoToFailure) {
        context.push(AppRoutes.paymentFailure, extra: event.message);
      } else if (event is PaymentGoBack) {
        context.pop();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(t.paymentsConfirmTitle)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        children: [
          PaymentSummaryCard(summary: args.flow.summary),
          SizedBox(height: 14.h),
          Text(
            t.paymentsSelectedMethod(_methodLabel(t, args.method)),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.isProcessing
                  ? null
                  : () => notifier.pay(method: args.method),
              child: state.isProcessing
                  ? SizedBox(
                      width: 18.r,
                      height: 18.r,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(t.paymentsPayCta),
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: state.isProcessing ? null : () => context.pop(),
              child: Text(t.commonBack),
            ),
          ),
        ],
      ),
    );
  }

  static String _methodLabel(AppLocalizations t, PaymentMethodType method) {
    return switch (method) {
      PaymentMethodType.stripe => t.paymentsMethodStripe,
      PaymentMethodType.paypal => t.paymentsMethodPaypal,
    };
  }
}
