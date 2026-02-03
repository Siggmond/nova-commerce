import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/foundation.dart';

import 'package:hive_flutter/hive_flutter.dart';

import 'dart:ui';

import 'app.dart';

import 'core/config/app_env.dart';

import 'core/config/providers.dart';

import 'core/telemetry/telemetry.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  debugPrint('DART main start: kIsWeb=$kIsWeb platform=$defaultTargetPlatform');

  debugPrint('DART Firebase.apps BEFORE init: ${Firebase.apps}');

  const bool skipFirebaseInit = bool.fromEnvironment(
    'SKIP_FIREBASE_INIT',

    defaultValue: false,
  );

  debugPrint('DART SKIP_FIREBASE_INIT=$skipFirebaseInit');

  final Telemetry telemetry = NoopTelemetry();

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
    } on UnsupportedError catch (e) {
      runApp(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Firebase is not configured for this platform.',

                      style: const TextStyle(
                        fontSize: 18,

                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      e.message ?? e.toString(),

                      style: const TextStyle(height: 1.3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      return;
    }
  }

  if (!kIsWeb) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  }

  if (!kReleaseMode && AppEnv.useFirestoreEmulator) {
    final host =
        (!kIsWeb &&
            defaultTargetPlatform == TargetPlatform.android &&
            AppEnv.firestoreHost == 'localhost')
        ? '10.0.2.2'
        : AppEnv.firestoreHost;

    FirebaseFirestore.instance.useFirestoreEmulator(host, AppEnv.firestorePort);

    FirebaseAuth.instance.useAuthEmulator(host, AppEnv.authPort);
  }

  try {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  } catch (_) {}

  runApp(
    ProviderScope(
      overrides: [telemetryProvider.overrideWithValue(telemetry)],

      child: const NovaCommerceApp(),
    ),
  );
}
