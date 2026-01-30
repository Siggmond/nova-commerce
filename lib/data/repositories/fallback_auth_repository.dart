import 'dart:async';

import '../../domain/entities/auth_account_details.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'fake_auth_repository.dart';

class FallbackAuthRepository implements AuthRepository {
  FallbackAuthRepository({
    required AuthRepository primary,
    required FakeAuthRepository fallback,
  }) : _primary = primary,
       _fallback = fallback;

  final _authStateController = StreamController<AuthUser?>.broadcast();
  StreamSubscription<AuthUser?>? _authStateSub;
  bool _authStateInitialized = false;

  final AuthRepository _primary;
  final FakeAuthRepository _fallback;
  bool _useFallback = false;

  static const _fallbackMessage =
      'Auth not configured on this build — using demo account mode.';

  void _ensureAuthStateSubscribed() {
    if (_authStateInitialized) return;
    _authStateInitialized = true;
    _attachAuthState(_primary);
  }

  void _attachAuthState(AuthRepository repo) {
    _authStateSub?.cancel();
    _authStateSub = repo.authStateChanges().listen(
      _authStateController.add,
      onError: _authStateController.addError,
    );
  }

  @override
  Stream<AuthUser?> authStateChanges() async* {
    _ensureAuthStateSubscribed();
    yield currentUser;
    yield* _authStateController.stream;
  }

  @override
  AuthUser? get currentUser =>
      _useFallback ? _fallback.currentUser : _primary.currentUser;

  @override
  Future<AuthAccountDetails?> getAccountDetails() {
    return _useFallback
        ? _fallback.getAccountDetails()
        : _primary.getAccountDetails();
  }

  @override
  Future<AuthAccountDetails?> reloadAccountDetails() {
    return _useFallback
        ? _fallback.reloadAccountDetails()
        : _primary.reloadAccountDetails();
  }

  @override
  Future<void> updateDisplayName(String displayName) {
    return _useFallback
        ? _fallback.updateDisplayName(displayName)
        : _primary.updateDisplayName(displayName);
  }

  @override
  Future<void> sendEmailVerification() {
    return _useFallback
        ? _fallback.sendEmailVerification()
        : _primary.sendEmailVerification();
  }

  @override
  Future<PhoneVerificationSession> startPhoneVerification({
    required String phoneNumber,
  }) {
    return _useFallback
        ? _fallback.startPhoneVerification(phoneNumber: phoneNumber)
        : _primary.startPhoneVerification(phoneNumber: phoneNumber);
  }

  @override
  Future<void> linkPhoneWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) {
    return _useFallback
        ? _fallback.linkPhoneWithSmsCode(
            verificationId: verificationId,
            smsCode: smsCode,
          )
        : _primary.linkPhoneWithSmsCode(
            verificationId: verificationId,
            smsCode: smsCode,
          );
  }

  @override
  Future<AuthUser> createAccount({
    required String email,
    required String password,
  }) async {
    return _guard(
      () => _primary.createAccount(email: email, password: password),
    );
  }

  @override
  Future<AuthUser> signInEmail({
    required String email,
    required String password,
  }) async {
    return _guard(() => _primary.signInEmail(email: email, password: password));
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    return _guard(() => _primary.signInWithGoogle());
  }

  @override
  Future<AuthUser> signInAnonymously() async {
    return _guard(() => _primary.signInAnonymously());
  }

  @override
  Future<void> signOut() async {
    if (_useFallback) {
      await _fallback.signOut();
      return;
    }
    await _primary.signOut();
  }

  @override
  String? takeFallbackNotice() => _fallback.takeFallbackNotice();

  Future<AuthUser> _guard(Future<AuthUser> Function() action) async {
    if (_useFallback) {
      return _fallback.signInAnonymously();
    }
    try {
      return await action();
    } on AuthException catch (e) {
      if (_shouldFallback(e)) {
        final user = await _fallback.signInAnonymously();
        _useFallback = true;
        _fallback.setFallbackNotice(_fallbackMessage);

        _ensureAuthStateSubscribed();
        _attachAuthState(_fallback);
        _authStateController.add(user);
        return user;
      }
      rethrow;
    }
  }

  bool _shouldFallback(AuthException e) {
    final message = e.message.toLowerCase();
    final code = (e.code ?? '').toLowerCase();
    return code == 'invalid-api-key' ||
        message.contains('api key not valid') ||
        message.contains('api-key') && message.contains('not valid');
  }
}
