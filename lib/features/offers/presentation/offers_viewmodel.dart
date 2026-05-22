import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nova_commerce/app/di/app_providers.dart';
import 'package:nova_commerce/features/offers/domain/entities/offer.dart';
import 'package:nova_commerce/features/offers/domain/repositories/offers_repository.dart';

const int offersPageSize = 20;

enum OffersQuickFilter { all, newOffers, popular, expiring, online, inStore }

class OffersState {
  const OffersState({
    required this.query,
    required this.quickFilter,
    required this.searchInput,
  });

  final OffersQuery query;
  final OffersQuickFilter quickFilter;
  final String searchInput;

  OffersState copyWith({
    OffersQuery? query,
    OffersQuickFilter? quickFilter,
    String? searchInput,
  }) {
    return OffersState(
      query: query ?? this.query,
      quickFilter: quickFilter ?? this.quickFilter,
      searchInput: searchInput ?? this.searchInput,
    );
  }

  static OffersState initial() {
    return const OffersState(
      query: OffersQuery(sort: OfferSort.recommended),
      quickFilter: OffersQuickFilter.all,
      searchInput: '',
    );
  }
}

final offersViewModelProvider =
    StateNotifierProvider.autoDispose<OffersViewModel, OffersState>((ref) {
      return OffersViewModel(ref);
    });

final offersQueryProvider = Provider.autoDispose<OffersQuery>((ref) {
  return ref.watch(offersViewModelProvider.select((state) => state.query));
});

final offersFirstPageProvider = FutureProvider.autoDispose<OffersPage>((ref) {
  final query = ref.watch(offersQueryProvider);
  final providerReadId = _OffersProviderDebug.nextReadId();
  developer.log(
    '[OffersFirstPageProvider] fetch id=$providerReadId query=${_queryLog(query)}',
    name: 'OffersFirstPageProvider',
  );

  final repo = ref.watch(offersRepositoryProvider);
  return repo.getOffers(query: query, limit: offersPageSize);
});

class OffersPaginationState {
  const OffersPaginationState({
    required this.extraItems,
    required this.isLoadingMore,
    required this.cursor,
    required this.hasMoreOverride,
    required this.error,
  });

  static const Object _unset = Object();

  final List<Offer> extraItems;
  final bool isLoadingMore;
  final Object? cursor;
  final bool? hasMoreOverride;
  final Object? error;

  OffersPaginationState copyWith({
    List<Offer>? extraItems,
    bool? isLoadingMore,
    Object? cursor = _unset,
    Object? hasMoreOverride = _unset,
    Object? error = _unset,
  }) {
    return OffersPaginationState(
      extraItems: extraItems ?? this.extraItems,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      cursor: identical(cursor, _unset) ? this.cursor : cursor,
      hasMoreOverride: identical(hasMoreOverride, _unset)
          ? this.hasMoreOverride
          : hasMoreOverride as bool?,
      error: identical(error, _unset) ? this.error : error,
    );
  }

  factory OffersPaginationState.initial() {
    return const OffersPaginationState(
      extraItems: <Offer>[],
      isLoadingMore: false,
      cursor: null,
      hasMoreOverride: null,
      error: null,
    );
  }
}

final offersPaginationProvider =
    StateNotifierProvider.autoDispose<
      OffersPaginationController,
      OffersPaginationState
    >((ref) {
      final controller = OffersPaginationController(ref);
      ref.listen<OffersQuery>(offersQueryProvider, (prev, next) {
        if (prev == next) return;
        controller.reset();
        developer.log(
          '[OffersPagination] reset due query change',
          name: 'OffersPaginationController',
        );
      });
      return controller;
    });

class OffersPaginationController extends StateNotifier<OffersPaginationState> {
  OffersPaginationController(this._ref)
    : super(OffersPaginationState.initial());

  final Ref _ref;

  void reset() {
    state = OffersPaginationState.initial();
  }

  Future<void> loadMore() async {
    final current = state;
    if (current.isLoadingMore) return;

    final firstPage = _ref.read(offersFirstPageProvider).valueOrNull;
    if (firstPage == null) return;

    final baseHasMore =
        firstPage.items.length == offersPageSize && firstPage.cursor != null;
    final effectiveHasMore = current.hasMoreOverride ?? baseHasMore;
    if (!effectiveHasMore) {
      if (current.hasMoreOverride != false) {
        state = current.copyWith(hasMoreOverride: false);
      }
      return;
    }

    final startAfter = current.cursor ?? firstPage.cursor;
    if (startAfter == null) {
      state = current.copyWith(hasMoreOverride: false);
      return;
    }

    state = current.copyWith(isLoadingMore: true, error: null);
    try {
      final query = _ref.read(offersQueryProvider);
      final repo = _ref.read(offersRepositoryProvider);
      final page = await repo.getOffers(
        query: query,
        limit: offersPageSize,
        startAfter: startAfter,
      );

      final nextExtraItems = _mergeExtraItems(
        baseItems: firstPage.items,
        existingExtraItems: current.extraItems,
        incomingItems: page.items,
      );
      final hasMore =
          page.items.length == offersPageSize && page.cursor != null;

      state = state.copyWith(
        extraItems: nextExtraItems,
        isLoadingMore: false,
        cursor: page.cursor,
        hasMoreOverride: hasMore,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(isLoadingMore: false, error: error);
    }
  }
}

class OffersFeedState {
  const OffersFeedState({
    required this.items,
    required this.heroItems,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.error,
  });

  final List<Offer> items;
  final List<Offer> heroItems;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final Object? error;
}

final offersFeedProvider = Provider.autoDispose<OffersFeedState>((ref) {
  final firstPageAsync = ref.watch(offersFirstPageProvider);
  final pagination = ref.watch(offersPaginationProvider);

  final firstPage = firstPageAsync.valueOrNull;
  final firstItems = firstPage?.items ?? const <Offer>[];
  final mergedItems = _mergeById(firstItems, pagination.extraItems);

  final featured = mergedItems.where((offer) => offer.isFeatured).take(6);
  final heroItems = featured.isNotEmpty
      ? featured.toList(growable: false)
      : mergedItems.take(6).toList(growable: false);

  final baseHasMore =
      firstItems.length == offersPageSize && (firstPage?.cursor != null);
  final hasMore = pagination.hasMoreOverride ?? baseHasMore;

  final loadError = mergedItems.isEmpty
      ? (firstPageAsync.asError?.error ?? pagination.error)
      : pagination.error;

  return OffersFeedState(
    items: mergedItems,
    heroItems: heroItems,
    isInitialLoading: firstPageAsync.isLoading && firstItems.isEmpty,
    isLoadingMore: pagination.isLoadingMore,
    hasMore: hasMore,
    error: loadError,
  );
});

final offerByIdProvider = FutureProvider.family.autoDispose<Offer?, String>((
  ref,
  id,
) {
  return ref.watch(offersRepositoryProvider).getOfferById(id);
});

class OffersViewModel extends StateNotifier<OffersState> {
  OffersViewModel(this._ref) : super(OffersState.initial());

  final Ref _ref;

  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> refresh({bool showLoading = false}) async {
    _ref.read(offersPaginationProvider.notifier).reset();
    _ref.invalidate(offersFirstPageProvider);
    try {
      await _ref.read(offersFirstPageProvider.future);
    } catch (_) {}
  }

  Future<void> loadMore() {
    return _ref.read(offersPaginationProvider.notifier).loadMore();
  }

  void setSearchTextDebounced(String text) {
    final input = text;
    state = state.copyWith(searchInput: input);

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 260), () {
      if (!mounted) return;
      final normalized = _normalizedSearchInput(input);
      final nextQuery = state.query.copyWith(searchText: normalized);
      state = state.copyWith(query: nextQuery);
    });
  }

  void setSort(OfferSort sort) {
    final nextQuery = state.query.copyWith(sort: sort);
    state = state.copyWith(query: nextQuery);
  }

  void setTags(List<String>? tags) {
    final nextQuery = state.query.copyWith(tags: tags);
    state = state.copyWith(query: nextQuery);
  }

  void setChannel(OfferChannel? channel) {
    final nextQuery = state.query.copyWith(channel: channel);
    state = state.copyWith(query: nextQuery);
  }

  void applyFilters({
    required OfferSort sort,
    required List<String>? tags,
    required OfferChannel? channel,
  }) {
    final nextQuery = state.query.copyWith(
      sort: sort,
      tags: tags,
      channel: channel,
    );
    state = state.copyWith(query: nextQuery);
  }

  void clearAllFiltersPreserveSearch() {
    final normalizedSearch = _normalizedSearchInput(state.searchInput);
    state = state.copyWith(
      quickFilter: OffersQuickFilter.all,
      query: const OffersQuery(
        sort: OfferSort.recommended,
      ).copyWith(searchText: normalizedSearch),
    );
  }

  void setQuickFilter(OffersQuickFilter filter) {
    final base = const OffersQuery(sort: OfferSort.recommended);
    final normalizedSearch = _normalizedSearchInput(state.searchInput);

    final next = switch (filter) {
      OffersQuickFilter.all => base,
      OffersQuickFilter.newOffers => base.copyWith(
        sort: OfferSort.newest,
        tags: const <String>['new'],
      ),
      OffersQuickFilter.popular => base.copyWith(
        sort: OfferSort.recommended,
        tags: const <String>['popular'],
      ),
      OffersQuickFilter.expiring => base.copyWith(
        sort: OfferSort.endingSoon,
        tags: const <String>['expiring'],
      ),
      OffersQuickFilter.online => base.copyWith(channel: OfferChannel.online),
      OffersQuickFilter.inStore => base.copyWith(channel: OfferChannel.inStore),
    };

    state = state.copyWith(
      quickFilter: filter,
      query: next.copyWith(searchText: normalizedSearch),
    );
  }

  static String _normalizedSearchInput(String text) {
    return text.trimLeft();
  }
}

List<Offer> _mergeExtraItems({
  required List<Offer> baseItems,
  required List<Offer> existingExtraItems,
  required List<Offer> incomingItems,
}) {
  final seenIds = <String>{
    ...baseItems.map((offer) => offer.id),
    ...existingExtraItems.map((offer) => offer.id),
  };
  final merged = <Offer>[...existingExtraItems];
  for (final offer in incomingItems) {
    if (seenIds.add(offer.id)) {
      merged.add(offer);
    }
  }
  return merged;
}

List<Offer> _mergeById(List<Offer> first, List<Offer> second) {
  final seenIds = <String>{};
  final out = <Offer>[];
  for (final offer in first) {
    if (seenIds.add(offer.id)) {
      out.add(offer);
    }
  }
  for (final offer in second) {
    if (seenIds.add(offer.id)) {
      out.add(offer);
    }
  }
  return out;
}

class _OffersProviderDebug {
  static int _next = 0;

  static int nextReadId() {
    _next += 1;
    return _next;
  }
}

String _queryLog(OffersQuery query) {
  final tags = query.tags;
  final tagsLabel = (tags == null || tags.isEmpty) ? '-' : tags.join(',');
  return 'sort=${query.sort.name};channel=${query.channel?.name ?? '-'};'
      'tags=$tagsLabel;search=${query.searchText ?? '-'}';
}
