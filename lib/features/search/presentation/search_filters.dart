import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SearchSort { recommended, popular, rating }

enum SearchPriceTier { lowest, midRange, highEnd }

class SearchFilters {
  const SearchFilters({
    this.query = '',
    this.sort = SearchSort.recommended,
    this.priceTier,
    this.category = 'all',
  });

  final String query;
  final SearchSort sort;
  final SearchPriceTier? priceTier;
  final String category;

  bool get hasNonQueryFilters {
    return sort != SearchSort.recommended ||
        priceTier != null ||
        category != 'all';
  }

  SearchFilters copyWith({
    String? query,
    SearchSort? sort,
    SearchPriceTier? priceTier,
    bool clearPriceTier = false,
    String? category,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      sort: sort ?? this.sort,
      priceTier: clearPriceTier ? null : (priceTier ?? this.priceTier),
      category: category ?? this.category,
    );
  }
}

final searchFiltersProvider =
    StateNotifierProvider<SearchFiltersController, SearchFilters>((ref) {
      return SearchFiltersController();
    });

class SearchFiltersController extends StateNotifier<SearchFilters> {
  SearchFiltersController() : super(const SearchFilters());

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void setQueryDebounced(
    String q, {
    Duration delay = const Duration(milliseconds: 260),
  }) {
    _debounce?.cancel();
    _debounce = Timer(delay, () {
      state = state.copyWith(query: q);
    });
  }

  void setQueryImmediate(String q) {
    _debounce?.cancel();
    state = state.copyWith(query: q);
  }

  void setSort(SearchSort sort) {
    state = state.copyWith(sort: sort);
  }

  void setPriceTier(SearchPriceTier? tier) {
    state = state.copyWith(priceTier: tier);
  }

  void setCategory(String category) {
    state = state.copyWith(category: category);
  }

  void clearAll() {
    _debounce?.cancel();
    state = const SearchFilters();
  }
}
