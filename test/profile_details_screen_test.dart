import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nova_commerce/core/config/auth_providers.dart';
import 'package:nova_commerce/core/widgets/app_button.dart';
import 'package:nova_commerce/data/repositories/fake_auth_repository.dart';
import 'package:nova_commerce/features/profile/presentation/profile_details_screen.dart';

void main() {
  testWidgets('Profile Details screen renders for signed-in user', (
    tester,
  ) async {
    final repo = FakeAuthRepository();
    await repo.createAccount(email: 'a@b.com', password: 'pw');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) => const MaterialApp(home: ProfileDetailsScreen()),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Account details'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Phone number'), findsAtLeastNWidgets(1));
  });

  testWidgets('Name edit persists', (tester) async {
    final repo = FakeAuthRepository();
    await repo.createAccount(email: 'a@b.com', password: 'pw');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) => const MaterialApp(home: ProfileDetailsScreen()),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text('Edit'));
    await tester.pump();

    await tester.enterText(find.byType(TextField).first, 'New Name');
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final details = await repo.getAccountDetails();
    expect(details?.displayName, 'New Name');
  });

  testWidgets('Email verification status updates after reload', (tester) async {
    final repo = FakeAuthRepository();
    await repo.createAccount(email: 'a@b.com', password: 'pw');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) => const MaterialApp(home: ProfileDetailsScreen()),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    // Initially unverified.
    expect(find.text('Not verified'), findsWidgets);

    await tester.tap(find.text('Verify email'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Simulate coming back from verification (app resume triggers reload()).
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Verified'), findsWidgets);
  });

  testWidgets('Phone verification links correctly', (tester) async {
    final repo = FakeAuthRepository();
    await repo.createAccount(email: 'a@b.com', password: 'pw');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) => const MaterialApp(home: ProfileDetailsScreen()),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    final phoneField = find.widgetWithText(TextField, 'Phone number');
    for (var i = 0; i < 20 && phoneField.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(phoneField, findsOneWidget);

    await tester.enterText(phoneField, '+12025550123');

    final sendCodeButton = find.byWidgetPredicate(
      (w) => w is AppButton && w.label == 'Send code',
    );
    for (var i = 0; i < 20 && sendCodeButton.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(sendCodeButton, findsOneWidget);

    await tester.ensureVisible(sendCodeButton);
    await tester.pump();
    await tester.tap(sendCodeButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final smsField = find.widgetWithText(TextField, 'SMS code');
    for (var i = 0; i < 20 && smsField.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(smsField, findsOneWidget);

    await tester.enterText(smsField, '123456');

    final verifyPhoneButton = find.byWidgetPredicate(
      (w) => w is AppButton && w.label == 'Verify phone',
    );
    for (var i = 0; i < 20 && verifyPhoneButton.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(verifyPhoneButton, findsOneWidget);

    await tester.ensureVisible(verifyPhoneButton);
    await tester.pump();
    await tester.tap(verifyPhoneButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final details = await repo.getAccountDetails();
    expect(details?.isPhoneVerified, isTrue);
  });
}
