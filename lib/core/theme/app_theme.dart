import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static const Color _brandPrimary = Color(0xFF6D5EF6);

  static const Color _lightScaffold = Color(0xFFF7F7FA);
  static const Color _lightSurface = Color(0xFFFCFCFD);
  static const Color _lightSurfaceLow = Color(0xFFF5F6FA);
  static const Color _lightSurfaceHigh = Color(0xFFEFF1F6);
  static const Color _lightSurfaceHighest = Color(0xFFE9ECF3);

  static const Color _darkScaffold = Color(0xFF0F1115);
  static const Color _darkSurface = Color(0xFF141821);
  static const Color _darkSurfaceLow = Color(0xFF191E28);
  static const Color _darkSurfaceHigh = Color(0xFF202634);
  static const Color _darkSurfaceHighest = Color(0xFF262D3D);

  static const double _defaultLineHeight = 1.15;

  static TextStyle? _down(TextStyle? style, double delta) {
    if (style == null) return null;
    final size = style.fontSize;
    if (size == null) return style;
    return style.copyWith(fontSize: size - delta);
  }

  static TextStyle? _withHeight(TextStyle? style) {
    if (style == null) return null;
    return style.copyWith(height: _defaultLineHeight);
  }

  static TextTheme _withDefaultLineHeights(TextTheme t) {
    return t.copyWith(
      displayLarge: _withHeight(t.displayLarge),
      displayMedium: _withHeight(t.displayMedium),
      displaySmall: _withHeight(t.displaySmall),
      headlineLarge: _withHeight(t.headlineLarge),
      headlineMedium: _withHeight(t.headlineMedium),
      headlineSmall: _withHeight(t.headlineSmall),
      titleLarge: _withHeight(t.titleLarge),
      titleMedium: _withHeight(t.titleMedium),
      titleSmall: _withHeight(t.titleSmall),
      bodyLarge: _withHeight(t.bodyLarge),
      bodyMedium: _withHeight(t.bodyMedium),
      bodySmall: _withHeight(t.bodySmall),
      labelLarge: _withHeight(t.labelLarge),
      labelMedium: _withHeight(t.labelMedium),
      labelSmall: _withHeight(t.labelSmall),
    );
  }

  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: _brandPrimary,
          brightness: Brightness.light,
        ).copyWith(
          primary: _brandPrimary,
          surface: _lightSurface,
          surfaceContainerLow: _lightSurfaceLow,
          surfaceContainerHigh: _lightSurfaceHigh,
          surfaceContainerHighest: _lightSurfaceHighest,
        );

    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: scheme,
    );

    final baseText = _withDefaultLineHeights(base.textTheme);
    final denseText = baseText.copyWith(
      headlineSmall: _down(baseText.headlineSmall, 2),
      titleLarge: _down(baseText.titleLarge, 2),
      titleMedium: _down(baseText.titleMedium, 2),
      titleSmall: _down(baseText.titleSmall, 1),
      bodyLarge: _down(baseText.bodyLarge, 2),
      bodyMedium: baseText.bodySmall,
    );

    return base.copyWith(
      scaffoldBackgroundColor: _lightScaffold,
      appBarTheme: AppBarTheme(
        backgroundColor: _lightScaffold,
        surfaceTintColor: _lightScaffold,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: denseText.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: base.colorScheme.onSurface,
        ),
      ),
      textTheme: denseText.copyWith(
        headlineSmall: denseText.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleLarge: denseText.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleMedium: denseText.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        labelLarge: denseText.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: -0.1,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1.5,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        color: base.colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          textStyle: denseText.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999.r),
        ),
        labelStyle: denseText.labelSmall,
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
        labelPadding: EdgeInsets.symmetric(horizontal: 3.w),
        selectedColor: base.colorScheme.primary.withValues(alpha: 0.10),
        side: BorderSide(
          color: base.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? base.colorScheme.primary
              : null,
        ),
        checkColor: WidgetStatePropertyAll(base.colorScheme.onPrimary),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? base.colorScheme.primary
              : null,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? base.colorScheme.primary
              : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? base.colorScheme.primary.withValues(alpha: 0.40)
              : null,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 60.h,
        elevation: 1,
        indicatorColor: base.colorScheme.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStatePropertyAll(
          denseText.labelSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected
                ? base.colorScheme.primary
                : base.colorScheme.onSurface.withValues(alpha: 0.75),
          );
        }),
      ),
    );
  }

  static ThemeData get dark {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: _brandPrimary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: _brandPrimary.withValues(alpha: 0.92),
          surface: _darkSurface,
          surfaceContainerLow: _darkSurfaceLow,
          surfaceContainerHigh: _darkSurfaceHigh,
          surfaceContainerHighest: _darkSurfaceHighest,
        );

    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: scheme,
    );

    final baseText = _withDefaultLineHeights(base.textTheme);
    final denseText = baseText.copyWith(
      headlineSmall: _down(baseText.headlineSmall, 2),
      titleLarge: _down(baseText.titleLarge, 2),
      titleMedium: _down(baseText.titleMedium, 2),
      titleSmall: _down(baseText.titleSmall, 1),
      bodyLarge: _down(baseText.bodyLarge, 2),
      bodyMedium: baseText.bodySmall,
    );

    return base.copyWith(
      scaffoldBackgroundColor: _darkScaffold,
      appBarTheme: AppBarTheme(
        backgroundColor: _darkScaffold,
        surfaceTintColor: _darkScaffold,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: denseText.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: base.colorScheme.onSurface,
        ),
      ),
      textTheme: denseText.copyWith(
        headlineSmall: denseText.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleLarge: denseText.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleMedium: denseText.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        labelLarge: denseText.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: -0.1,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1.5,
        shadowColor: Colors.black.withValues(alpha: 0.28),
        color: base.colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          textStyle: denseText.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999.r),
        ),
        labelStyle: denseText.labelSmall,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
        selectedColor: base.colorScheme.primary.withValues(alpha: 0.16),
        side: BorderSide(
          color: base.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? base.colorScheme.primary
              : null,
        ),
        checkColor: WidgetStatePropertyAll(base.colorScheme.onPrimary),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? base.colorScheme.primary
              : null,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? base.colorScheme.primary
              : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? base.colorScheme.primary.withValues(alpha: 0.42)
              : null,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 60.h,
        elevation: 1,
        indicatorColor: base.colorScheme.primary.withValues(alpha: 0.14),
        labelTextStyle: WidgetStatePropertyAll(
          denseText.labelSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected
                ? base.colorScheme.primary
                : base.colorScheme.onSurface.withValues(alpha: 0.78),
          );
        }),
      ),
    );
  }
}
