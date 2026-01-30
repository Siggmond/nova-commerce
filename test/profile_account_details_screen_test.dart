import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nova_commerce/core/config/auth_providers.dart';
import 'package:nova_commerce/data/repositories/fake_auth_repository.dart';
import 'package:nova_commerce/domain/entities/auth_account_details.dart';
import 'package:nova_commerce/domain/entities/auth_user.dart';
import 'package:nova_commerce/domain/repositories/auth_repository.dart';
import 'package:nova_commerce/features/profile/presentation/profile_account_details_screen.dart';

class _RecordingAuthRepository implements AuthRepository {
  _RecordingAuthRepository();

  final _controller = StreamController<AuthUser?>.broadcast();

  final bool _emailVerified = false;
  bool _phoneVerified = false;
  String? _phoneNumber;
  String? _lastVerificationId;

  int sendEmailVerificationCalls = 0;
  int reloadCalls = 0;
  int startPhoneVerificationCalls = 0;
  int linkPhoneWithSmsCodeCalls = 0;

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield currentUser;
    yield* _controller.stream;
  }

  @override
  AuthUser? get currentUser => const AuthUser(
        uid: 'u_real',
        email: 'a@b.com',
        isAnonymous: false,
        isDemo: false,
      );

  @override
  Future<AuthAccountDetails?> getAccountDetails() async => _details();

  @override
  Future<AuthAccountDetails?> reloadAccountDetails() async {
    reloadCalls++;
    return _details();
  }

  AuthAccountDetails _details() {
    return AuthAccountDetails(
      uid: 'u_real',
      displayName: 'Alex',
      email: 'a@b.com',
      isEmailVerified: _emailVerified,
      phoneNumber: _phoneNumber,
      isPhoneVerified: _phoneVerified,
      isAnonymous: false,
      isDemo: false,
    );
  }

  @override
  Future<void> updateDisplayName(String displayName) async {}

  @override
  Future<void> sendEmailVerification() async {
    sendEmailVerificationCalls++;
  }

  @override
  Future<PhoneVerificationSession> startPhoneVerification({
    required String phoneNumber,
  }) async {
    startPhoneVerificationCalls++;
    _lastVerificationId = 'ver_123';
    return const PhoneVerificationSession(verificationId: 'ver_123');
  }

  @override
  Future<void> linkPhoneWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    linkPhoneWithSmsCodeCalls++;
    if (verificationId != _lastVerificationId) {
      throw const AuthException(message: 'Invalid verification session');
    }
    if (smsCode.trim().isEmpty) {
      throw const AuthException(message: 'Invalid code');
    }
    _phoneVerified = true;
    _phoneNumber = '+12025550123';
  }

  @override
  Future<AuthUser> createAccount({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> signInEmail({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> signInAnonymously() {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  String? takeFallbackNotice() => null;
}

Future<void> _pumpAccountDetails(
  WidgetTester tester, {
  required AuthRepository repo,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) => const MaterialApp(home: ProfileAccountDetailsScreen()),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxTicks = 20,
}) async {
  for (var i = 0; i < maxTicks && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('Account details shows DEMO badge and demo email verification updates UI', (
    tester,
  ) async {
    final repo = FakeAuthRepository();
    await repo.createAccount(email: 'a@b.com', password: 'pw');

    await _pumpAccountDetails(tester, repo: repo);

    expect(find.text('DEMO'), findsOneWidget);
    expect(find.text('Not verified'), findsWidgets);

    final verifyEmail = find.text('Verify email');
    await tester.ensureVisible(verifyEmail);
    await tester.tap(verifyEmail);
    await tester.pump();

    await _pumpUntilFound(tester, find.text('Verified ✅'));
    expect(find.text('Verified ✅'), findsWidgets);

    // Demo mode immediately verifies, so the verify/resend button disappears.
    expect(find.textContaining('Resend in'), findsNothing);
  });

  testWidgets('Account details triggers non-demo repo calls for email and phone flows', (
    tester,
  ) async {
    final repo = _RecordingAuthRepository();

    await _pumpAccountDetails(tester, repo: repo);

    expect(find.text('DEMO'), findsNothing);

    final verifyEmail = find.text('Verify email');
    await tester.ensureVisible(verifyEmail);
    await tester.tap(verifyEmail);
    await tester.pump();

    expect(repo.sendEmailVerificationCalls, 1);
    expect(repo.reloadCalls, greaterThanOrEqualTo(1));
    final resendLabel = find.textContaining('Resend in');
    await _pumpUntilFound(tester, resendLabel);
    expect(resendLabel, findsOneWidget);

    final phoneField = find.widgetWithText(TextField, 'Phone number');
    await tester.ensureVisible(phoneField);
    await tester.enterText(phoneField, '+12025550123');

    final sendCode = find.text('Send code');
    await tester.tap(sendCode);
    await tester.pump();

    expect(repo.startPhoneVerificationCalls, 1);

    final smsField = find.widgetWithText(TextField, 'SMS code');
    await _pumpUntilFound(tester, smsField);
    expect(smsField, findsOneWidget);

    await tester.enterText(smsField, '123456');
    final verifyPhone = find.text('Verify phone');
    await tester.ensureVisible(verifyPhone);
    await tester.pump();
    await tester.tap(verifyPhone);
    await tester.pump();

    expect(repo.linkPhoneWithSmsCodeCalls, 1);

    await _pumpUntilFound(tester, find.text('Verified ✅'));
    expect(find.text('Verified ✅'), findsWidgets);
  });
}
