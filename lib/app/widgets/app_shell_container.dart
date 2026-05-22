import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:nova_commerce/app/di/app_providers.dart';
import 'package:nova_commerce/app/config/low_end_device_mode.dart';
import 'package:nova_commerce/app/perf/performance_engine.dart';
import 'package:nova_commerce/app/router/app_tabs.dart';
import 'package:nova_commerce/app/startup/feature_init_once.dart';
import 'package:nova_commerce/core/ai_nav/ai_nav_features.dart';
import 'package:nova_commerce/core/widgets/app_shell.dart';
import 'package:nova_commerce/features/cart/cart.dart';
import 'package:nova_commerce/features/wishlist/wishlist.dart';

class AppShellContainer extends ConsumerStatefulWidget {
  const AppShellContainer({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShellContainer> createState() => _AppShellContainerState();
}

class _AppShellContainerState extends ConsumerState<AppShellContainer> {
  static const bool _mlNavEnabled = false;
  static const Duration _aiStartupCooldown = Duration(seconds: 10);

  final DateTime _createdAt = DateTime.now();
  bool _aiSyncQueued = false;
  bool? _pendingSuppress;
  List<double> _pendingFeatures = const <double>[];
  bool? _lastQueuedSuppress;
  List<double>? _lastQueuedFeatures;
  bool? _appliedSuppress;
  List<double>? _appliedFeatures;

  bool get _startupCooldownActive {
    return DateTime.now().difference(_createdAt) < _aiStartupCooldown;
  }

  void _queueAiSignals({
    required bool suppress,
    required List<double> features,
    required bool highPressure,
  }) {
    if (!_mlNavEnabled) return;

    final nextSuppress = suppress || highPressure || _startupCooldownActive;
    final nextFeatures = List<double>.unmodifiable(features);

    if (_lastQueuedSuppress == nextSuppress &&
        _sameVector(_lastQueuedFeatures, nextFeatures) &&
        !_aiSyncQueued) {
      return;
    }

    _lastQueuedSuppress = nextSuppress;
    _lastQueuedFeatures = List<double>.of(nextFeatures, growable: false);
    _pendingSuppress = nextSuppress;
    _pendingFeatures = nextFeatures;

    if (_aiSyncQueued) return;
    _aiSyncQueued = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _aiSyncQueued = false;
      if (!mounted) return;

      final notifier = ref.read(aiNavControllerProvider.notifier);
      final suppressNow = _pendingSuppress ?? true;

      if (_appliedSuppress != suppressNow) {
        notifier.setSuppressed(suppressNow);
        _appliedSuppress = suppressNow;
      }

      if (!suppressNow && !_sameVector(_appliedFeatures, _pendingFeatures)) {
        notifier.updateFeatures(_pendingFeatures);
        _appliedFeatures = List<double>.of(_pendingFeatures, growable: false);
      }
    });
  }

  static bool _sameVector(List<double>? a, List<double> b) {
    if (a == null) return false;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final navigationShell = widget.navigationShell;
    final currentIndex = navigationShell.currentIndex;
    final currentTabNotifier = ref.read(currentTabIndexProvider.notifier);
    if (currentTabNotifier.state != currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(currentTabIndexProvider.notifier).state = currentIndex;
      });
    }
    final tabCount = ref.watch(appTabCountProvider);
    final perfEngine = ref.read(performanceEngineProvider.notifier);
    final highPressure = ref.watch(
      performanceEngineProvider.select((s) => s.highPressure),
    );
    final lowEndMode = ref.watch(lowEndDeviceModeProvider);
    final reduceAnimations = highPressure || lowEndMode;

    ref.listen<AppTabSwitchRequest?>(appTabSwitchRequestProvider, (prev, next) {
      if (next == null) return;
      final index = next.index;
      if (index < 0 || index >= tabCount) {
        ref.read(appTabSwitchRequestProvider.notifier).consume();
        return;
      }
      if (!perfEngine.shouldAllowAction('tab_switch')) {
        ref.read(appTabSwitchRequestProvider.notifier).consume();
        return;
      }
      navigationShell.goBranch(index, initialLocation: next.initialLocation);
      ref.read(appTabSwitchRequestProvider.notifier).consume();
    });

    final cartCount = isCartFeatureInitialized
        ? ref.watch(cartItemCountProvider)
        : 0;

    int? suggestedIndex;
    double? suggestedConfidence;
    if (_mlNavEnabled) {
      final aiTabCount = ref.watch(aiModelTabCountProvider);
      final location = _safeLocation(context);
      final suppress = _shouldSuppressSuggestions(location);
      final wishlistCount = ref.read(wishlistIdsProvider).length;
      final isSignedIn = ref.read(currentUidProvider) != null;

      final aiTabIndex = appTabIndexToAiModelTabIndex(currentIndex);
      final features = AiNavFeatures.fromAppSignals(
        currentTabIndex: aiTabIndex,
        tabCount: aiTabCount,
        cartCount: cartCount,
        wishlistCount: wishlistCount,
        isSignedIn: isSignedIn,
        hourOfDay: DateTime.now().hour,
      );
      _queueAiSignals(
        suppress: suppress,
        features: features.toVector(),
        highPressure: highPressure,
      );

      final suggestion = ref.watch(aiNavControllerProvider);
      suggestedIndex = suggestion == null
          ? null
          : aiIntentToAppTabIndex(suggestion.intent);
      suggestedConfidence = suggestion?.confidence;
    }

    return AppShell(
      body: navigationShell,
      currentIndex: currentIndex,
      tabCount: tabCount,
      tabLabels: <String>[
        l10n.navShop,
        l10n.navSearch,
        l10n.navAi,
        l10n.navOffers,
        l10n.navCart,
        l10n.navAccount,
      ],
      cartCount: cartCount,
      suggestedIndex: suggestedIndex,
      suggestedConfidence: suggestedConfidence,
      reduceAnimations: reduceAnimations,
      onSelectTab: (index) {
        if (_mlNavEnabled) {
          ref
              .read(aiNavControllerProvider.notifier)
              .consumeSuggestionAndCooldown();
        }
        if (index < 0 || index >= tabCount) return;
        if (!perfEngine.shouldAllowAction('tab_switch')) return;
        navigationShell.goBranch(index, initialLocation: true);
      },
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
