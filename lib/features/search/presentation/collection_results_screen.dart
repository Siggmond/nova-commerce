import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nova_commerce/app/theme/app_shadows.dart';
import 'package:nova_commerce/app/theme/app_tokens.dart';
import 'package:nova_commerce/core/widgets/app_cached_network_image.dart';
import 'package:nova_commerce/features/search/presentation/collection_catalog.dart';
import 'package:nova_commerce/features/search/presentation/collection_viewmodel.dart';
import 'package:nova_commerce/features/search/presentation/search_filters.dart';
import 'package:nova_commerce/features/search/presentation/search_viewmodel.dart';
import 'package:nova_commerce/features/search/presentation/widgets/collection_filter_sheet.dart';
import 'package:nova_commerce/features/search/presentation/widgets/filter_chip_bar.dart';
import 'package:nova_commerce/features/search/presentation/widgets/search_collapsing_header.dart';
import 'package:nova_commerce/features/search/presentation/widgets/search_results_view.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

class CollectionResultsScreen extends ConsumerStatefulWidget {
  const CollectionResultsScreen({super.key, required this.collectionId});

  final String collectionId;

  @override
  ConsumerState<CollectionResultsScreen> createState() =>
      _CollectionResultsScreenState();
}

class _CollectionResultsScreenState
    extends ConsumerState<CollectionResultsScreen> {
  late final TextEditingController _controller = TextEditingController();
  late final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final query = ref
        .read(collectionFiltersProvider(widget.collectionId))
        .query;
    _controller.text = query;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CollectionFilterSheet(collectionId: widget.collectionId),
    );
  }

  Future<void> _submitQuery([String? raw]) async {
    final query = (raw ?? _controller.text).trim();
    _controller
      ..text = query
      ..selection = TextSelection.collapsed(offset: query.length);

    ref
        .read(collectionFiltersProvider(widget.collectionId).notifier)
        .setQueryImmediate(query);
    _focusNode.unfocus();
  }

  void _clearNonQueryFilters() {
    final controller = ref.read(
      collectionFiltersProvider(widget.collectionId).notifier,
    );
    controller.setSort(SearchSort.recommended);
    controller.setPriceTier(null);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final collection = searchCollectionById(widget.collectionId);
    if (collection == null) {
      return Scaffold(
        appBar: AppBar(title: Text(t.collectionTitle)),
        body: Center(child: Text(t.collectionNotFound)),
      );
    }

    final filters = ref.watch(collectionFiltersProvider(widget.collectionId));
    final query = filters.query;
    if (_controller.text != query && !_focusNode.hasFocus) {
      _controller
        ..text = query
        ..selection = TextSelection.collapsed(offset: query.length);
    }

    final catalogState = ref.watch(searchViewModelProvider);
    final results = ref.watch(collectionProductsProvider(widget.collectionId));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SearchCollapsingHeader(
            controller: _controller,
            focusNode: _focusNode,
            query: query,
            title: _collectionTitle(t, collection.id),
            hintText: t.searchHintSearchInCollection,
            searchTooltip: t.searchTooltipSearch,
            filterTooltip: t.searchTooltipFilters,
            hasActiveFilters: filters.hasNonQueryFilters,
            expandedHeight: 154,
            collapsedHeight: 80,
            onChanged: (value) => ref
                .read(collectionFiltersProvider(widget.collectionId).notifier)
                .setQueryDebounced(value),
            onSubmitted: (value) => unawaited(_submitQuery(value)),
            onSearchPressed: () => unawaited(_submitQuery()),
            onClearQuery: () {
              _controller.clear();
              ref
                  .read(collectionFiltersProvider(widget.collectionId).notifier)
                  .setQueryImmediate('');
            },
            onFilterPressed: () => unawaited(_openFilters()),
          ),
          FilterChipBar(
            filters: filters,
            includeCategory: false,
            onOpenFilters: () => unawaited(_openFilters()),
            onClearSort: () => ref
                .read(collectionFiltersProvider(widget.collectionId).notifier)
                .setSort(SearchSort.recommended),
            onClearPriceTier: () => ref
                .read(collectionFiltersProvider(widget.collectionId).notifier)
                .setPriceTier(null),
            onClearAll: _clearNonQueryFilters,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 6.h),
              child: _CollectionHeaderBanner(collection: collection),
            ),
          ),
          SearchResultsView(
            results: results,
            isLoading: catalogState.isLoading,
            hasError: catalogState.hasError,
            onRetry: () => ref.read(searchViewModelProvider.notifier).refresh(),
            errorTitle: t.collectionLoadProductsErrorTitle,
            errorSubtitle: t.collectionLoadProductsErrorSubtitle,
            emptyTitle: t.collectionNoResultsTitle,
            emptySubtitle: t.collectionNoResultsSubtitle,
            itemKeyPrefix: 'collection_${collection.id}',
          ),
        ],
      ),
    );
  }
}

class _CollectionHeaderBanner extends StatelessWidget {
  const _CollectionHeaderBanner({required this.collection});

  final SearchCollection collection;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final radius = BorderRadius.circular(AppRadii.xl);

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: radius,
        boxShadow: AppShadows.sm(),
      ),
      child: SizedBox(
        height: 128.h,
        child: Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final memCacheWidth = (constraints.maxWidth * dpr).round();
                  final memCacheHeight = (constraints.maxHeight * dpr).round();

                  return AppCachedNetworkImage(
                    url: collection.imageUrl,
                    fit: BoxFit.cover,
                    borderRadius: radius,
                    memCacheWidth: memCacheWidth,
                    memCacheHeight: memCacheHeight,
                    backgroundColor: cs.surfaceContainerHigh,
                  );
                },
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.10),
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14.w,
              right: 14.w,
              bottom: 12.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _collectionSubtitle(t, collection.id),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    _categoryLabel(t, collection.categoryId).toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.80),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _collectionTitle(AppLocalizations t, String id) {
  switch (id) {
    case 'editorial_1':
      return t.searchCollectionEditorial1Title;
    case 'editorial_2':
      return t.searchCollectionEditorial2Title;
    case 'editorial_3':
      return t.searchCollectionEditorial3Title;
    case 'editorial_4':
      return t.searchCollectionEditorial4Title;
    case 'editorial_5':
      return t.searchCollectionEditorial5Title;
    case 'editorial_6':
      return t.searchCollectionEditorial6Title;
    default:
      return id;
  }
}

String _collectionSubtitle(AppLocalizations t, String id) {
  switch (id) {
    case 'editorial_1':
      return t.searchCollectionEditorial1Subtitle;
    case 'editorial_2':
      return t.searchCollectionEditorial2Subtitle;
    case 'editorial_3':
      return t.searchCollectionEditorial3Subtitle;
    case 'editorial_4':
      return t.searchCollectionEditorial4Subtitle;
    case 'editorial_5':
      return t.searchCollectionEditorial5Subtitle;
    case 'editorial_6':
      return t.searchCollectionEditorial6Subtitle;
    default:
      return '';
  }
}

String _categoryLabel(AppLocalizations t, String id) {
  switch (id.toLowerCase()) {
    case 'groceries':
      return t.homeCategoryGroceries;
    case 'restaurants':
      return t.homeCategoryRestaurants;
    case 'pharmacy':
      return t.homeCategoryPharmacy;
    case 'coffee':
      return t.homeCategoryCoffee;
    case 'bakery':
      return t.homeCategoryBakery;
    case 'electronics':
      return t.homeCategoryElectronics;
    case 'flowers':
      return t.homeCategoryFlowers;
    case 'pet':
      return t.homeCategoryPetSupplies;
    case 'cosmetics':
      return t.homeCategoryCosmetics;
    case 'snacks':
      return t.homeCategorySnacks;
    case 'drinks':
      return t.homeCategoryDrinks;
    case 'baby':
      return t.homeCategoryBaby;
    default:
      return id;
  }
}
