import '../entities/auth_user.dart';
import '../entities/auth_account_details.dart';

class AuthException implements Exception {
  const AuthException({required this.message, this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

abstract class AuthRepository {
  Stream<AuthUser?> authStateChanges();
  AuthUser? get currentUser;

  Future<AuthAccountDetails?> getAccountDetails();
  Future<AuthAccountDetails?> reloadAccountDetails();

  Future<void> updateDisplayName(String displayName);

  Future<void> sendEmailVerification();

  Future<PhoneVerificationSession> startPhoneVerification({
    required String phoneNumber,
  });

  Future<void> linkPhoneWithSmsCode({
    required String verificationId,
    required String smsCode,
  });

  Future<AuthUser> createAccount({
    required String email,
    required String password,
  });

  Future<AuthUser> signInEmail({
    required String email,
    required String password,
  });

  Future<AuthUser> signInWithGoogle();

  Future<AuthUser> signInAnonymously();

  Future<void> signOut();

  String? takeFallbackNotice();
}
