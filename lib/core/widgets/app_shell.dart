import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ai_nav/ai_nav_features.dart';
import '../ai_nav/ai_nav_providers.dart';
import '../config/app_tabs.dart';
import '../../core/config/auth_providers.dart';
import '../../features/cart/presentation/cart_viewmodel.dart';
import '../../features/wishlist/presentation/wishlist_viewmodel.dart';
import 'ai_animated_navbar.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = navigationShell.currentIndex;
    final tabCount = ref.watch(appTabCountProvider);
    final aiTabCount = ref.watch(aiModelTabCountProvider);

    ref.listen<AppTabSwitchRequest?>(appTabSwitchRequestProvider, (prev, next) {
      if (next == null) return;
      final index = next.index;
      if (index < 0 || index >= tabCount) {
        ref.read(appTabSwitchRequestProvider.notifier).consume();
        return;
      }
      navigationShell.goBranch(index, initialLocation: next.initialLocation);
      ref.read(appTabSwitchRequestProvider.notifier).consume();
    });

    final cartCount = ref
        .watch(cartItemsProvider)
        .fold<int>(0, (sum, item) => sum + item.quantity);

    final location = _safeLocation(context);
    final suppress = _shouldSuppressSuggestions(location);
    ref.read(aiNavControllerProvider.notifier).setSuppressed(suppress);

    final wishlistCount = ref.watch(wishlistIdsProvider).length;
    final isSignedIn = ref.watch(currentUidProvider) != null;

    final aiTabIndex = appTabIndexToAiModelTabIndex(currentIndex);
    final features = AiNavFeatures.fromAppSignals(
      currentTabIndex: aiTabIndex,
      tabCount: aiTabCount,
      cartCount: cartCount,
      wishlistCount: wishlistCount,
      isSignedIn: isSignedIn,
      hourOfDay: DateTime.now().hour,
    );
    ref
        .read(aiNavControllerProvider.notifier)
        .updateFeatures(features.toVector());

    final suggestion = ref.watch(aiNavControllerProvider);
    final suggestedIndex = suggestion == null
        ? null
        : aiIntentToAppTabIndex(suggestion.intent);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AiAnimatedNavBar(
        currentIndex: currentIndex,
        cartCount: cartCount,
        suggestedIndex: suggestedIndex,
        suggestedConfidence: suggestion?.confidence,
        onSelect: (index) {
          ref
              .read(aiNavControllerProvider.notifier)
              .consumeSuggestionAndCooldown();
          if (index < 0 || index >= tabCount) return;
          navigationShell.goBranch(index, initialLocation: true);
        },
      ),
    );
  }

  static String _safeLocation(BuildContext context) {
    try {
      return GoRouterState.of(context).uri.toString();
    } catch (_) {
      return '';
    }
  }

  static bool _shouldSuppressSuggestions(String location) {
    return location.startsWith('/checkout') ||
        location.startsWith('/order-success');
  }
}
