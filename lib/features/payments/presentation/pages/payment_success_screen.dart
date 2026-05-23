import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nova_commerce/app/router/app_routes.dart';
import 'package:nova_commerce/app/theme/app_tokens.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

import '../state/payment_viewmodel.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key, required this.args});

  final PaymentSuccessArgs args;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(t.paymentsSuccessTitle)),
      body: Center(
        child: Padding(
          padding: AppInsets.state,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 380.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76.r,
                  height: 76.r,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.32),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: cs.primary,
                    size: 42.r,
                  ),
                ),
                SizedBox(height: AppSpace.lg),
                Text(
                  t.paymentsSuccessHeadline,
                  style: tt.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpace.sm),
                Text(
                  t.paymentsOrderIdLabel(args.orderId),
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpace.xl),
                SizedBox(
                  width: double.infinity,
                  height: AppHitTargets.comfortable,
                  child: FilledButton(
                    onPressed: () {
                      context.go(
                        '${AppRoutes.orderSuccess}/${args.orderId}',
                        extra: args.summary,
                      );
                    },
                    child: Text(t.paymentsViewOrderCta),
                  ),
                ),
                SizedBox(height: AppSpace.sm),
                SizedBox(
                  width: double.infinity,
                  height: AppHitTargets.comfortable,
                  child: OutlinedButton(
                    onPressed: () => context.go(AppRoutes.orders),
                    child: Text(t.paymentsViewOrdersCta),
                  ),
                ),
                SizedBox(height: AppSpace.sm),
                SizedBox(
                  width: double.infinity,
                  height: AppHitTargets.comfortable,
                  child: OutlinedButton(
                    onPressed: () => context.go(AppRoutes.home),
                    child: Text(t.paymentsContinueShoppingCta),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
