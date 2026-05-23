import 'package:flutter/material.dart';

import 'package:nova_commerce/app/theme/app_shadows.dart';
import 'package:nova_commerce/app/theme/app_tokens.dart';
import 'package:nova_commerce/features/checkout/domain/checkout_cart_summary.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

class PaymentSummaryCard extends StatelessWidget {
  const PaymentSummaryCard({super.key, required this.summary});

  final CheckoutCartSummary summary;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final currency = summary.currency.toUpperCase();

    return Container(
      padding: AppInsets.card,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.36)),
        boxShadow: AppShadows.sm(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.paymentsSummaryTitle,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          SizedBox(height: AppSpace.md),
          _row(
            tt,
            cs,
            label: t.paymentsSummaryItems,
            value: '${summary.items.length}',
          ),
          SizedBox(height: AppSpace.sm),
          _row(
            tt,
            cs,
            label: t.paymentsSummarySubtotal,
            value: '$currency ${summary.subtotal.toStringAsFixed(0)}',
          ),
          SizedBox(height: AppSpace.sm),
          _row(
            tt,
            cs,
            label: t.paymentsSummaryShipping,
            value: summary.shippingFee <= 0
                ? t.paymentsSummaryFree
                : '$currency ${summary.shippingFee.toStringAsFixed(0)}',
          ),
          SizedBox(height: AppSpace.md),
          Container(
            padding: AppInsets.cardTight,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
            ),
            child: _row(
              tt,
              cs,
              label: t.paymentsSummaryTotal,
              value: '$currency ${summary.total.toStringAsFixed(0)}',
              strong: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    TextTheme tt,
    ColorScheme cs, {
    required String label,
    required String value,
    bool strong = false,
  }) {
    final style = strong
        ? tt.titleMedium?.copyWith(fontWeight: FontWeight.w900, height: 1.15)
        : tt.bodyMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.78),
            height: 1.2,
          );
    final valueStyle = strong
        ? tt.titleLarge?.copyWith(fontWeight: FontWeight.w900, height: 1.1)
        : tt.bodyMedium?.copyWith(fontWeight: FontWeight.w800, height: 1.2);

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: valueStyle),
      ],
    );
  }
}
