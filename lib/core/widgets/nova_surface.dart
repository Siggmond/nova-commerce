import 'package:flutter/material.dart';

import '../theme/app_shadows.dart';
import '../theme/nova_tokens.dart';

class NovaSurface extends StatelessWidget {
  const NovaSurface({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: color ?? NovaColors.sheet(cs),
      elevation: 1,
      shadowColor: AppShadows.shadowColor.withValues(alpha: 0.12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? NovaRadii.radius16),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.25)),
      ),
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );
  }
}
