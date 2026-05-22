import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nova_commerce/app/app.dart';
import 'package:nova_commerce/app/router/app_routes.dart';
import 'package:nova_commerce/app/di/app_providers.dart';
import 'package:nova_commerce/features/auth/auth.dart';
import 'package:nova_commerce/features/profile/presentation/profile_screen.dart';
import 'package:nova_commerce/features/wishlist/wishlist.dart';

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxPumps = 200,
  Duration step = const Duration(milliseconds: 50),
}) async {
  for (var i = 0; i < maxPumps; i++) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Did not find widget after pumping: $finder');
}

Future<void> _waitPastTabThrottle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 90)),
  );
  await tester.pump();
}

void main() {
  testWidgets('Bottom tabs reset inactive stack on tab switch', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final authRepo = FakeAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(authRepo)],
        child: const NovaCommerceApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 800));

    // Start on Home.
    await _pumpUntilFound(
      tester,
      find.byKey(const Key('home_messages_button')),
    );
    expect(find.byKey(const Key('home_messages_button')), findsWidgets);

    // Go to Profile tab.
    await tester.tap(find.byKey(const Key('nav_tab_account')));
    await _pumpUntilFound(tester, find.byType(ProfileScreen));
    expect(find.byType(ProfileScreen), findsOneWidget);

    // Push Wishlist within Profile tab.
    final profileContext = tester.element(find.byType(ProfileScreen));
    unawaited(GoRouter.of(profileContext).push(AppRoutes.wishlist));
    await tester.pump();
    await _pumpUntilFound(tester, find.byType(WishlistScreen));
    expect(find.byType(WishlistScreen), findsOneWidget);

    // Switch to Home tab, then back to Profile.
    await _waitPastTabThrottle(tester);
    await tester.tap(find.byKey(const Key('nav_tab_shop')));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('home_messages_button')), findsWidgets);

    await _waitPastTabThrottle(tester);
    await tester.tap(find.byKey(const Key('nav_tab_account')));
    await _pumpUntilFound(tester, find.byType(ProfileScreen));

    // Profile tab stack should reset to its initial route when selected again.
    expect(find.byType(WishlistScreen), findsNothing);
    expect(find.byType(ProfileScreen), findsOneWidget);
  });
}
