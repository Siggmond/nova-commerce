import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nova_commerce/app.dart';
import 'package:nova_commerce/core/config/app_routes.dart';
import 'package:nova_commerce/core/config/auth_providers.dart';
import 'package:nova_commerce/data/repositories/fake_auth_repository.dart';
import 'package:nova_commerce/features/profile/presentation/profile_screen.dart';
import 'package:nova_commerce/features/wishlist/presentation/wishlist_screen.dart';

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

void main() {
  testWidgets('Bottom tabs preserve stack and back behavior is predictable', (
    WidgetTester tester,
  ) async {
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
    await tester.tap(find.text('Account').hitTestable());
    await _pumpUntilFound(tester, find.byType(ProfileScreen).hitTestable());
    expect(find.byType(ProfileScreen).hitTestable(), findsOneWidget);

    // Push Wishlist within Profile tab.
    final profileContext = tester.element(find.byType(ProfileScreen));
    GoRouter.of(profileContext).push(AppRoutes.wishlist);
    await tester.pump();
    await _pumpUntilFound(tester, find.byType(WishlistScreen));
    expect(find.byType(WishlistScreen), findsOneWidget);

    // Switch to Home tab, then back to Profile.
    await tester.tap(find.text('Shop').hitTestable());
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('home_messages_button')), findsWidgets);

    await tester.tap(find.text('Account').hitTestable());
    await _pumpUntilFound(tester, find.byType(WishlistScreen));

    // Profile tab stack should be preserved (still on Wishlist screen).
    expect(find.byType(WishlistScreen), findsOneWidget);

    // Back should pop to Profile root.
    await tester.binding.handlePopRoute();
    await tester.pump();
    await _pumpUntilFound(tester, find.byType(ProfileScreen).hitTestable());
    expect(find.byType(ProfileScreen).hitTestable(), findsOneWidget);
  });
}
