import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_tokens.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.actionText,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: AppInsets.state,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.r,
              height: 64.r,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.32),
                ),
              ),
              child: Icon(
                icon,
                size: 30.r,
                color: cs.onSurface.withValues(alpha: 0.66),
              ),
            ),
            SizedBox(height: AppSpace.md),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpace.xs),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 360.w),
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.72),
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (actionText != null && onAction != null) ...[
              SizedBox(height: AppSpace.lg),
              AppButton.primary(label: actionText!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
