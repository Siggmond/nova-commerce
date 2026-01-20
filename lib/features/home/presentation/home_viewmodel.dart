import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../domain/entities/product.dart';

sealed class HomeState {
  const HomeState();

  const factory HomeState.loading() = HomeLoading;
  const factory HomeState.data({
    required List<Product> items,
    required bool isLoadingMore,
    required bool hasMore,
  }) = HomeData;
  const factory HomeState.error(Object error) = HomeError;

  T when<T>({
    required T Function() loading,
    required T Function(List<Product> items, bool isLoadingMore, bool hasMore)
    data,
    required T Function(Object error) error,
  }) {
    final s = this;
    if (s is HomeLoading) return loading();
    if (s is HomeData) return data(s.items, s.isLoadingMore, s.hasMore);
    return error((s as HomeError).error);
  }
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeData extends HomeState {
  const HomeData({
    required this.items,
    required this.isLoadingMore,
    required this.hasMore,
  });

  final List<Product> items;
  final bool isLoadingMore;
  final bool hasMore;

  HomeData copyWith({
    List<Product>? items,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return HomeData(
      items: items ?? this.items,
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
    refresh();
  }

  final Ref _ref;

  static const int _pageSize = 20;

  Object? _cursor;

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

  Future<void> refresh() async {
    state = const HomeState.loading();
    _cursor = null;
    try {
      final repo = _ref.read(productRepositoryProvider);
      final page = await repo.getFeaturedProducts(limit: _pageSize);
      _cursor = page.cursor;
      final items = _dedupeById(page.items);
      state = HomeState.data(
        items: items,
        isLoadingMore: false,
        hasMore: page.items.length == _pageSize && _cursor != null,
      );
    } catch (e) {
      state = HomeState.error(e);
    }
  }

  Future<void> loadMore() async {
    final s = state;
    if (s is! HomeData) return;
    if (s.isLoadingMore || !s.hasMore) return;
    if (s.items.isEmpty) return;
    if (_cursor == null) return;

    state = s.copyWith(isLoadingMore: true);
    try {
      final repo = _ref.read(productRepositoryProvider);
      final page = await repo.getFeaturedProducts(
        limit: _pageSize,
        startAfter: _cursor,
      );

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

      state = s.copyWith(
        items: merged,
        isLoadingMore: false,
        hasMore: fetchedCount == _pageSize && _cursor != null,
      );
    } catch (_) {
      state = s.copyWith(isLoadingMore: false);
    }
  }
}
