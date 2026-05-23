import 'package:flutter/material.dart';

import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_tokens.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      elevation: AppElevation.card,
      shadowColor: AppShadows.shadowColor.withValues(alpha: 0.08),
      surfaceTintColor: Colors.transparent,
      color: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.34)),
      ),
      child: Padding(padding: padding ?? AppInsets.card, child: child),
    );
  }
}
