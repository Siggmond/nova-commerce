import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nova_commerce/app/router/app_routes.dart';
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
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: cs.primary, size: 56.r),
              SizedBox(height: 12.h),
              Text(
                t.paymentsSuccessHeadline,
                style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                t.paymentsOrderIdLabel(args.orderId),
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
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
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go(AppRoutes.orders),
                  child: Text(t.paymentsViewOrdersCta),
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: Text(t.paymentsContinueShoppingCta),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
