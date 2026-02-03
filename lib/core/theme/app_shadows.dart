import 'package:flutter/material.dart';

class AppShadows {
  static final Color _shadowColor = Colors.black.withValues(alpha: 0.14);
  static Color get shadowColor => _shadowColor;

  static final List<BoxShadow> _smDefault = [
    BoxShadow(
      color: _shadowColor.withValues(alpha: 0.10),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> _mdDefault = [
    BoxShadow(
      color: _shadowColor.withValues(alpha: 0.12),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];

  static final List<BoxShadow> _lgDefault = [
    BoxShadow(
      color: _shadowColor.withValues(alpha: 0.14),
      blurRadius: 28,
      offset: const Offset(0, 14),
    ),
  ];

  static final List<BoxShadow> _navBarDefault = [
    BoxShadow(
      color: _shadowColor.withValues(alpha: 0.10),
      blurRadius: 24,
      offset: const Offset(0, -10),
    ),
  ];

  static List<BoxShadow> sm({Color? color}) {
    if (color == null) return _smDefault;
    final c = color;
    return [
      BoxShadow(
        color: c.withValues(alpha: 0.10),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static List<BoxShadow> md({Color? color}) {
    if (color == null) return _mdDefault;
    final c = color;
    return [
      BoxShadow(
        color: c.withValues(alpha: 0.12),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static List<BoxShadow> lg({Color? color}) {
    if (color == null) return _lgDefault;
    final c = color;
    return [
      BoxShadow(
        color: c.withValues(alpha: 0.14),
        blurRadius: 28,
        offset: const Offset(0, 14),
      ),
    ];
  }

  static List<BoxShadow> navBar({Color? color}) {
    if (color == null) return _navBarDefault;
    final c = color;
    return [
      BoxShadow(
        color: c.withValues(alpha: 0.10),
        blurRadius: 24,
        offset: const Offset(0, -10),
      ),
    ];
  }
}
