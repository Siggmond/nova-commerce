import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nova_commerce/app/di/app_providers.dart';
import '../../../core/domain/entities/product.dart';

sealed class HomeState {
  const HomeState();

  const factory HomeState.loading() = HomeLoading;
  const factory HomeState.data({
    required List<Product> items,
    required bool isRefreshing,
    required bool isLoadingMore,
    required bool hasMore,
  }) = HomeData;
  const factory HomeState.error(Object error) = HomeError;

  T when<T>({
    required T Function() loading,
    required T Function(
      List<Product> items,
      bool isRefreshing,
      bool isLoadingMore,
      bool hasMore,
    )
    data,
    required T Function(Object error) error,
  }) {
    final s = this;
    if (s is HomeLoading) return loading();
    if (s is HomeData) {
      return data(s.items, s.isRefreshing, s.isLoadingMore, s.hasMore);
    }
    return error((s as HomeError).error);
  }
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeData extends HomeState {
  const HomeData({
    required this.items,
    required this.isRefreshing,
    required this.isLoadingMore,
    required this.hasMore,
  });

  final List<Product> items;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool hasMore;

  HomeData copyWith({
    List<Product>? items,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return HomeData(
      items: items ?? this.items,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class HomeError extends HomeState {
  const HomeError(this.error);

  final Object error;
}

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((
  ref,
) {
  return HomeViewModel(ref);
});

class HomeViewModel extends StateNotifier<HomeState> {
  HomeViewModel(this._ref) : super(const HomeState.loading()) {
    refresh(showLoading: true);
  }

  final Ref _ref;

  static const int _pageSize = 20;

  Object? _cursor;
  int _requestToken = 0;
  bool _isDisposed = false;

  List<Product> _dedupeById(Iterable<Product> items) {
    final seen = <String>{};
    final out = <Product>[];
    for (final p in items) {
      if (seen.add(p.id)) {
        out.add(p);
      }
    }
    return out;
  }

  Future<void> refresh({bool showLoading = false}) async {
    if (_isDisposed) return;
    final requestToken = ++_requestToken;
    final current = state;
    if (current is HomeData && !showLoading) {
      _publish(current.copyWith(isRefreshing: true));
    } else {
      _publish(const HomeState.loading());
    }
    _cursor = null;
    try {
      final repo = _ref.read(productRepositoryProvider);
      final page = await repo.getFeaturedProducts(limit: _pageSize);
      if (!_isRequestActive(requestToken)) return;
      _cursor = page.cursor;
      final items = _dedupeById(page.items);
      _publish(
        HomeState.data(
          items: items,
          isRefreshing: false,
          isLoadingMore: false,
          hasMore: page.items.length == _pageSize && _cursor != null,
        ),
      );
    } catch (e) {
      if (!_isRequestActive(requestToken)) return;
      _publish(HomeState.error(e));
    }
  }

  Future<void> loadMore() async {
    if (_isDisposed) return;
    final s = state;
    if (s is! HomeData) return;
    if (s.isLoadingMore || !s.hasMore) return;
    if (s.items.isEmpty) return;
    if (_cursor == null) return;

    final requestToken = ++_requestToken;
    _publish(s.copyWith(isLoadingMore: true));
    try {
      final repo = _ref.read(productRepositoryProvider);
      final page = await repo.getFeaturedProducts(
        limit: _pageSize,
        startAfter: _cursor,
      );
      if (!_isRequestActive(requestToken)) return;

      _cursor = page.cursor;
      final next = page.items;
      final fetchedCount = next.length;

      final seen = s.items.map((p) => p.id).toSet();
      final merged = <Product>[...s.items];
      for (final p in next) {
        if (seen.add(p.id)) {
          merged.add(p);
        }
      }

      _publish(
        s.copyWith(
          items: merged,
          isLoadingMore: false,
          hasMore: fetchedCount == _pageSize && _cursor != null,
        ),
      );
    } catch (_) {
      if (!_isRequestActive(requestToken)) return;
      _publish(s.copyWith(isLoadingMore: false));
    }
  }

  /// Firestore reads are not truly cancelable; this invalidates pending
  /// responses so route disposal cannot apply stale fetch completions.
  void cancelInFlightPageFetches() {
    _requestToken += 1;
  }

  bool _isRequestActive(int token) {
    return !_isDisposed && token == _requestToken;
  }

  void _publish(HomeState nextState) {
    if (_isDisposed || !mounted) return;
    state = nextState;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _requestToken += 1;
    super.dispose();
  }
}
