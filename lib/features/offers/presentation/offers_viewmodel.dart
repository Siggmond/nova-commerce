import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../domain/entities/offer.dart';
import '../../../domain/repositories/offers_repository.dart';

enum OffersQuickFilter { all, newOffers, popular, expiring, online, inStore }

class OffersState {
  const OffersState({
    required this.query,
    required this.quickFilter,
    required this.items,
    required this.isLoading,
    required this.isRefreshing,
    required this.isLoadingMore,
    required this.hasMore,
    required this.cursor,
    required this.error,
  });

  final OffersQuery query;
  final OffersQuickFilter quickFilter;

  final List<Offer> items;

  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool hasMore;
  final Object? cursor;
  final Object? error;

  OffersState copyWith({
    OffersQuery? query,
    OffersQuickFilter? quickFilter,
    List<Offer>? items,
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? hasMore,
    Object? cursor,
    Object? error,
  }) {
    return OffersState(
      query: query ?? this.query,
      quickFilter: quickFilter ?? this.quickFilter,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      cursor: cursor,
      error: error,
    );
  }

  static OffersState initial() {
    return OffersState(
      query: const OffersQuery(sort: OfferSort.recommended),
      quickFilter: OffersQuickFilter.all,
      items: const <Offer>[],
      isLoading: true,
      isRefreshing: false,
      isLoadingMore: false,
      hasMore: true,
      cursor: null,
      error: null,
    );
  }
}

final offersViewModelProvider =
    StateNotifierProvider<OffersViewModel, OffersState>((ref) {
      return OffersViewModel(ref);
    });

final offerByIdProvider = FutureProvider.family<Offer?, String>((ref, id) {
  return ref.watch(offersRepositoryProvider).getOfferById(id);
});

class OffersViewModel extends StateNotifier<OffersState> {
  OffersViewModel(this._ref) : super(OffersState.initial()) {
    refresh(showLoading: true);
  }

  final Ref _ref;

  static const int _pageSize = 20;

  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> refresh({bool showLoading = false}) async {
    if (showLoading) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        cursor: null,
        hasMore: true,
      );
    } else {
      state = state.copyWith(
        isRefreshing: true,
        error: null,
        cursor: null,
        hasMore: true,
      );
    }

    try {
      final repo = _ref.read(offersRepositoryProvider);
      final page = await repo.getOffers(query: state.query, limit: _pageSize);
      state = state.copyWith(
        items: page.items,
        cursor: page.cursor,
        hasMore: page.items.length == _pageSize && page.cursor != null,
        isLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        error: e,
      );
    }
  }

  Future<void> loadMore() async {
    final s = state;
    if (s.isLoading || s.isRefreshing || s.isLoadingMore) return;
    if (!s.hasMore) return;

    final cursor = s.cursor;
    if (cursor == null) return;

    state = s.copyWith(isLoadingMore: true);
    try {
      final repo = _ref.read(offersRepositoryProvider);
      final page = await repo.getOffers(
        query: s.query,
        limit: _pageSize,
        startAfter: cursor,
      );

      final merged = <Offer>[...s.items, ...page.items];
      state = s.copyWith(
        items: merged,
        cursor: page.cursor,
        hasMore: page.items.length == _pageSize && page.cursor != null,
        isLoadingMore: false,
      );
    } catch (e) {
      state = s.copyWith(isLoadingMore: false, error: e);
    }
  }

  void setSearchTextDebounced(String text) {
    final trimmed = text.trimLeft();
    final nextQuery = state.query.copyWith(searchText: trimmed);
    state = state.copyWith(query: nextQuery);

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 260), () {
      refresh(showLoading: true);
    });
  }

  void setSort(OfferSort sort) {
    state = state.copyWith(query: state.query.copyWith(sort: sort));
    refresh(showLoading: true);
  }

  void setTags(List<String>? tags) {
    final next = state.query.copyWith(tags: tags);
    state = state.copyWith(query: next);
    refresh(showLoading: true);
  }

  void setChannel(OfferChannel? channel) {
    final next = state.query.copyWith(channel: channel);
    state = state.copyWith(query: next);
    refresh(showLoading: true);
  }

  void applyFilters({
    required OfferSort sort,
    required List<String>? tags,
    required OfferChannel? channel,
  }) {
    final next = state.query.copyWith(sort: sort, tags: tags, channel: channel);
    state = state.copyWith(query: next);
    refresh(showLoading: true);
  }

  void clearAllFiltersPreserveSearch() {
    final searchText = state.query.searchText;
    state = state.copyWith(
      quickFilter: OffersQuickFilter.all,
      query: const OffersQuery(
        sort: OfferSort.recommended,
      ).copyWith(searchText: searchText),
    );
    refresh(showLoading: true);
  }

  void setQuickFilter(OffersQuickFilter filter) {
    final base = const OffersQuery(sort: OfferSort.recommended);

    final next = switch (filter) {
      OffersQuickFilter.all => base,
      OffersQuickFilter.newOffers => base.copyWith(
        sort: OfferSort.newest,
        tags: const ['new'],
      ),
      OffersQuickFilter.popular => base.copyWith(
        sort: OfferSort.recommended,
        tags: const ['popular'],
      ),
      OffersQuickFilter.expiring => base.copyWith(
        sort: OfferSort.endingSoon,
        tags: const ['expiring'],
      ),
      OffersQuickFilter.online => base.copyWith(channel: OfferChannel.online),
      OffersQuickFilter.inStore => base.copyWith(channel: OfferChannel.inStore),
    };

    final merged = next.copyWith(searchText: state.query.searchText);

    state = state.copyWith(quickFilter: filter, query: merged);
    refresh(showLoading: true);
  }
}
