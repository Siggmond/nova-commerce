import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nova_commerce/core/config/auth_providers.dart';
import 'package:nova_commerce/data/repositories/fallback_auth_repository.dart';
import 'package:nova_commerce/data/repositories/fake_auth_repository.dart';
import 'package:nova_commerce/domain/entities/auth_user.dart';
import 'package:nova_commerce/domain/entities/auth_account_details.dart';
import 'package:nova_commerce/domain/repositories/auth_repository.dart';
import 'package:nova_commerce/features/auth/presentation/sign_in_screen.dart';

class _FailingAuthRepository implements AuthRepository {
  @override
  Stream<AuthUser?> authStateChanges() => const Stream.empty();

  @override
  AuthUser? get currentUser => null;

  @override
  Future<AuthAccountDetails?> getAccountDetails() async => null;

  @override
  Future<AuthAccountDetails?> reloadAccountDetails() async => null;

  @override
  Future<void> updateDisplayName(String displayName) async {
    throw const AuthException(
      message: 'API key not valid',
      code: 'invalid-api-key',
    );
  }

  @override
  Future<void> sendEmailVerification() async {
    throw const AuthException(
      message: 'API key not valid',
      code: 'invalid-api-key',
    );
  }

  @override
  Future<PhoneVerificationSession> startPhoneVerification({
    required String phoneNumber,
  }) async {
    throw const AuthException(
      message: 'API key not valid',
      code: 'invalid-api-key',
    );
  }

  @override
  Future<void> linkPhoneWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    throw const AuthException(
      message: 'API key not valid',
      code: 'invalid-api-key',
    );
  }

  @override
  Future<AuthUser> createAccount({
    required String email,
    required String password,
  }) async {
    throw const AuthException(
      message: 'API key not valid',
      code: 'invalid-api-key',
    );
  }

  @override
  Future<AuthUser> signInEmail({
    required String email,
    required String password,
  }) async {
    throw const AuthException(
      message: 'API key not valid',
      code: 'invalid-api-key',
    );
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    throw const AuthException(
      message: 'API key not valid',
      code: 'invalid-api-key',
    );
  }

  @override
  Future<AuthUser> signInAnonymously() async {
    throw const AuthException(
      message: 'API key not valid',
      code: 'invalid-api-key',
    );
  }

  @override
  Future<void> signOut() async {}

  @override
  String? takeFallbackNotice() => null;
}

void main() {
  test('FallbackAuthRepository uses demo account on invalid API key', () async {
    final fallback = FakeAuthRepository();
    final repo = FallbackAuthRepository(
      primary: _FailingAuthRepository(),
      fallback: fallback,
    );

    final user = await repo.createAccount(
      email: 'test@nova.dev',
      password: 'password123',
    );

    expect(user.isDemo, isTrue);
    expect(repo.currentUser?.isDemo, isTrue);
    expect(repo.takeFallbackNotice(), isNotNull);
  });

  testWidgets('Sign-in screen shows fallback notice and continues', (
    tester,
  ) async {
    final fallback = FakeAuthRepository();
    final repo = FallbackAuthRepository(
      primary: _FailingAuthRepository(),
      fallback: fallback,
    );

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: SizedBox.shrink()),
        ),
        GoRoute(path: '/sign-in', builder: (_, __) => const SignInScreen()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (_, __) => MaterialApp.router(routerConfig: router),
        ),
      ),
    );
    router.push('/sign-in');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'demo@nova.dev');
    await tester.enterText(find.byType(TextField).at(1), 'secret');
    await tester.tap(find.text('Create account'));
    await tester.pump();

    expect(
      find.text('Auth not configured on this build — using demo account mode.'),
      findsAtLeastNWidgets(1),
    );
    expect(repo.currentUser, isNotNull);
  });
}
