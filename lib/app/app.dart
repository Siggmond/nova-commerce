import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

import 'router/app_router.dart';
import 'config/theme_mode_provider.dart';
import 'config/performance_mode.dart';
import 'config/app_locale_provider.dart';
import 'config/responsive_text_scale.dart';
import 'perf/performance_engine.dart';
import 'theme/app_theme.dart';
import '../core/perf/perf_markers.dart';

class NovaCommerceApp extends ConsumerStatefulWidget {
  const NovaCommerceApp({super.key});

  static const bool _logAppBuilds = bool.fromEnvironment(
    'LOG_APP_BUILDS',
    defaultValue: false,
  );

  @override
  ConsumerState<NovaCommerceApp> createState() => _NovaCommerceAppState();
}

class _NovaCommerceAppState extends ConsumerState<NovaCommerceApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      PerfMarkers.firstFrame();
      ref.read(performanceEngineProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final perfEnabled = kDebugMode ? ref.watch(performanceModeProvider) : false;

    if (kDebugMode) {
      ref.listen<bool>(performanceModeProvider, (previous, next) {
        debugProfileBuildsEnabled = next;
        debugProfileLayoutsEnabled = next;
        debugProfilePaintsEnabled = next;
        debugPrintRebuildDirtyWidgets = next;
      });

      debugProfileBuildsEnabled = perfEnabled;
      debugProfileLayoutsEnabled = perfEnabled;
      debugProfilePaintsEnabled = perfEnabled;
      debugPrintRebuildDirtyWidgets = perfEnabled;
    }

    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(appLocaleProvider);

    assert(() {
      if (NovaCommerceApp._logAppBuilds) {
        debugPrint(
          'NovaCommerceApp build: locale=${locale?.languageCode ?? 'system'}',
        );
      }
      return true;
    }());

    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      fontSizeResolver: ResponsiveTextScale.resolveSp,
      builder: (context, child) {
        return MaterialApp.router(
          key: ValueKey<String>('app_${locale?.languageCode ?? 'system'}'),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) return const Locale('en');
            for (final supported in supportedLocales) {
              if (supported.languageCode == locale.languageCode) {
                return supported;
              }
            }
            return const Locale('en');
          },
          onGenerateTitle: (context) =>
              AppLocalizations.of(context)?.appTitle ?? '',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          showPerformanceOverlay: perfEnabled,
          routerConfig: router,
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            final textScaler = ResponsiveTextScale.clampForMediaQuery(mq);
            return MediaQuery(
              data: mq.copyWith(textScaler: textScaler),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
