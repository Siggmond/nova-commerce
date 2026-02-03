import 'package:flutter/material.dart';

extension AppTypographyX on BuildContext {
  TextTheme get appText => Theme.of(this).textTheme;

  TextStyle? get h1 => appText.headlineSmall;
  TextStyle? get h2 => appText.titleLarge;
  TextStyle? get h3 => appText.titleMedium;

  TextStyle? get body => appText.bodyMedium;
  TextStyle? get bodyStrong =>
      appText.bodyMedium?.copyWith(fontWeight: FontWeight.w700);

  TextStyle? get label => appText.labelLarge;
}
