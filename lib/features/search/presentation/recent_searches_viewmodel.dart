import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';

const int _recentSearchesLimit = 12;

final recentSearchesViewModelProvider =
    StateNotifierProvider<RecentSearchesViewModel, List<String>>((ref) {
      return RecentSearchesViewModel(ref);
    });

class RecentSearchesViewModel extends StateNotifier<List<String>> {
  RecentSearchesViewModel(this._ref) : super(const []) {
    refresh();
  }

  final Ref _ref;

  Future<void> refresh() async {
    final repo = _ref.read(recentSearchesRepositoryProvider);
    final items = await repo.loadQueries();
    state = items;
  }

  Future<void> add(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final current = [...state];
    current.removeWhere((q) => q == trimmed);
    current.insert(0, trimmed);

    if (current.length > _recentSearchesLimit) {
      current.removeRange(_recentSearchesLimit, current.length);
    }

    state = current;
    await _ref.read(recentSearchesRepositoryProvider).saveQueries(current);
  }

  Future<void> clear() async {
    state = const [];
    await _ref.read(recentSearchesRepositoryProvider).saveQueries(const []);
  }
}
