import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shadows.dart';

class HomeFilterChipStyle {
  static Color baseColor({required int index}) {
    final palette = AppColors.categoryChipPalette;
    return palette[index % palette.length];
  }

  static Color borderColor({
    required ColorScheme cs,
    required int index,
    required bool selected,
  }) {
    final base = baseColor(index: index);
    final overlay = cs.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.03);
    final c = Color.alphaBlend(overlay, base);
    return c.withValues(alpha: selected ? 0.72 : 0.60);
  }

  static Color fillColor({
    required ColorScheme cs,
    required int index,
    required bool selected,
  }) {
    if (selected) {
      final base = baseColor(index: index);
      final tint = base.withValues(
        alpha: cs.brightness == Brightness.dark ? 0.22 : 0.14,
      );
      return Color.alphaBlend(tint, cs.surface);
    }
    return cs.surfaceContainerHigh.withValues(
      alpha: cs.brightness == Brightness.dark ? 0.50 : 0.72,
    );
  }

  static List<BoxShadow> shadows({
    required ColorScheme cs,
    required int index,
    required bool selected,
    bool enabled = true,
  }) {
    if (!enabled) return const <BoxShadow>[];
    final base = baseColor(index: index);
    final tint = base.withValues(alpha: selected ? 0.18 : 0.10);
    return selected ? AppShadows.md(color: tint) : AppShadows.sm(color: tint);
  }

  static TextStyle? labelStyle({
    required BuildContext context,
    required ColorScheme cs,
    required int index,
    required bool selected,
  }) {
    final base = baseColor(index: index);
    final c = selected
        ? Color.alphaBlend(base.withValues(alpha: 0.10), cs.onSurface)
        : cs.onSurface.withValues(alpha: 0.86);

    return Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, color: c);
  }
}
