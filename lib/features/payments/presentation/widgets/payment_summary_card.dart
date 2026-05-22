import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: cs.outline.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.paymentsSummaryTitle,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 10.h),
          _row(
            tt,
            label: t.paymentsSummaryItems,
            value: '${summary.items.length}',
          ),
          SizedBox(height: 6.h),
          _row(
            tt,
            label: t.paymentsSummarySubtotal,
            value: '$currency ${summary.subtotal.toStringAsFixed(0)}',
          ),
          SizedBox(height: 6.h),
          _row(
            tt,
            label: t.paymentsSummaryShipping,
            value: summary.shippingFee <= 0
                ? t.paymentsSummaryFree
                : '$currency ${summary.shippingFee.toStringAsFixed(0)}',
          ),
          SizedBox(height: 10.h),
          Divider(height: 1, color: cs.outline.withValues(alpha: 0.25)),
          SizedBox(height: 10.h),
          _row(
            tt,
            label: t.paymentsSummaryTotal,
            value: '$currency ${summary.total.toStringAsFixed(0)}',
            strong: true,
          ),
        ],
      ),
    );
  }

  Widget _row(
    TextTheme tt, {
    required String label,
    required String value,
    bool strong = false,
  }) {
    final style = strong
        ? tt.titleMedium?.copyWith(fontWeight: FontWeight.w900)
        : tt.bodyMedium;

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}
