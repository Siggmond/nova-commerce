import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_routes.dart';
import '../../../core/errors/app_error_mapper.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/shimmer.dart';
import '../../../domain/entities/product.dart';
import 'home_filters.dart';
import 'home_viewmodel.dart';
import '../../ai_assistant/presentation/ai_chat_viewmodel.dart';
import '../../wishlist/presentation/wishlist_viewmodel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final ScrollController _scrollController = ScrollController();

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.extentAfter < 800) {
      ref.read(homeViewModelProvider.notifier).loadMore();
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova'),
        actions: [
          IconButton(
            onPressed: () => context.go(AppRoutes.cart),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ],
      ),
      body: state.when(
        loading: () => const _HomeSkeleton(),
        error: (e) {
          final msg = mapAppError(e);
          return AppErrorState(
            title: msg.title,
            subtitle: msg.subtitle,
            actionText: 'Retry',
            onAction: () => ref.read(homeViewModelProvider.notifier).refresh(),
          );
        },
        data: (items, isLoadingMore, hasMore) => RefreshIndicator(
          onRefresh: () => ref.read(homeViewModelProvider.notifier).refresh(),
          child: _HomeFeed(
            scrollController: _scrollController,
            items: items,
            isLoadingMore: isLoadingMore,
            hasMore: hasMore,
          ),
        ),
      ),
    );
  }
}

class _HomeFeed extends ConsumerStatefulWidget {
  const _HomeFeed({
    required this.scrollController,
    required this.items,
    required this.isLoadingMore,
    required this.hasMore,
  });

  final ScrollController scrollController;
  final List<Product> items;
  final bool isLoadingMore;
  final bool hasMore;

  @override
  ConsumerState<_HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends ConsumerState<_HomeFeed> {
  final _trendingKey = GlobalKey();
  final _pickedKey = GlobalKey();
  final _underKey = GlobalKey();

  bool _hintShown = false;
  bool _didPrecache = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _maybePrecacheFirstImages();
      await Future<void>.delayed(const Duration(milliseconds: 420));
      if (!mounted) return;
      if (_hintShown) return;
      _hintShown = true;
      if (!widget.scrollController.hasClients) return;
      final start = widget.scrollController.offset;
      await widget.scrollController.animateTo(
        (start + 36).clamp(0, widget.scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
      await widget.scrollController.animateTo(
        start,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _HomeFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_didPrecache) return;
    if (oldWidget.items.isEmpty && widget.items.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _maybePrecacheFirstImages();
      });
    }
  }

  void _maybePrecacheFirstImages() {
    if (_didPrecache) return;
    if (widget.items.isEmpty) return;

    _didPrecache = true;
    final targets = widget.items.take(4);
    for (final p in targets) {
      final url = p.imageUrls.isNotEmpty ? p.imageUrls.first.trim() : '';
      if (url.isEmpty) continue;
      precacheImage(CachedNetworkImageProvider(url), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final listImageWidth = 1.sw - 32.w;

    final meta = ref.watch(homeCatalogMetaProvider);
    final filtered = ref.watch(homeFilteredProductsProvider);
    final items = widget.items;

    final trending = items.take(6).toList(growable: false);
    final picked = items.reversed.take(6).toList(growable: false);
    final under = items
        .where((p) => p.price <= 50)
        .take(6)
        .toList(growable: false);

    return CustomScrollView(
      controller: widget.scrollController,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AiEntryCard(
                  onTap: () => context.go(AppRoutes.ai),
                  onChip: (text) {
                    context.go(AppRoutes.ai);
                    ref.read(aiChatViewModelProvider.notifier).send(text);
                  },
                  onShowTrending: () => _scrollToKey(_trendingKey),
                  onShowUnder50: () => _scrollToKey(_underKey),
                ),
                SizedBox(height: 16.h),
                _HeroDealCard(
                  title: 'Trending drop',
                  subtitle: 'Fresh picks people are buying right now',
                  accent: cs.primary,
                  onTap: () => _scrollToKey(_trendingKey),
                ),
                SizedBox(height: 18.h),
                const _SectionHeader(
                  title: 'Browse',
                  subtitle: 'Search, filter, and sort (MVP)',
                ),
                SizedBox(height: 12.h),
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search products',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => ref
                      .read(homeBrowseFiltersProvider.notifier)
                      .setQueryDebounced(v),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openFilters(
                          context: context,
                          brands: meta.brands,
                          minPrice: meta.minPrice,
                          maxPrice: meta.maxPrice,
                        ),
                        icon: const Icon(Icons.tune),
                        label: const Text('Filters'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref.read(homeBrowseFiltersProvider.notifier).reset();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                if (filtered.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Text(
                      'No results for your filters.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        ),
        if (filtered.isNotEmpty)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final p = filtered[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _FeedProductTile(
                    key: ValueKey(p.id),
                    product: p,
                    imageWidth: listImageWidth,
                  ),
                );
              }, childCount: filtered.length < 12 ? filtered.length : 12),
            ),
          ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  key: _trendingKey,
                  title: 'Trending now',
                  subtitle: 'The feed everyone is tapping today',
                ),
                SizedBox(height: 12.h),
                SizedBox(height: 0.h),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
          sliver: SliverToBoxAdapter(child: _HorizontalCards(items: trending)),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  key: _pickedKey,
                  title: 'Picked for you',
                  subtitle: 'Based on what you saved & viewed (demo)',
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final p = picked[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 360),
                  curve: Curves.easeOutCubic,
                  offset: Offset.zero,
                  child: _FeedProductTile(
                    key: ValueKey('picked-${p.id}'),
                    product: p,
                    imageWidth: listImageWidth,
                  ),
                ),
              );
            }, childCount: picked.length),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  key: _underKey,
                  title: 'Under \$50 today',
                  subtitle: 'Budget heat — fast wins',
                ),
                SizedBox(height: 12.h),
                if (under.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Text(
                      'No items under \$50 in this feed right now.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (under.isNotEmpty)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
            sliver: SliverToBoxAdapter(child: _HorizontalCards(items: under)),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Center(
              child: widget.isLoadingMore
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : (widget.hasMore
                        ? const SizedBox.shrink()
                        : const SizedBox.shrink()),
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 8.h)),
      ],
    );
  }

  Future<void> _openFilters({
    required BuildContext context,
    required List<String> brands,
    required double minPrice,
    required double maxPrice,
  }) async {
    final safeMaxPrice = maxPrice <= minPrice ? (minPrice + 1) : maxPrice;

    final current = ref.read(homeBrowseFiltersProvider);
    String? brand = current.brand;
    bool inStockOnly = current.inStockOnly;
    HomeSort sort = current.sort;
    RangeValues range =
        current.priceRange ?? RangeValues(minPrice, safeMaxPrice);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 8.h,
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  DropdownButtonFormField<String?>(
                    value: brand,
                    decoration: const InputDecoration(
                      labelText: 'Brand',
                      border: OutlineInputBorder(),
                    ),
                    items: <DropdownMenuItem<String?>>[
                      const DropdownMenuItem(value: null, child: Text('All')),
                      ...brands.map(
                        (b) => DropdownMenuItem(value: b, child: Text(b)),
                      ),
                    ],
                    onChanged: (v) => setLocal(() => brand = v),
                  ),
                  SizedBox(height: 14.h),
                  SwitchListTile(
                    value: inStockOnly,
                    onChanged: (v) => setLocal(() => inStockOnly = v),
                    title: const Text('In stock only'),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Price range',
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  RangeSlider(
                    values: range,
                    min: minPrice,
                    max: safeMaxPrice,
                    onChanged: (v) => setLocal(() => range = v),
                  ),
                  SizedBox(height: 14.h),
                  DropdownButtonFormField<HomeSort>(
                    value: sort,
                    decoration: const InputDecoration(
                      labelText: 'Sort',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: HomeSort.newest,
                        child: Text('Newest'),
                      ),
                      DropdownMenuItem(
                        value: HomeSort.priceAsc,
                        child: Text('Price: low to high'),
                      ),
                      DropdownMenuItem(
                        value: HomeSort.priceDesc,
                        child: Text('Price: high to low'),
                      ),
                    ],
                    onChanged: (v) =>
                        setLocal(() => sort = v ?? HomeSort.newest),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final filters = ref.read(
                          homeBrowseFiltersProvider.notifier,
                        );
                        filters.setBrand(brand);
                        filters.setInStockOnly(inStockOnly);
                        filters.setPriceRange(range);
                        filters.setSort(sort);
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _scrollToKey(GlobalKey key) async {
    final context = key.currentContext;
    if (context == null) return;
    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }
}

class _FeedProductTile extends ConsumerWidget {
  const _FeedProductTile({
    super.key,
    required this.product,
    required this.imageWidth,
  });

  final Product product;
  final double imageWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(
      wishlistIdsProvider.select((ids) => ids.contains(product.id)),
    );

    return ProductCard(
      product: product,
      isSaved: isSaved,
      imageWidth: imageWidth,
      onToggleSaved: () =>
          ref.read(wishlistViewModelProvider.notifier).toggle(product.id),
      onTap: () => context.push('${AppRoutes.product}?id=${product.id}'),
    );
  }
}

class _AiEntryCard extends StatelessWidget {
  const _AiEntryCard({
    required this.onTap,
    required this.onChip,
    required this.onShowTrending,
    required this.onShowUnder50,
  });

  final VoidCallback onTap;
  final ValueChanged<String> onChip;
  final VoidCallback onShowTrending;
  final VoidCallback onShowUnder50;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.10),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10.r),
                    child: Icon(
                      Icons.auto_awesome,
                      color: cs.primary,
                      size: 22.r,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ask Nova what to buy',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Get instant picks and jump the feed.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onTap,
                  icon: Icon(Icons.arrow_forward, size: 20.r),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: [
                ActionChip(
                  label: const Text('Find me something cheap'),
                  onPressed: () {
                    onShowUnder50();
                    onChip('Find me something cheap under \$50');
                  },
                ),
                ActionChip(
                  label: const Text('What is trending?'),
                  onPressed: () {
                    onShowTrending();
                    onChip('What is trending right now?');
                  },
                ),
                ActionChip(
                  label: const Text('Build me an outfit'),
                  onPressed: () => onChip('Build me an outfit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroDealCard extends StatelessWidget {
  const _HeroDealCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(24.r),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withValues(alpha: 0.16),
              cs.surfaceContainerHighest,
            ],
          ),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    FilledButton(
                      onPressed: onTap,
                      child: const Text('Open feed'),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.r),
                  child: Icon(Icons.trending_up, color: accent, size: 28.r),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _HorizontalCards extends ConsumerWidget {
  const _HorizontalCards({required this.items});

  final List<Product> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageWidth = 260.w;
    return SizedBox(
      height: 280.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final p = items[index];
          return SizedBox(
            width: 260.w,
            child: ProductCard(
              key: ValueKey(p.id),
              product: p,
              isSaved: ref.watch(
                wishlistIdsProvider.select((ids) => ids.contains(p.id)),
              ),
              imageWidth: imageWidth,
              onToggleSaved: () =>
                  ref.read(wishlistViewModelProvider.notifier).toggle(p.id),
              onTap: () => context.push('${AppRoutes.product}?id=${p.id}'),
            ),
          );
        },
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      children: const [
        Shimmer(child: SkeletonBox(height: 86, radius: 18)),
        SizedBox(height: 16),
        Shimmer(child: SkeletonBox(height: 112, radius: 18)),
        SizedBox(height: 18),
        Shimmer(child: SkeletonBox(height: 54, radius: 12)),
        SizedBox(height: 10),
        Shimmer(child: SkeletonBox(height: 44, radius: 12)),
        SizedBox(height: 12),
        Shimmer(child: SkeletonBox(height: 272, radius: 16)),
        SizedBox(height: 12),
        Shimmer(child: SkeletonBox(height: 272, radius: 16)),
        SizedBox(height: 12),
        Shimmer(child: SkeletonBox(height: 272, radius: 16)),
      ],
    );
  }
}
