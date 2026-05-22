import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../firebase_options.dart';
import '../core/images/image_cache_budget.dart';
import '../core/telemetry/telemetry.dart';
import 'config/app_env.dart';
import 'config/responsive_text_scale.dart';

void _debugLog(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}

Future<Telemetry?> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  NovaImageCacheBudget.applyDefaults();

  _debugLog('DART main start: kIsWeb=$kIsWeb platform=$defaultTargetPlatform');

  _debugLog('DART Firebase.apps BEFORE init: ${Firebase.apps}');

  const bool skipFirebaseInit = bool.fromEnvironment(
    'SKIP_FIREBASE_INIT',
    defaultValue: false,
  );

  _debugLog('DART SKIP_FIREBASE_INIT=$skipFirebaseInit');

  final Telemetry telemetry = NoopTelemetry();
  var firebaseReady = false;

  if (AppEnv.enableTelemetry) {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);

      final st = details.stack ?? StackTrace.current;

      telemetry.recordError(details.exception, st, fatal: true);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      telemetry.recordError(error, stack, fatal: true);

      return false;
    };
  }

  if (!skipFirebaseInit) {
    final bool isAndroid =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

    try {
      if (isAndroid) {
        await Firebase.initializeApp();
      } else {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      firebaseReady = true;
    } on UnsupportedError catch (e) {
      runApp(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          minTextAdapt: true,
          splitScreenMode: true,
          fontSizeResolver: ResponsiveTextScale.resolveSp,
          builder: (context, child) {
            return MaterialApp(
              home: Scaffold(
                body: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(20.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Firebase is not configured for this platform.',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          e.message ?? e.toString(),
                          style: const TextStyle(height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );

      return null;
    } catch (e, st) {
      _debugLog(
        'DART Firebase.initializeApp failed; continuing without Firebase. error=$e',
      );
      if (kDebugMode) {
        debugPrintStack(stackTrace: st);
      }
    }
  }

  if (firebaseReady && !kIsWeb) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  }

  if (firebaseReady && !kReleaseMode && AppEnv.useFirestoreEmulator) {
    final host =
        (!kIsWeb &&
            defaultTargetPlatform == TargetPlatform.android &&
            AppEnv.firestoreHost == 'localhost')
        ? '10.0.2.2'
        : AppEnv.firestoreHost;

    FirebaseFirestore.instance.useFirestoreEmulator(host, AppEnv.firestorePort);

    await FirebaseAuth.instance.useAuthEmulator(host, AppEnv.authPort);
  }

  return telemetry;
}
