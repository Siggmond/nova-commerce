import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../domain/entities/auth_account_details.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository() : _current = null;

  final _controller = StreamController<AuthUser?>.broadcast();
  final _uuid = const Uuid();
  AuthUser? _current;
  String? _fallbackNotice;

  String _displayName = '';
  bool _emailVerified = false;
  String? _phoneNumber;
  String? _lastVerificationId;

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  AuthUser? get currentUser => _current;

  @override
  Future<AuthAccountDetails?> getAccountDetails() async {
    final user = _current;
    if (user == null) return null;
    return AuthAccountDetails(
      uid: user.uid,
      displayName: _displayName,
      email: user.email,
      isEmailVerified: _emailVerified,
      phoneNumber: _phoneNumber,
      isPhoneVerified: _phoneNumber != null,
      isAnonymous: user.isAnonymous,
      isDemo: user.isDemo,
    );
  }

  @override
  Future<AuthAccountDetails?> reloadAccountDetails() async {
    return getAccountDetails();
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    if (_current == null) {
      throw const AuthException(message: 'Not signed in');
    }
    _displayName = displayName;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (_current == null) {
      throw const AuthException(message: 'Not signed in');
    }
    // For fake mode, mark as verified immediately.
    _emailVerified = true;
  }

  @override
  Future<PhoneVerificationSession> startPhoneVerification({
    required String phoneNumber,
  }) async {
    if (_current == null) {
      throw const AuthException(message: 'Not signed in');
    }
    _lastVerificationId = 'ver_${_uuid.v4()}'.substring(0, 10);
    return PhoneVerificationSession(verificationId: _lastVerificationId!);
  }

  @override
  Future<void> linkPhoneWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    if (_current == null) {
      throw const AuthException(message: 'Not signed in');
    }
    if (_lastVerificationId == null || verificationId != _lastVerificationId) {
      throw const AuthException(message: 'Invalid verification session');
    }
    if (smsCode.trim().isEmpty) {
      throw const AuthException(message: 'Invalid code');
    }
    _phoneNumber = '+10000000000';
  }

  @override
  Future<AuthUser> createAccount({
    required String email,
    required String password,
  }) async {
    return _setUser(email: email, isAnonymous: false);
  }

  @override
  Future<AuthUser> signInEmail({
    required String email,
    required String password,
  }) async {
    return _setUser(email: email, isAnonymous: false);
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    return _setUser(email: 'demo@nova.app', isAnonymous: false);
  }

  @override
  Future<AuthUser> signInAnonymously() async {
    return _setUser(email: null, isAnonymous: true);
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }

  @override
  String? takeFallbackNotice() {
    final msg = _fallbackNotice;
    _fallbackNotice = null;
    return msg;
  }

  void setFallbackNotice(String message) {
    _fallbackNotice = message;
  }

  AuthUser _setUser({String? email, required bool isAnonymous}) {
    final user = AuthUser(
      uid: 'demo_${_uuid.v4()}'.substring(0, 12),
      email: email,
      isAnonymous: isAnonymous,
      isDemo: true,
    );
    _current = user;
    _displayName = '';
    _emailVerified = false;
    _phoneNumber = null;
    _lastVerificationId = null;
    _controller.add(user);
    return user;
  }
}
