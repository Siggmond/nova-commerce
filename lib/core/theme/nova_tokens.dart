import 'package:flutter/material.dart';

import 'app_tokens.dart';

class NovaColors {
  static Color canvas(ColorScheme cs) => cs.surface;
  static Color sheet(ColorScheme cs) => cs.surfaceContainerLow;
  static Color sheetStrong(ColorScheme cs) => cs.surfaceContainerHigh;
}

class NovaRadii {
  static double get radius16 => AppRadii.md;
  static double get radius12 => AppRadii.sm;
  static double get radiusPill => AppRadii.pill;
}

class NovaShadows {
  static List<BoxShadow> low(ColorScheme cs) => [
    BoxShadow(
      blurRadius: 18,
      offset: const Offset(0, 10),
      color: Colors.black.withValues(alpha: 0.10),
    ),
  ];
}

class NovaText {
  static TextStyle? title(BuildContext context) => Theme.of(
    context,
  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700);

  static TextStyle? sectionTitle(BuildContext context) => Theme.of(
    context,
  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800);

  static TextStyle? bodyMuted(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: cs.onSurface.withValues(alpha: 0.70),
    );
  }
}
