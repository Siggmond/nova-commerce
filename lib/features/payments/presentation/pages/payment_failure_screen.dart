import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nova_commerce/app/theme/app_tokens.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

class PaymentFailureScreen extends StatelessWidget {
  const PaymentFailureScreen({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(t.paymentsFailureTitle)),
      body: Center(
        child: Padding(
          padding: AppInsets.state,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 380.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72.r,
                  height: 72.r,
                  decoration: BoxDecoration(
                    color: cs.errorContainer.withValues(alpha: 0.36),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    border: Border.all(color: cs.error.withValues(alpha: 0.20)),
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: cs.error,
                    size: 38.r,
                  ),
                ),
                SizedBox(height: AppSpace.lg),
                Text(
                  kDebugMode && message.trim().isNotEmpty
                      ? message
                      : t.paymentsFailureBody,
                  textAlign: TextAlign.center,
                  style: tt.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: AppSpace.xl),
                SizedBox(
                  width: double.infinity,
                  height: AppHitTargets.comfortable,
                  child: FilledButton(
                    onPressed: () => context.pop(),
                    child: Text(t.commonBack),
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
