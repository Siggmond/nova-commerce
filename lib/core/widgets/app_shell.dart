import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ai_nav/ai_nav_features.dart';
import '../ai_nav/ai_nav_intent.dart';
import '../ai_nav/ai_nav_providers.dart';
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
    final cartCount = ref
        .watch(cartItemsProvider)
        .fold<int>(0, (sum, item) => sum + item.quantity);

    final location = _safeLocation(context);
    final suppress = _shouldSuppressSuggestions(location);
    ref.read(aiNavControllerProvider.notifier).setSuppressed(suppress);

    final wishlistCount = ref.watch(wishlistIdsProvider).length;
    final isSignedIn = ref.watch(currentUidProvider) != null;

    final features = AiNavFeatures.fromAppSignals(
      currentTabIndex: currentIndex,
      tabCount: 5,
      cartCount: cartCount,
      wishlistCount: wishlistCount,
      isSignedIn: isSignedIn,
      hourOfDay: DateTime.now().hour,
    );
    ref
        .read(aiNavControllerProvider.notifier)
        .updateFeatures(features.toVector());

    final suggestion = ref.watch(aiNavControllerProvider);
    final suggestedIndex = switch (suggestion?.intent) {
      AiNavIntent.home => 0,
      AiNavIntent.ai => 1,
      AiNavIntent.trends => 2,
      AiNavIntent.cart => 3,
      AiNavIntent.profile => 4,
      _ => null,
    };

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
          if (index == currentIndex) return;
          navigationShell.goBranch(index);
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
