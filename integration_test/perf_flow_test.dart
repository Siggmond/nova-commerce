import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

import 'package:nova_commerce/app/router/app_routes.dart';
import 'package:nova_commerce/core/perf/perf_markers.dart';
import 'package:nova_commerce/features/home/presentation/home_viewmodel.dart';
import 'package:nova_commerce/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('perf flow emits report in profile', (tester) async {
    PerfMarkers.resetForTest();
    await app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await _waitForMarker(
      tester: tester,
      marker: 'firstProductsFrame',
      timeout: const Duration(seconds: 30),
    );
    await PerfMarkers.memorySample('after_first_products_frame');

    final firstProductId = _firstProductIdFromHomeState(tester);
    if (firstProductId == null || firstProductId.isEmpty) {
      fail(
        'Could not resolve a product id from Home state after firstProductsFrame.',
      );
    }

    final target = Uri(
      path: AppRoutes.product,
      queryParameters: <String, String>{'id': firstProductId},
    ).toString();
    await _retryNavigation(
      tester: tester,
      action: 'open product details',
      perform: () async {
        final context = _routerContext(tester);
        GoRouter.of(context).go(target);
      },
      isSuccess: () => _currentPath(tester) == AppRoutes.product,
    );
    await PerfMarkers.memorySample('after_product_details_open');

    await _retryNavigation(
      tester: tester,
      action: 'return home from product details',
      perform: () async {
        final context = _routerContext(tester);
        GoRouter.of(context).go(AppRoutes.home);
      },
      isSuccess: () => _currentPath(tester) == AppRoutes.home,
    );

    final homeScrollView = find.byKey(const Key('home_scroll_view'));
    if (homeScrollView.evaluate().isNotEmpty) {
      await tester.drag(homeScrollView.first, const Offset(0, -300));
      await tester.pumpAndSettle(const Duration(milliseconds: 700));
      await tester.drag(homeScrollView.first, const Offset(0, 180));
      await tester.pumpAndSettle(const Duration(milliseconds: 700));
    }

    await _retryNavigation(
      tester: tester,
      action: 'open cart tab',
      perform: () async {
        final cartTab = find.byKey(const Key('nav_tab_cart'));
        expect(cartTab, findsOneWidget);
        await tester.tap(cartTab.first);
      },
      isSuccess: () => _currentPath(tester) == AppRoutes.cart,
    );
    await PerfMarkers.memorySample('after_cart_open');

    await _retryNavigation(
      tester: tester,
      action: 'open checkout',
      perform: () async {
        final checkoutCta = find.byKey(const Key('cartProceedToCheckoutCta'));
        if (checkoutCta.evaluate().isNotEmpty) {
          await tester.tap(checkoutCta.first);
          return;
        }
        final context = _routerContext(tester);
        GoRouter.of(context).go(AppRoutes.checkout);
      },
      isSuccess: () => _currentPath(tester) == AppRoutes.checkout,
    );
    await PerfMarkers.memorySample('after_checkout_open');

    expect(find.byKey(const Key('checkout_screen_scaffold')), findsOneWidget);

    await _retryNavigation(
      tester: tester,
      action: 'return home',
      perform: () async {
        final context = _routerContext(tester);
        GoRouter.of(context).go(AppRoutes.home);
      },
      isSuccess: () => _currentPath(tester) == AppRoutes.home,
    );
    await PerfMarkers.memorySample('after_returning_home');

    PerfMarkers.report(trigger: 'perf_ci_flow');
  });
}

Future<void> _waitForMarker({
  required WidgetTester tester,
  required String marker,
  required Duration timeout,
}) async {
  final end = DateTime.now().add(timeout);
  while (!PerfMarkers.hasMarker(marker)) {
    if (DateTime.now().isAfter(end)) {
      fail('Timed out waiting for marker: $marker');
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _retryNavigation({
  required WidgetTester tester,
  required String action,
  required Future<void> Function() perform,
  required bool Function() isSuccess,
  int retries = 3,
  Duration settleDuration = const Duration(seconds: 2),
}) async {
  Object? lastError;

  for (var attempt = 1; attempt <= retries; attempt++) {
    try {
      await perform();
    } catch (error) {
      lastError = error;
    }

    await tester.pumpAndSettle(settleDuration);
    if (isSuccess()) return;
    await tester.pump(const Duration(milliseconds: 150));
  }

  final suffix = lastError == null ? '' : ' Last error: $lastError';
  fail('Navigation failed for "$action" after $retries retries.$suffix');
}

String? _firstProductIdFromHomeState(WidgetTester tester) {
  final scopeFinder = find.byType(ProviderScope);
  if (scopeFinder.evaluate().isEmpty) return null;
  final context = tester.element(scopeFinder.first);
  final container = ProviderScope.containerOf(context);
  final state = container.read(homeViewModelProvider);
  return switch (state) {
    HomeData(:final items) when items.isNotEmpty => items.first.id.trim(),
    _ => null,
  };
}

BuildContext _routerContext(WidgetTester tester) {
  final scaffoldFinder = find.byType(Scaffold);
  if (scaffoldFinder.evaluate().isNotEmpty) {
    return tester.element(scaffoldFinder.first);
  }
  return tester.element(find.byType(MaterialApp).first);
}

String _currentPath(WidgetTester tester) {
  final context = _routerContext(tester);
  return GoRouter.of(context).state.uri.path;
}
