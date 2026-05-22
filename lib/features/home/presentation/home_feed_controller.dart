import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nova_commerce/features/wishlist/wishlist.dart';

import 'home_feed_registry.dart';
import 'home_filters.dart';
import 'home_viewmodel.dart';

enum HomeSectionStatus { loading, ready, empty, error }

typedef _HomeSectionSignal = ({
  int phase,
  bool isRefreshing,
  int itemCount,
  int itemIdsHash,
});

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

final homeFeedControllerProvider =
    StateNotifierProvider<HomeFeedController, List<HomeSectionState>>(
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
    _ref.listen<_HomeSectionSignal>(
      homeViewModelProvider.select(
        (s) => switch (s) {
          HomeLoading() => (
            phase: 0,
            isRefreshing: false,
            itemCount: 0,
            itemIdsHash: 0,
          ),
          HomeError() => (
            phase: 1,
            isRefreshing: false,
            itemCount: 0,
            itemIdsHash: 0,
          ),
          HomeData(:final items, :final isRefreshing) => (
            phase: 2,
            isRefreshing: isRefreshing,
            itemCount: items.length,
            itemIdsHash: Object.hashAll(items.map((e) => e.id)),
          ),
        },
      ),
      (_, __) {
        if (_isDisposed) return;
        _recompute();
      },
    );
    _ref.listen<bool>(
      homeFilteredProductsProvider.select((items) => items.isNotEmpty),
      (_, __) {
        if (_isDisposed) return;
        _recompute();
      },
    );
    _ref.listen<bool>(homePersonalizationEnabledProvider, (_, __) {
      if (_isDisposed) return;
      _recompute();
    });
    _ref.listen<Set<String>>(wishlistIdsProvider, (_, __) {
      if (_isDisposed) return;
      if (_ref.read(homePersonalizationEnabledProvider)) {
        _recompute();
      }
    });
    _recompute();
  }

  final Ref _ref;
  bool _isDisposed = false;

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
    required bool hasItems,
    required bool isRefreshing,
    required HomeSectionStatus previousStatus,
  }) {
    final prev = previousStatus;
    if (isRefreshing) {
      if (prev == HomeSectionStatus.ready) return HomeSectionStatus.ready;
      return prev;
    }
    return hasItems ? HomeSectionStatus.ready : HomeSectionStatus.empty;
  }

  void _recompute() {
    if (_isDisposed || !mounted) return;
    final currentById = {for (final s in state) s.id: s};
    final isRefreshing = _isRefreshing();
    final hasBrowseItems = _ref.read(
      homeFilteredProductsProvider.select((items) => items.isNotEmpty),
    );

    final order = _desiredOrder();
    final next = <HomeSectionState>[];
    for (final id in order) {
      final prev = currentById[id];
      final retryToken = prev?.retryToken ?? 0;
      final prevStatus = prev?.status ?? HomeSectionStatus.ready;

      final status = switch (id) {
        HomeSectionId.browseResults => _statusForList(
          hasItems: hasBrowseItems,
          isRefreshing: isRefreshing,
          previousStatus: prevStatus,
        ),
        _ => prevStatus,
      };

      next.add(
        HomeSectionState(id: id, status: status, retryToken: retryToken),
      );
    }

    final current = state;
    if (current.length == next.length) {
      var same = true;
      for (var i = 0; i < current.length; i++) {
        final a = current[i];
        final b = next[i];
        if (a.id != b.id ||
            a.status != b.status ||
            a.retryToken != b.retryToken) {
          same = false;
          break;
        }
      }
      if (same) return;
    }

    if (_isDisposed || !mounted) return;
    state = next;
  }

  void retrySection(HomeSectionId id) {
    if (_isDisposed || !mounted) return;
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

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
