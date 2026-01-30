import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:nova_commerce/app.dart';
import 'package:nova_commerce/core/config/auth_providers.dart';
import 'package:nova_commerce/data/repositories/fake_auth_repository.dart';
import 'package:nova_commerce/features/orders/presentation/orders_screen.dart';
import 'package:nova_commerce/features/profile/presentation/profile_screen.dart';

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
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
        child: const NovaCommerceApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 800));

    // Start on Home.
    expect(find.byKey(const Key('home_messages_button')), findsWidgets);

    // Go to Profile tab.
    await tester.tap(find.text('Profile').hitTestable());
    await _pumpUntilFound(tester, find.byType(ProfileScreen).hitTestable());
    expect(find.byType(ProfileScreen).hitTestable(), findsOneWidget);

    // Wait for Profile actions to render.
    final ordersText = find.text('Orders');
    await _pumpUntilFound(tester, ordersText);
    await tester.scrollUntilVisible(ordersText, 220);
    await tester.pump();

    final ordersTileHitTestable =
        find
            .ancestor(of: ordersText, matching: find.byType(ListTile))
            .hitTestable();
    expect(ordersTileHitTestable, findsOneWidget);

    // Push Orders within Profile tab.
    await tester.tap(ordersTileHitTestable);
    // Orders may show a skeleton with ongoing shimmer animation, so avoid
    // pumpAndSettle which would time out.
    await _pumpUntilFound(tester, find.byType(OrdersScreen));
    expect(find.byType(OrdersScreen), findsOneWidget);

    // Switch to Home tab, then back to Profile.
    await tester.tap(find.text('Shop'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('home_messages_button')), findsWidgets);

    await tester.tap(find.text('Profile'));
    await _pumpUntilFound(tester, find.byType(OrdersScreen));

    // Profile tab stack should be preserved (still on Orders screen).
    expect(find.byType(OrdersScreen), findsOneWidget);

    // Back should pop to Profile root.
    await tester.pageBack();
    await _pumpUntilFound(tester, find.byType(ProfileScreen).hitTestable());
    expect(find.byType(ProfileScreen).hitTestable(), findsOneWidget);
  });
}
