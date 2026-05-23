import 'package:flutter/material.dart';

import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_tokens.dart';
import '../../app/theme/nova_tokens.dart';

class NovaSurface extends StatelessWidget {
  const NovaSurface({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius,
    this.elevation = 0,
    this.clipBehavior = Clip.antiAlias,
    this.shadowColor,
    this.borderSide,
  });

  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final double? borderRadius;
  final double elevation;
  final Clip clipBehavior;
  final Color? shadowColor;
  final BorderSide? borderSide;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: color ?? NovaColors.sheet(cs),
      elevation: elevation,
      shadowColor:
          shadowColor ?? AppShadows.shadowColor.withValues(alpha: 0.08),
      surfaceTintColor: Colors.transparent,
      clipBehavior: clipBehavior,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadii.lg),
        side:
            borderSide ??
            BorderSide(color: cs.outlineVariant.withValues(alpha: 0.36)),
      ),
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );
  }
}
