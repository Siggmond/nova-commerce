import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:nova_commerce/app/theme/app_shadows.dart';
import 'package:nova_commerce/app/theme/app_tokens.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

import '../../domain/entities/payment_method.dart';

class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({
    super.key,
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final title = switch (method.type) {
      PaymentMethodType.stripe => t.paymentsMethodStripe,
      PaymentMethodType.paypal => t.paymentsMethodPaypal,
    };
    final subtitle = switch (method.type) {
      PaymentMethodType.stripe => t.paymentsMethodStripeSubtitle,
      PaymentMethodType.paypal => t.paymentsMethodPaypalSubtitle,
    };
    final borderColor = selected
        ? cs.primary.withValues(alpha: 0.50)
        : cs.outlineVariant.withValues(alpha: 0.42);
    final surfaceColor = selected
        ? cs.primaryContainer.withValues(alpha: 0.14)
        : cs.surface;

    return Material(
      color: surfaceColor,
      shadowColor: AppShadows.shadowColor.withValues(alpha: 0.08),
      elevation: selected ? 1 : 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: BorderSide(color: borderColor, width: selected ? 1.4 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 76.h),
          child: Row(
            children: [
              SizedBox(width: AppSpace.md),
              Container(
                width: AppHitTargets.min,
                height: AppHitTargets.min,
                decoration: BoxDecoration(
                  color: selected
                      ? cs.primary.withValues(alpha: 0.12)
                      : cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(
                    color: selected
                        ? cs.primary.withValues(alpha: 0.22)
                        : cs.outlineVariant.withValues(alpha: 0.28),
                  ),
                ),
                child: Icon(
                  method.type == PaymentMethodType.stripe
                      ? Icons.credit_card
                      : Icons.account_balance_wallet,
                  size: 22.r,
                  color: selected
                      ? cs.primary
                      : cs.onSurface.withValues(alpha: 0.8),
                ),
              ),
              SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: AppSpace.xxs),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.7),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpace.md),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 22.r,
                color: selected
                    ? cs.primary
                    : cs.onSurface.withValues(alpha: 0.45),
              ),
              SizedBox(width: AppSpace.md),
            ],
          ),
        ),
      ),
    );
  }
}
