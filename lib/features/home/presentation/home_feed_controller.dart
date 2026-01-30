import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_feed_registry.dart';
import 'home_filters.dart';
import 'home_viewmodel.dart';
import '../../wishlist/presentation/wishlist_viewmodel.dart';

enum HomeSectionStatus { loading, ready, empty, error }

class HomeSectionState {
  const HomeSectionState({
    required this.id,
    required this.status,
    required this.retryToken,
  });

  final HomeSectionId id;
  final HomeSectionStatus status;
  final int retryToken;

  HomeSectionState copyWith({HomeSectionStatus? status, int? retryToken}) {
    return HomeSectionState(
      id: id,
      status: status ?? this.status,
      retryToken: retryToken ?? this.retryToken,
    );
  }
}

final homeFeedControllerProvider = StateNotifierProvider<HomeFeedController, List<HomeSectionState>>(
  (ref) => HomeFeedController(ref),
);

class HomeFeedController extends StateNotifier<List<HomeSectionState>> {
  HomeFeedController(this._ref)
      : super([
          for (final def in homeSectionRegistry)
            HomeSectionState(
              id: def.id,
              status: HomeSectionStatus.ready,
              retryToken: 0,
            ),
        ]) {
    _ref.listen<HomeState>(homeViewModelProvider, (_, __) => _recompute());
    _ref.listen<List<dynamic>>(homeFilteredProductsProvider, (_, __) => _recompute());
    _ref.listen<List<dynamic>>(homeUnder50ProductsProvider, (_, __) => _recompute());
    _ref.listen<bool>(homePersonalizationEnabledProvider, (_, __) => _recompute());
    _ref.listen<Set<String>>(wishlistIdsProvider, (_, __) => _recompute());
    _recompute();
  }

  final Ref _ref;

  bool _isRefreshing() {
    final s = _ref.read(homeViewModelProvider);
    return s is HomeData && s.isRefreshing;
  }

  List<String> _homeItemIds() {
    final s = _ref.read(homeViewModelProvider);
    if (s is! HomeData) return const <String>[];
    return s.items.map((e) => e.id).toList(growable: false);
  }

  List<HomeSectionId> _desiredOrder() {
    final base = homeSectionRegistry.map((e) => e.id).toList(growable: false);
    final enabled = _ref.read(homePersonalizationEnabledProvider);
    if (!enabled) return base;

    final wishlist = _ref.read(wishlistIdsProvider);
    final itemIds = _homeItemIds();
    final intersects = itemIds.any(wishlist.contains);
    if (!intersects) return base;

    final set = base.toSet();
    final boosted = <HomeSectionId>[
      HomeSectionId.pickedHeader,
      HomeSectionId.pickedFeed,
      HomeSectionId.trendingHeader,
      HomeSectionId.trendingFeed,
    ];

    final out = <HomeSectionId>[];
    for (final id in boosted) {
      if (set.contains(id)) out.add(id);
    }
    for (final id in base) {
      if (!out.contains(id)) out.add(id);
    }
    return out;
  }

  HomeSectionStatus _statusForList({
    required HomeSectionId id,
    required List<dynamic> items,
    required bool isRefreshing,
    required Map<HomeSectionId, HomeSectionState> current,
  }) {
    final prev = current[id]?.status ?? HomeSectionStatus.ready;
    if (isRefreshing) {
      if (prev == HomeSectionStatus.ready) return HomeSectionStatus.ready;
      return prev;
    }
    return items.isEmpty ? HomeSectionStatus.empty : HomeSectionStatus.ready;
  }

  void _recompute() {
    final currentById = {for (final s in state) s.id: s};
    final isRefreshing = _isRefreshing();
    final browse = _ref.read(homeFilteredProductsProvider);
    final under = _ref.read(homeUnder50ProductsProvider);

    final order = _desiredOrder();
    final next = <HomeSectionState>[];
    for (final id in order) {
      final prev = currentById[id];
      final retryToken = prev?.retryToken ?? 0;
      final prevStatus = prev?.status ?? HomeSectionStatus.ready;

      final status = switch (id) {
        HomeSectionId.browseResults => _statusForList(
            id: id,
            items: browse,
            isRefreshing: isRefreshing,
            current: currentById,
          ),
        HomeSectionId.underFeed => _statusForList(
            id: id,
            items: under,
            isRefreshing: isRefreshing,
            current: currentById,
          ),
        _ => prevStatus,
      };

      next.add(
        HomeSectionState(id: id, status: status, retryToken: retryToken),
      );
    }
    state = next;
  }

  void retrySection(HomeSectionId id) {
    state = [
      for (final s in state)
        if (s.id == id)
          s.copyWith(
            status: HomeSectionStatus.loading,
            retryToken: s.retryToken + 1,
          )
        else
          s,
    ];
  }
}
