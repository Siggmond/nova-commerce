import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/responsive_text_scale.dart';
import 'app_shadows.dart';
import 'app_tokens.dart';

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
  static const List<String> _localizedFontFallbacks = <String>[
    'Noto Sans Arabic',
    'Noto Naskh Arabic',
    'Roboto',
    'Arial',
  ];

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

  static TextStyle? _withScaledFont(TextStyle? style, double factor) {
    if (style == null) return null;
    final size = style.fontSize;
    if (size == null) return style;
    return style.copyWith(fontSize: size * factor);
  }

  static TextStyle? _withLocalizedFallbacks(TextStyle? style) {
    if (style == null) return null;
    return style.copyWith(fontFamilyFallback: _localizedFontFallbacks);
  }

  static TextStyle? _primaryTextStyle(TextStyle? style) {
    if (style == null) return null;
    return _withLocalizedFallbacks(
      GoogleFonts.plusJakartaSans(textStyle: style),
    );
  }

  static TextTheme _withLocalizedFallbackText(TextTheme t) {
    return t.copyWith(
      displayLarge: _withLocalizedFallbacks(t.displayLarge),
      displayMedium: _withLocalizedFallbacks(t.displayMedium),
      displaySmall: _withLocalizedFallbacks(t.displaySmall),
      headlineLarge: _withLocalizedFallbacks(t.headlineLarge),
      headlineMedium: _withLocalizedFallbacks(t.headlineMedium),
      headlineSmall: _withLocalizedFallbacks(t.headlineSmall),
      titleLarge: _withLocalizedFallbacks(t.titleLarge),
      titleMedium: _withLocalizedFallbacks(t.titleMedium),
      titleSmall: _withLocalizedFallbacks(t.titleSmall),
      bodyLarge: _withLocalizedFallbacks(t.bodyLarge),
      bodyMedium: _withLocalizedFallbacks(t.bodyMedium),
      bodySmall: _withLocalizedFallbacks(t.bodySmall),
      labelLarge: _withLocalizedFallbacks(t.labelLarge),
      labelMedium: _withLocalizedFallbacks(t.labelMedium),
      labelSmall: _withLocalizedFallbacks(t.labelSmall),
    );
  }

  static TextTheme _primaryTextTheme(TextTheme t) {
    return _withLocalizedFallbackText(GoogleFonts.plusJakartaSansTextTheme(t));
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

  static TextTheme _withResponsiveFontScale(TextTheme t) {
    final su = ScreenUtil();
    final scale = (su.scaleText * ResponsiveTextScale.screenUtilFactor(su))
        .clamp(0.80, 1.08);
    return t.copyWith(
      displayLarge: _withScaledFont(t.displayLarge, scale),
      displayMedium: _withScaledFont(t.displayMedium, scale),
      displaySmall: _withScaledFont(t.displaySmall, scale),
      headlineLarge: _withScaledFont(t.headlineLarge, scale),
      headlineMedium: _withScaledFont(t.headlineMedium, scale),
      headlineSmall: _withScaledFont(t.headlineSmall, scale),
      titleLarge: _withScaledFont(t.titleLarge, scale),
      titleMedium: _withScaledFont(t.titleMedium, scale),
      titleSmall: _withScaledFont(t.titleSmall, scale),
      bodyLarge: _withScaledFont(t.bodyLarge, scale),
      bodyMedium: _withScaledFont(t.bodyMedium, scale),
      bodySmall: _withScaledFont(t.bodySmall, scale),
      labelLarge: _withScaledFont(t.labelLarge, scale),
      labelMedium: _withScaledFont(t.labelMedium, scale),
      labelSmall: _withScaledFont(t.labelSmall, scale),
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

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);

    final baseText = _withDefaultLineHeights(base.textTheme);
    final denseBaseText = baseText.copyWith(
      headlineSmall: _down(baseText.headlineSmall, 2),
      titleLarge: _down(baseText.titleLarge, 2),
      titleMedium: _down(baseText.titleMedium, 2),
      titleSmall: _down(baseText.titleSmall, 1),
      bodyLarge: _down(baseText.bodyLarge, 2),
      bodyMedium: baseText.bodySmall,
    );
    final denseText = _withResponsiveFontScale(denseBaseText);
    final appText = _primaryTextTheme(
      denseText.copyWith(
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
    );

    return base.copyWith(
      scaffoldBackgroundColor: _lightScaffold,
      appBarTheme: AppBarTheme(
        backgroundColor: _lightScaffold,
        surfaceTintColor: _lightScaffold,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: _primaryTextStyle(
          denseText.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: base.colorScheme.onSurface,
          ),
        ),
      ),
      textTheme: appText,
      cardTheme: CardThemeData(
        elevation: AppElevation.card,
        shadowColor: AppShadows.shadowColor.withValues(alpha: 0.08),
        color: base.colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: Size(0, AppHitTargets.min),
          padding: AppInsets.button,
          tapTargetSize: MaterialTapTargetSize.padded,
          visualDensity: VisualDensity.standard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle: _primaryTextStyle(
            denseText.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        labelStyle: appText.labelSmall,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpace.sm,
          vertical: AppSpace.xxs,
        ),
        labelPadding: EdgeInsets.symmetric(horizontal: AppSpace.xxs),
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
          appText.labelSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22.r,
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

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);

    final baseText = _withDefaultLineHeights(base.textTheme);
    final denseBaseText = baseText.copyWith(
      headlineSmall: _down(baseText.headlineSmall, 2),
      titleLarge: _down(baseText.titleLarge, 2),
      titleMedium: _down(baseText.titleMedium, 2),
      titleSmall: _down(baseText.titleSmall, 1),
      bodyLarge: _down(baseText.bodyLarge, 2),
      bodyMedium: baseText.bodySmall,
    );
    final denseText = _withResponsiveFontScale(denseBaseText);
    final appText = _primaryTextTheme(
      denseText.copyWith(
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
    );

    return base.copyWith(
      scaffoldBackgroundColor: _darkScaffold,
      appBarTheme: AppBarTheme(
        backgroundColor: _darkScaffold,
        surfaceTintColor: _darkScaffold,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: _primaryTextStyle(
          denseText.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: base.colorScheme.onSurface,
          ),
        ),
      ),
      textTheme: appText,
      cardTheme: CardThemeData(
        elevation: AppElevation.card,
        shadowColor: AppShadows.shadowColor.withValues(alpha: 0.18),
        color: base.colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: Size(0, AppHitTargets.min),
          padding: AppInsets.button,
          tapTargetSize: MaterialTapTargetSize.padded,
          visualDensity: VisualDensity.standard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle: _primaryTextStyle(
            denseText.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        labelStyle: appText.labelSmall,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpace.sm,
          vertical: AppSpace.xxs,
        ),
        labelPadding: EdgeInsets.symmetric(horizontal: AppSpace.xxs),
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
          appText.labelSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22.r,
            color: selected
                ? base.colorScheme.primary
                : base.colorScheme.onSurface.withValues(alpha: 0.78),
          );
        }),
      ),
    );
  }
}
