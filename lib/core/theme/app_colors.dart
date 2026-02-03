import 'package:flutter/material.dart';

extension AppColorsX on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;
}

class AppColors {
  static const List<Color> categoryChipPalette = [
    Color(0xFF2F6BFF),
    Color(0xFFE91E63),
    Color(0xFF00BFA6),
    Color(0xFFFF8A00),
    Color(0xFF7C4DFF),
    Color(0xFFFF3B30),
    Color(0xFF00A3FF),
    Color(0xFF43A047),
  ];
}
