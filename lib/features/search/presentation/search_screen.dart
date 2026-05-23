import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nova_commerce/app/router/app_tabs.dart';
import 'package:nova_commerce/features/search/presentation/recent_searches_viewmodel.dart';
import 'package:nova_commerce/features/search/presentation/search_filters.dart';
import 'package:nova_commerce/features/search/presentation/search_viewmodel.dart';
import 'package:nova_commerce/features/search/presentation/widgets/discovery_view.dart';
import 'package:nova_commerce/features/search/presentation/widgets/filter_chip_bar.dart';
import 'package:nova_commerce/features/search/presentation/widgets/search_collapsing_header.dart';
import 'package:nova_commerce/features/search/presentation/widgets/search_filter_sheet.dart';
import 'package:nova_commerce/features/search/presentation/widgets/search_results_view.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller = TextEditingController();
  late final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialQuery;
    if (widget.initialQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(searchFiltersProvider.notifier)
            .setQueryImmediate(widget.initialQuery);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _goToShopTabRoot() {
    ref
        .read(appTabSwitchRequestProvider.notifier)
        .requestIndex(AppTabIndex.shop, initialLocation: true);
  }

  Future<void> _openFilters() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SearchFilterSheet(),
    );
  }

  Future<void> _submitQuery([String? raw]) async {
    final query = (raw ?? _controller.text).trim();
    _controller
      ..text = query
      ..selection = TextSelection.collapsed(offset: query.length);
    ref.read(searchFiltersProvider.notifier).setQueryImmediate(query);
    if (query.isNotEmpty) {
      await ref.read(recentSearchesViewModelProvider.notifier).add(query);
    }
    _focusNode.unfocus();
  }

  Future<void> _selectFromDiscovery(String query) async {
    await _submitQuery(query);
  }

  void _clearNonQueryFilters() {
    final controller = ref.read(searchFiltersProvider.notifier);
    controller.setSort(SearchSort.recommended);
    controller.setPriceTier(null);
    controller.setCategory('all');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final filters = ref.watch(searchFiltersProvider);
    final query = filters.query;
    final hasNonQueryFilters = filters.hasNonQueryFilters;

    final showDiscovery = query.trim().isEmpty && !hasNonQueryFilters;

    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          _goToShopTabRoot();
        },
        child: CustomScrollView(
          slivers: [
            SearchCollapsingHeader(
              controller: _controller,
              focusNode: _focusNode,
              query: query,
              title: t.searchTooltipSearch,
              hintText: t.searchHintSearchForProducts,
              searchTooltip: t.searchTooltipSearch,
              filterTooltip: t.searchTooltipFilters,
              hasActiveFilters: hasNonQueryFilters,
              expandedHeight: 132,
              collapsedHeight: 64,
              onChanged: (value) => ref
                  .read(searchFiltersProvider.notifier)
                  .setQueryDebounced(value),
              onSubmitted: (value) => unawaited(_submitQuery(value)),
              onSearchPressed: () => unawaited(_submitQuery()),
              onClearQuery: () {
                _controller.clear();
                ref.read(searchFiltersProvider.notifier).setQueryImmediate('');
              },
              onFilterPressed: () => unawaited(_openFilters()),
            ),
            if (!showDiscovery)
              FilterChipBar(
                filters: filters,
                includeCategory: true,
                onOpenFilters: () => unawaited(_openFilters()),
                onClearSort: () => ref
                    .read(searchFiltersProvider.notifier)
                    .setSort(SearchSort.recommended),
                onClearPriceTier: () =>
                    ref.read(searchFiltersProvider.notifier).setPriceTier(null),
                onClearCategory: () =>
                    ref.read(searchFiltersProvider.notifier).setCategory('all'),
                onClearAll: _clearNonQueryFilters,
              ),
            if (showDiscovery)
              _DiscoveryContentSliver(onSelectQuery: _selectFromDiscovery)
            else
              _SearchResultsContentSliver(
                onRetry: () {
                  ref.read(searchViewModelProvider.notifier).refresh();
                },
                errorTitle: t.collectionLoadProductsErrorTitle,
                errorSubtitle: t.collectionLoadProductsErrorSubtitle,
                emptyTitle: t.collectionNoResultsTitle,
                emptySubtitle: t.searchNoResultsSubtitle,
                itemKeyPrefix: 'search',
              ),
          ],
        ),
      ),
    );
  }
}

class _DiscoveryContentSliver extends ConsumerWidget {
  const _DiscoveryContentSliver({required this.onSelectQuery});

  final Future<void> Function(String query) onSelectQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popular = ref.watch(searchFeaturedProductsProvider);
    final catalogIsLoading = ref.watch(
      searchViewModelProvider.select((state) => state.isLoading),
    );
    return DiscoveryView(
      popularProducts: popular,
      catalogIsLoading: catalogIsLoading,
      onSelectQuery: onSelectQuery,
    );
  }
}

class _SearchResultsContentSliver extends ConsumerWidget {
  const _SearchResultsContentSliver({
    required this.onRetry,
    required this.errorTitle,
    required this.errorSubtitle,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.itemKeyPrefix,
  });

  final VoidCallback onRetry;
  final String errorTitle;
  final String errorSubtitle;
  final String emptyTitle;
  final String emptySubtitle;
  final String itemKeyPrefix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchFilteredProductsProvider);
    final isLoading = ref.watch(
      searchViewModelProvider.select((state) => state.isLoading),
    );
    final hasError = ref.watch(
      searchViewModelProvider.select((state) => state.hasError),
    );

    return SearchResultsView(
      results: results,
      isLoading: isLoading,
      hasError: hasError,
      onRetry: onRetry,
      errorTitle: errorTitle,
      errorSubtitle: errorSubtitle,
      emptyTitle: emptyTitle,
      emptySubtitle: emptySubtitle,
      itemKeyPrefix: itemKeyPrefix,
    );
  }
}
