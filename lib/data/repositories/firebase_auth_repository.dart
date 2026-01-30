import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/auth_account_details.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  @override
  Stream<AuthUser?> authStateChanges() {
    return _auth.authStateChanges().map(_mapUser);
  }

  @override
  AuthUser? get currentUser => _mapUser(_auth.currentUser);

  @override
  Future<AuthAccountDetails?> getAccountDetails() async {
    return _mapDetails(_auth.currentUser);
  }

  @override
  Future<AuthAccountDetails?> reloadAccountDetails() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      await user.reload();
      return _mapDetails(_auth.currentUser);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? e.code, code: e.code);
    }
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthException(message: 'Not signed in');
      }
      await user.updateDisplayName(displayName);
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? e.code, code: e.code);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthException(message: 'Not signed in');
      }
      await user.sendEmailVerification();
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? e.code, code: e.code);
    }
  }

  @override
  Future<PhoneVerificationSession> startPhoneVerification({
    required String phoneNumber,
  }) async {
    final completer = Completer<PhoneVerificationSession>();
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthException(message: 'Not signed in');
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          // Auto-retrieval on some devices; verify immediately.
          try {
            await user.updatePhoneNumber(credential);
            await user.reload();
            if (!completer.isCompleted) {
              completer.complete(
                const PhoneVerificationSession(verificationId: ''),
              );
            }
          } on FirebaseAuthException catch (e) {
            if (!completer.isCompleted) {
              completer.completeError(
                AuthException(message: e.message ?? e.code, code: e.code),
              );
            }
          }
        },
        verificationFailed: (e) {
          if (completer.isCompleted) return;
          completer.completeError(
            AuthException(message: e.message ?? e.code, code: e.code),
          );
        },
        codeSent: (verificationId, __) {
          if (completer.isCompleted) return;
          completer.complete(
            PhoneVerificationSession(verificationId: verificationId),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {
          if (completer.isCompleted) return;
          // Still allow manual entry.
          completer.complete(
            PhoneVerificationSession(verificationId: verificationId),
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      if (!completer.isCompleted) {
        completer.completeError(
          AuthException(message: e.message ?? e.code, code: e.code),
        );
      }
    }

    return completer.future;
  }

  @override
  Future<void> linkPhoneWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthException(message: 'Not signed in');
      }
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await user.updatePhoneNumber(credential);
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? e.code, code: e.code);
    }
  }

  @override
  Future<AuthUser> createAccount({
    required String email,
    required String password,
  }) async {
    try {
      final current = _auth.currentUser;
      if (current != null && current.isAnonymous) {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        final result = await current.linkWithCredential(credential);
        return _requireUser(result.user);
      }

      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _requireUser(result.user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? e.code, code: e.code);
    }
  }

  @override
  Future<AuthUser> signInEmail({
    required String email,
    required String password,
  }) async {
    try {
      final current = _auth.currentUser;
      if (current != null && current.isAnonymous) {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        try {
          final result = await current.linkWithCredential(credential);
          return _requireUser(result.user);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use') {
            final result = await _auth.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
            return _requireUser(result.user);
          }
          rethrow;
        }
      }

      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _requireUser(result.user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? e.code, code: e.code);
    }
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw const AuthException(message: 'Google sign-in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final current = _auth.currentUser;
      if (current != null && current.isAnonymous) {
        try {
          final result = await current.linkWithCredential(credential);
          return _requireUser(result.user);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use') {
            final result = await _auth.signInWithCredential(credential);
            return _requireUser(result.user);
          }
          rethrow;
        }
      }

      final result = await _auth.signInWithCredential(credential);
      return _requireUser(result.user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? e.code, code: e.code);
    }
  }

  @override
  Future<AuthUser> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      return _requireUser(result.user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? e.code, code: e.code);
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  String? takeFallbackNotice() => null;

  AuthUser _requireUser(User? user) {
    final mapped = _mapUser(user);
    if (mapped == null) {
      throw const AuthException(message: 'Auth user unavailable');
    }
    return mapped;
  }

  AuthUser? _mapUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email,
      isAnonymous: user.isAnonymous,
      isDemo: false,
    );
  }

  AuthAccountDetails? _mapDetails(User? user) {
    if (user == null) return null;

    final displayName = (user.displayName ?? '').trim();
    final phone = (user.phoneNumber ?? '').trim();

    return AuthAccountDetails(
      uid: user.uid,
      displayName: displayName,
      email: user.email,
      isEmailVerified: user.emailVerified,
      phoneNumber: phone.isEmpty ? null : phone,
      isPhoneVerified: phone.isNotEmpty,
      isAnonymous: user.isAnonymous,
      isDemo: false,
    );
  }
}
