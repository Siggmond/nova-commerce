import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/config/app_router.dart';
import 'core/config/performance_mode.dart';
import 'core/theme/app_theme.dart';

class NovaCommerceApp extends ConsumerWidget {
  const NovaCommerceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'NovaCommerce',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          showPerformanceOverlay: perfEnabled,
          routerConfig: router,
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            final clamped = mq.textScaler.clamp(
              minScaleFactor: 0.90,
              maxScaleFactor: 1.10,
            );
            return MediaQuery(
              data: mq.copyWith(textScaler: clamped),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
