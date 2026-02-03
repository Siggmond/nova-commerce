import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_cached_network_image.dart';
import '../../wishlist/presentation/wishlist_viewmodel.dart';
import 'collection_catalog.dart';
import 'collection_viewmodel.dart';
import 'search_viewmodel.dart';
import 'widgets/collection_filter_sheet.dart';
import 'widgets/search_result_card.dart';

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

  static const double _breakpointCompactList = 420;
  static const double _rowCardExtent = 96;
  static const double _rowCardGap = 8;
  static const double _gridCardExtent = 248;

  static const double _searchFieldHeight = 46;

  @override
  void initState() {
    super.initState();
    final q = ref.read(collectionFiltersProvider(widget.collectionId)).query;
    _controller.text = q;
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
      builder: (_) {
        return CollectionFilterSheet(collectionId: widget.collectionId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final collection = searchCollectionById(widget.collectionId);
    final catalogState = ref.watch(searchViewModelProvider);

    final query = ref.watch(
      collectionFiltersProvider(widget.collectionId).select((s) => s.query),
    );
    if (_controller.text != query) {
      _controller
        ..text = query
        ..selection = TextSelection.collapsed(offset: query.length);
    }

    final results = ref.watch(collectionProductsProvider(widget.collectionId));
    final ids = ref.watch(wishlistIdsProvider);

    if (collection == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Collection')),
        body: const Center(child: Text('Collection not found.')),
      );
    }

    List<Widget> buildResultSlivers() {
      if (catalogState.isLoading) {
        return const [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          ),
        ];
      }

      if (catalogState.hasError) {
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 22.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 44.r,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Could not load products',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Please check your connection and try again.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    AppButton.primary(
                      label: 'Retry',
                      onPressed: () =>
                          ref.read(searchViewModelProvider.notifier).refresh(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ];
      }

      if (results.isEmpty) {
        return const [
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(
              title: 'No results',
              subtitle: 'Try a different keyword or filters.',
            ),
          ),
        ];
      }

      return [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 12.h),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.crossAxisExtent;

              if (width < _breakpointCompactList) {
                return SliverFixedExtentList(
                  itemExtent: (_rowCardExtent + _rowCardGap).h,
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = results[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: _rowCardGap.h),
                      child: SearchResultCard(
                        key: ValueKey(
                          'collection_${collection.id}_${product.id}',
                        ),
                        product: product,
                        variant: SearchResultCardVariant.row,
                        isSaved: ids.contains(product.id),
                        onToggleSaved: () => ref
                            .read(wishlistViewModelProvider.notifier)
                            .toggle(product.id),
                      ),
                    );
                  }, childCount: results.length),
                );
              }

              final crossAxisCount = width < 720 ? 2 : 3;
              const spacing = 10.0;

              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  mainAxisExtent: _gridCardExtent.h,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = results[index];
                  return SearchResultCard(
                    key: ValueKey('collection_${collection.id}_${product.id}'),
                    product: product,
                    variant: SearchResultCardVariant.grid,
                    isSaved: ids.contains(product.id),
                    onToggleSaved: () => ref
                        .read(wishlistViewModelProvider.notifier)
                        .toggle(product.id),
                  );
                }, childCount: results.length),
              );
            },
          ),
        ),
      ];
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            titleSpacing: 0,
            toolbarHeight: 64.h,
            leading: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Back',
            ),
            title: Text(
              collection.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Filters',
                onPressed: _openFilters,
                icon: const Icon(Icons.tune_rounded),
              ),
              SizedBox(width: 6.w),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
              child: _CollectionHeaderBanner(collection: collection),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
              child: SizedBox(
                height: _searchFieldHeight.h,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.28),
                    ),
                    boxShadow: AppShadows.sm(),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: (value) => ref
                        .read(
                          collectionFiltersProvider(
                            widget.collectionId,
                          ).notifier,
                        )
                        .setQueryDebounced(value),
                    onSubmitted: (value) => ref
                        .read(
                          collectionFiltersProvider(
                            widget.collectionId,
                          ).notifier,
                        )
                        .setQueryImmediate(value.trim()),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search in this collection',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.fromLTRB(
                        14.w,
                        12.h,
                        10.w,
                        12.h,
                      ),
                      suffixIcon: IconButton(
                        tooltip: 'Clear',
                        onPressed: () {
                          _controller.clear();
                          ref
                              .read(
                                collectionFiltersProvider(
                                  widget.collectionId,
                                ).notifier,
                              )
                              .setQueryImmediate('');
                        },
                        icon: Icon(Icons.close_rounded, size: 20.r),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          ...buildResultSlivers(),
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
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppRadii.xl);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: radius,
        boxShadow: AppShadows.md(),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          height: 128.h,
          child: Stack(
            children: [
              Positioned.fill(
                child: AppCachedNetworkImage(
                  url: collection.imageUrl,
                  fit: BoxFit.cover,
                  backgroundColor: cs.surfaceContainerHigh,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
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
                      collection.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      collection.category.toUpperCase(),
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
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 44.r, color: cs.outline),
            SizedBox(height: 10.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
