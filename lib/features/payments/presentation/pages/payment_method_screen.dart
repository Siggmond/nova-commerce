import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nova_commerce/app/router/app_routes.dart';
import 'package:nova_commerce/features/checkout/domain/checkout_cart_summary.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

import '../state/payment_viewmodel.dart';
import '../widgets/payment_method_tile.dart';
import '../widgets/payment_summary_card.dart';

class PaymentMethodScreen extends ConsumerWidget {
  const PaymentMethodScreen({super.key, required this.args});

  final PaymentFlowArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final CheckoutCartSummary summary = args.summary;
    final paymentProvider = paymentViewModelProvider(args);

    final state = ref.watch(paymentProvider);
    final notifier = ref.read(paymentProvider.notifier);

    ref.listen<int>(paymentProvider.select((s) => s.eventId), (_, __) {
      final event = ref.read(paymentProvider).event;
      if (event is PaymentGoToConfirm) {
        context.push(
          AppRoutes.paymentConfirm,
          extra: PaymentConfirmArgs(flow: args, method: event.method),
        );
      } else if (event is PaymentGoBack) {
        context.pop();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(t.paymentsTitle)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        children: [
          PaymentSummaryCard(summary: summary),
          SizedBox(height: 14.h),
          Text(
            t.paymentsChooseMethod,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 10.h),
          for (final m in notifier.supportedMethods) ...[
            PaymentMethodTile(
              method: m,
              selected: state.selectedMethod == m.type,
              onTap: () => notifier.selectMethod(m.type),
            ),
            SizedBox(height: 10.h),
          ],
          SizedBox(height: 6.h),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.isProcessing ? null : notifier.goToConfirm,
              child: state.isProcessing
                  ? SizedBox(
                      width: 18.r,
                      height: 18.r,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(t.paymentsContinueCta),
            ),
          ),
        ],
      ),
    );
  }
}
