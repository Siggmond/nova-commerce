import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'app.dart';
import 'core/config/app_env.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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

  runApp(const ProviderScope(child: NovaCommerceApp()));
}
