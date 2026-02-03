import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/config/app_tabs.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/nova_section_header.dart';
import '../../wishlist/presentation/wishlist_viewmodel.dart';
import 'recent_searches_viewmodel.dart';
import 'search_filters.dart';
import 'search_viewmodel.dart';
import 'widgets/collections_section.dart';
import 'widgets/featured_search_card.dart';
import 'widgets/recent_searches_section.dart';
import 'widgets/search_result_card.dart';
import 'widgets/search_filter_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller = TextEditingController();
  late final FocusNode _focusNode = FocusNode();

  static const double _breakpointCompactList = 420;
  static const double _rowCardExtent = 96;
  static const double _rowCardGap = 8;
  static const double _gridCardExtent = 248;

  static const double _appBarSearchHeight = 46;

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
      builder: (ctx) {
        return const SearchFilterSheet();
      },
    );
  }

  void _setQueryImmediate(String q) {
    final next = q;
    _controller
      ..text = next
      ..selection = TextSelection.collapsed(offset: next.length);
    ref.read(searchFiltersProvider.notifier).setQueryImmediate(next);
  }

  Future<void> _submitQuery() async {
    final q = _controller.text.trim();
    ref.read(searchFiltersProvider.notifier).setQueryImmediate(q);
    if (q.isNotEmpty) {
      await ref.read(recentSearchesViewModelProvider.notifier).add(q);
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchFiltersProvider.select((s) => s.query));
    final filters = ref.watch(searchFiltersProvider);
    final results = ref.watch(searchFilteredProductsProvider);
    final featured = ref.watch(searchFeaturedProductsProvider);
    final catalogState = ref.watch(searchViewModelProvider);
    final ids = ref.watch(wishlistIdsProvider);

    final showDiscovery = query.trim().isEmpty && !filters.hasNonQueryFilters;

    List<Widget> buildSlivers() {
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
              subtitle: 'Try a different keyword.',
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
                        key: ValueKey('search_${product.id}'),
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
                    key: ValueKey('search_${product.id}'),
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

    List<Widget> buildDiscoverySlivers() {
      final out = <Widget>[];

      out.add(
        SliverPadding(
          padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 0),
          sliver: const SliverToBoxAdapter(
            child: NovaSectionHeader(title: 'Featured'),
          ),
        ),
      );

      if (featured.isEmpty && catalogState.isLoading) {
        out.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
              child: const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            ),
          ),
        );
      } else {
        out.add(
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120.h,
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(12.w, AppSpace.xs, 12.w, 10.h),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final p = featured[index];
                  return FeaturedSearchCard(
                    key: ValueKey('featured_${p.id}'),
                    product: p,
                  );
                },
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemCount: featured.length,
              ),
            ),
          ),
        );
      }

      out.add(
        RecentSearchesSection(
          onSelectQuery: (q) async {
            _setQueryImmediate(q);
            await _submitQuery();
          },
        ),
      );

      out.add(
        SliverPadding(
          padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 0),
          sliver: const SliverToBoxAdapter(
            child: NovaSectionHeader(
              title: 'Collections',
              subtitle: 'Editorial picks designed to inspire your next cart.',
            ),
          ),
        ),
      );
      out.add(const CollectionsSection());

      return out;
    }

    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _goToShopTabRoot();
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              toolbarHeight: 70.h,
              title: Padding(
                padding: EdgeInsets.fromLTRB(8.w, 8.h, 10.w, 8.h),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Back to Shop',
                      onPressed: _goToShopTabRoot,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: SizedBox(
                        height: _appBarSearchHeight.h,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.28),
                            ),
                            boxShadow: AppShadows.sm(),
                          ),
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            onChanged: (value) => ref
                                .read(searchFiltersProvider.notifier)
                                .setQueryDebounced(value),
                            onSubmitted: (_) => _submitQuery(),
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'Search for products',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.fromLTRB(
                                14.w,
                                12.h,
                                10.w,
                                12.h,
                              ),
                              suffixIcon: IconButton(
                                tooltip: 'Search',
                                onPressed: _submitQuery,
                                icon: Icon(Icons.search_rounded, size: 24.r),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      tooltip: 'Filters',
                      onPressed: _openFilters,
                      icon: const Icon(Icons.tune_rounded),
                    ),
                  ],
                ),
              ),
            ),
            if (showDiscovery)
              ...buildDiscoverySlivers()
            else
              ...buildSlivers(),
          ],
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
