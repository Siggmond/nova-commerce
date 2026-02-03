import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_env.dart';
import '../../data/repositories/fake_auth_repository.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppEnv.useFakeRepos) {
    return FakeAuthRepository();
  }

  final firebaseConfigured = Firebase.apps.isNotEmpty;
  if (!firebaseConfigured) {
    throw StateError('Firebase is not configured.');
  }

  return FirebaseAuthRepository(ref.read(firebaseAuthProvider));
});

final authUserProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentUidProvider = Provider<String?>((ref) {
  return ref
      .watch(authUserProvider)
      .maybeWhen(data: (user) => user?.uid, orElse: () => null);
});
