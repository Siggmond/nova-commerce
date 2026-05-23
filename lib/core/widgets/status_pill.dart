import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_tokens.dart';

enum StatusPillVariant { success, neutral }

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.variant = StatusPillVariant.neutral,
  });

  final String label;
  final StatusPillVariant variant;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (bg, border, fg) = switch (variant) {
      StatusPillVariant.success => (
        cs.primary.withValues(alpha: 0.10),
        cs.primary.withValues(alpha: 0.22),
        cs.primary,
      ),
      StatusPillVariant.neutral => (
        cs.surfaceContainerHighest.withValues(alpha: 0.20),
        cs.onSurface.withValues(alpha: 0.14),
        cs.onSurface.withValues(alpha: 0.75),
      ),
    };

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 32.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: fg,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
