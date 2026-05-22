import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai_nav/ai_nav_intent.dart';

enum AppTab { shop, search, ai, offers, cart, account }

class AppTabIndex {
  static const int shop = 0;
  static const int search = 1;
  static const int ai = 2;
  static const int offers = 3;
  static const int cart = 4;
  static const int account = 5;
}

const appTabs = <AppTab>[
  AppTab.shop,
  AppTab.search,
  AppTab.ai,
  AppTab.offers,
  AppTab.cart,
  AppTab.account,
];

const aiModelTabsCount = 5;

final appTabCountProvider = Provider<int>((ref) => appTabs.length);

final aiModelTabCountProvider = Provider<int>((ref) => aiModelTabsCount);

final currentTabIndexProvider = StateProvider<int>((ref) {
  return AppTabIndex.shop;
});

int appTabIndexToAiModelTabIndex(int appIndex) {
  return switch (appIndex) {
    AppTabIndex.shop => 0,
    AppTabIndex.search => 0,
    AppTabIndex.ai => 1,
    AppTabIndex.offers => 0,
    AppTabIndex.cart => 3,
    AppTabIndex.account => 4,
    _ => 0,
  };
}

int aiModelTabIndexToAppTabIndex(int aiIndex) {
  return switch (aiIndex) {
    0 => AppTabIndex.shop,
    1 => AppTabIndex.ai,
    2 => AppTabIndex.shop,
    3 => AppTabIndex.cart,
    4 => AppTabIndex.account,
    _ => AppTabIndex.shop,
  };
}

int? aiIntentToAppTabIndex(AiNavIntent intent) {
  return switch (intent) {
    AiNavIntent.home => AppTabIndex.shop,
    AiNavIntent.ai => AppTabIndex.ai,
    AiNavIntent.trends => AppTabIndex.shop,
    AiNavIntent.cart => AppTabIndex.cart,
    AiNavIntent.profile => AppTabIndex.account,
    _ => null,
  };
}

class AppTabSwitchRequest {
  const AppTabSwitchRequest({required this.index, this.initialLocation = true});

  final int index;
  final bool initialLocation;
}

class AppTabSwitchController extends StateNotifier<AppTabSwitchRequest?> {
  AppTabSwitchController() : super(null);

  void requestIndex(int index, {bool initialLocation = true}) {
    state = AppTabSwitchRequest(index: index, initialLocation: initialLocation);
  }

  void requestTab(AppTab tab, {bool initialLocation = true}) {
    requestIndex(appTabToIndex(tab), initialLocation: initialLocation);
  }

  void consume() {
    state = null;
  }
}

final appTabSwitchRequestProvider =
    StateNotifierProvider<AppTabSwitchController, AppTabSwitchRequest?>((ref) {
      return AppTabSwitchController();
    });

int appTabToIndex(AppTab tab) {
  return switch (tab) {
    AppTab.shop => AppTabIndex.shop,
    AppTab.search => AppTabIndex.search,
    AppTab.ai => AppTabIndex.ai,
    AppTab.offers => AppTabIndex.offers,
    AppTab.cart => AppTabIndex.cart,
    AppTab.account => AppTabIndex.account,
  };
}
