import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_routes.dart';
import '../../../core/config/app_tabs.dart';
import '../../../core/errors/app_error_mapper.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_cached_network_image.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/nova_section_header.dart';
import '../../../core/widgets/nova_skeleton.dart';
import '../../../core/widgets/responsive_grid_delegate.dart';
import '../../../domain/entities/product.dart';
import '../../wishlist/presentation/wishlist_viewmodel.dart';
import '../../trends/presentation/trends_screen.dart';
import 'delivery_location_controller.dart';
import 'home_feed_controller.dart';
import 'home_feed_registry.dart';
import 'home_filters.dart';
import 'home_viewmodel.dart';
import 'widgets/delivery_location_chip.dart';
import 'widgets/category_tile.dart';
import 'widgets/home_filter_chip_style.dart';
import 'widgets/search_bar_frame.dart';

class HomeV2Feed extends ConsumerStatefulWidget {
  const HomeV2Feed({super.key});

  @override
  ConsumerState<HomeV2Feed> createState() => _HomeV2FeedState();
}

class _GoldGiftButton extends StatelessWidget {
  const _GoldGiftButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const red = Color(0xFFFF3B30);

    final bg1 = red.withValues(
      alpha: cs.brightness == Brightness.dark ? 0.28 : 0.16,
    );
    final bg2 = red.withValues(
      alpha: cs.brightness == Brightness.dark ? 0.18 : 0.10,
    );
    final border = red.withValues(
      alpha: cs.brightness == Brightness.dark ? 0.48 : 0.38,
    );

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: Ink(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bg1, bg2],
          ),
          border: Border.all(color: border),
          boxShadow: AppShadows.sm(color: red.withValues(alpha: 0.22)),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 34.r,
            height: 34.r,
            child: Icon(
              Icons.card_giftcard_rounded,
              size: 18.r,
              color: red.withValues(alpha: 0.95),
            ),
          ),
        ),
      ),
    );
  }
}

IconData _iconForCategory(String name) {
  switch (name.toLowerCase()) {
    case 'groceries':
      return Icons.local_grocery_store_outlined;
    case 'electronics':
      return Icons.devices_other_outlined;
    case 'beauty':
      return Icons.face_retouching_natural_outlined;
    case 'fashion':
      return Icons.checkroom_outlined;
    case 'home':
      return Icons.chair_outlined;
    case 'bakery':
      return Icons.bakery_dining_outlined;
    case 'fruits':
      return Icons.apple_outlined;
    case 'meat':
      return Icons.set_meal_outlined;
    case 'snacks':
      return Icons.lunch_dining_outlined;
    case 'drinks':
      return Icons.local_drink_outlined;
    case 'baby':
      return Icons.child_friendly_outlined;
    case 'health':
      return Icons.health_and_safety_outlined;
    case 'gifts':
      return Icons.card_giftcard_outlined;
    case 'stationery':
      return Icons.edit_outlined;
    default:
      return Icons.category_outlined;
  }
}

class _HomeV2FeedState extends ConsumerState<HomeV2Feed> {
  late final ScrollController _scrollController = ScrollController();

  static const bool _enableFrameTimings = bool.fromEnvironment(
    'ENABLE_FRAME_TIMINGS',
    defaultValue: false,
  );

  TimingsCallback? _timingsCallback;

  static const _lebanonCities = <String>[
    'Beirut',
    'Tripoli',
    'Sidon',
    'Tyre',
    'Jounieh',
    'Byblos',
    'Zahle',
    'Baalbek',
    'Nabatieh',
    'Batroun',
    'Bsharri',
    'Aley',
  ];

  static const double _searchDockThreshold = 84.0;
  late final ValueNotifier<double> _searchDockTNotifier = ValueNotifier(0);

  static const double _dockedSearchHeight = 44.0;
  static const double _dockedSearchBottomPadding = 8.0;
  static const double _dockedSearchPreferredHeight =
      _dockedSearchHeight + _dockedSearchBottomPadding;

  static const int _loadMoreThrottleMs = 520;
  int _lastLoadMoreAttemptMs = 0;

  bool _didPrecache = false;
  Timer? _hintTimer;
  bool _hintShown = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    if (_enableFrameTimings) {
      _timingsCallback = (timings) {
        for (final t in timings) {
          final buildMs = t.buildDuration.inMicroseconds / 1000.0;
          final rasterMs = t.rasterDuration.inMicroseconds / 1000.0;
          if (buildMs > 16 || rasterMs > 16) {
            debugPrint(
              'FRAME_JANK build=${buildMs.toStringAsFixed(1)}ms raster=${rasterMs.toStringAsFixed(1)}ms total=${(buildMs + rasterMs).toStringAsFixed(1)}ms',
            );
          }
        }
      };
      SchedulerBinding.instance.addTimingsCallback(_timingsCallback!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _maybePrecacheFirstImages();

      _hintTimer?.cancel();
      _hintTimer = Timer(const Duration(milliseconds: 420), () async {
        if (!mounted) return;
        if (_hintShown) return;
        if (!_scrollController.hasClients) return;

        _hintShown = true;
        final start = _scrollController.offset;
        await _scrollController.animateTo(
          (start + 36).clamp(0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
        );
        if (!mounted) return;
        if (!_scrollController.hasClients) return;
        await _scrollController.animateTo(
          start,
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeOutCubic,
        );
      });
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    final cb = _timingsCallback;
    if (cb != null) {
      SchedulerBinding.instance.removeTimingsCallback(cb);
      _timingsCallback = null;
    }
    _searchDockTNotifier.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _maybePrecacheFirstImages() {
    if (_didPrecache) return;

    final items = ref
        .read(homeViewModelProvider)
        .when(
          loading: () => const <Product>[],
          error: (_) => const <Product>[],
          data: (items, __, ___, ____) => items,
        );

    if (items.isEmpty) return;

    _didPrecache = true;
    final targets = items.take(4);

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final screenW = MediaQuery.sizeOf(context).width;
    // Keep precache decode bounded to avoid decoding full-res images.
    // This does not change UI; it reduces initial-frame and early-scroll jank.
    final targetWidth = (screenW * dpr).round().clamp(360, 900);

    for (final p in targets) {
      final url = p.imageUrl.trim();
      if (url.isEmpty) continue;
      precacheImage(
        ResizeImage(CachedNetworkImageProvider(url), width: targetWidth),
        context,
      );
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;

    final nextT = (position.pixels / _searchDockThreshold)
        .clamp(0.0, 1.0)
        .toDouble();
    final prevT = _searchDockTNotifier.value;
    if ((nextT - prevT).abs() > 0.02) {
      _searchDockTNotifier.value = nextT;
    }

    if (position.extentAfter < 900) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastLoadMoreAttemptMs < _loadMoreThrottleMs) return;
      _lastLoadMoreAttemptMs = now;

      final state = ref.read(homeViewModelProvider);
      final (isLoadingMore, hasMore) = state.when(
        loading: () => (true, false),
        error: (_) => (true, false),
        data: (_, __, isLoadingMore, hasMore) => (isLoadingMore, hasMore),
      );

      if (isLoadingMore) return;
      if (!hasMore) return;
      ref.read(homeViewModelProvider.notifier).loadMore();
    }
  }

  Future<void> _openCityPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: ListView.separated(
            itemCount: _lebanonCities.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final city = _lebanonCities[i];
              return ListTile(
                title: Text(city),
                onTap: () => Navigator.of(ctx).pop(city),
              );
            },
          ),
        );
      },
    );

    if (selected == null) return;
    await ref.read(deliveryLocationProvider.notifier).setCity(selected);
  }

  @override
  Widget build(BuildContext context) {
    final phase = ref.watch(
      homeViewModelProvider.select((s) => switch (s) {
            HomeLoading() => 0,
            HomeError() => 1,
            HomeData() => 2,
          }),
    );

    if (phase == 0) return const _HomeV2Skeleton();

    if (phase == 1) {
      final error = ref.watch(
        homeViewModelProvider.select((s) => s is HomeError ? s.error : null),
      );
      final msg = mapAppError(error ?? Exception('Unknown error'));

      return CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            titleSpacing: 12,
            title: Row(
              children: [
                const Text('Nova'),
                const Spacer(),
                IconButton(
                  key: const Key('home_messages_button'),
                  tooltip: 'Messages',
                  onPressed: () => context.push(AppRoutes.messages),
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                ),
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: AppErrorState(
              title: msg.title,
              subtitle: msg.subtitle,
              actionText: 'Retry',
              onAction: () => ref.read(homeViewModelProvider.notifier).refresh(),
            ),
          ),
        ],
      );
    }

    final items = ref.watch(
      homeViewModelProvider.select((s) => s is HomeData ? s.items : const <Product>[]),
    );
    final isRefreshing = ref.watch(
      homeViewModelProvider.select((s) => s is HomeData ? s.isRefreshing : false),
    );

    if (!_didPrecache && items.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _maybePrecacheFirstImages();
      });
    }

    return RepaintBoundary(
      child: RefreshIndicator(
        onRefresh: () => ref
            .read(homeViewModelProvider.notifier)
            .refresh(showLoading: false),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            ValueListenableBuilder<double>(
              valueListenable: _searchDockTNotifier,
              builder: (context, t, _) {
                return _RebuildTracker(
                  label: 'home.header.appbar',
                  child: SliverAppBar(
                    pinned: true,
                    automaticallyImplyLeading: false,
                    titleSpacing: 12,
                    title: Row(
                      children: [
                        const Text('Nova'),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 180,
                            ),
                            child: DeliveryLocationChip(
                              onTap: _openCityPicker,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        _GoldGiftButton(
                          onTap: () => context.push(AppRoutes.gold),
                        ),
                      ],
                    ),
                    actions: [
                      IconButton(
                        key: const Key('home_messages_button'),
                        tooltip: 'Messages',
                        onPressed: () => context.push(AppRoutes.messages),
                        icon: const Icon(Icons.chat_bubble_outline_rounded),
                      ),
                    ],
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(
                        _dockedSearchPreferredHeight * t,
                      ),
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          heightFactor: t,
                          child: Opacity(
                            opacity: t,
                            child: IgnorePointer(
                              ignoring: t < 0.85,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  0,
                                  12,
                                  _dockedSearchBottomPadding,
                                ),
                                child: SizedBox(
                                  height: _dockedSearchHeight,
                                  child: SearchBarFrame(
                                    docked: true,
                                    child: _SearchBar(
                                      compact: true,
                                      onTap: () {
                                        ref
                                            .read(
                                              homeBrowseFiltersProvider
                                                  .notifier,
                                            )
                                            .reset();
                                        ref
                                            .read(
                                              appTabSwitchRequestProvider
                                                  .notifier,
                                            )
                                            .requestIndex(
                                              AppTabIndex.search,
                                              initialLocation: true,
                                            );
                                      },
                                      onOpenFilters: () {
                                        ref
                                            .read(
                                              appTabSwitchRequestProvider
                                                  .notifier,
                                            )
                                            .requestIndex(
                                              AppTabIndex.search,
                                              initialLocation: true,
                                            );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            ValueListenableBuilder<double>(
              valueListenable: _searchDockTNotifier,
              builder: (context, t, _) {
                final invT = (1 - t).clamp(0.0, 1.0).toDouble();
                return _RebuildTracker(
                  label: 'home.header.searchInline',
                  child: SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 0),
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          heightFactor: invT,
                          child: Opacity(
                            opacity: invT,
                            child: IgnorePointer(
                              ignoring: t > 0.15,
                              child: SearchBarFrame(
                                child: _SearchBar(
                                  onTap: () {
                                    ref
                                        .read(
                                          homeBrowseFiltersProvider.notifier,
                                        )
                                        .reset();
                                    ref
                                        .read(
                                          appTabSwitchRequestProvider.notifier,
                                        )
                                        .requestIndex(
                                          AppTabIndex.search,
                                          initialLocation: true,
                                        );
                                  },
                                  onOpenFilters: () {
                                    ref
                                        .read(
                                          appTabSwitchRequestProvider.notifier,
                                        )
                                        .requestIndex(
                                          AppTabIndex.search,
                                          initialLocation: true,
                                        );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 10.h, 0, 0),
                child: _CategoryTabsRow(
                  categories: [
                    'All',
                    ...HomeV2SectionRenderer._categories
                        .take(8)
                        .map((c) => c.name),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
            Consumer(
              builder: (context, ref, _) {
                final sectionStates = ref.watch(homeFeedControllerProvider);
                final isLoadingMore = ref.watch(
                  homeViewModelProvider.select(
                    (s) => s is HomeData ? s.isLoadingMore : false,
                  ),
                );
                final hasMore = ref.watch(
                  homeViewModelProvider.select((s) => s is HomeData ? s.hasMore : false),
                );

                return _RebuildTracker(
                  label: 'home.sections',
                  child: SliverMainAxisGroup(
                    slivers: HomeV2SectionRenderer(
                      items: items,
                      isRefreshing: isRefreshing,
                      isLoadingMore: isLoadingMore,
                      hasMore: hasMore,
                    ).buildSlivers(
                      context: context,
                      ref: ref,
                      sectionStates: sectionStates,
                    ),
                  ),
                );
              },
            ),
            SliverToBoxAdapter(child: SizedBox(height: 14.h)),
          ],
        ),
      ),
    );
  }
}

class _RebuildTracker extends StatelessWidget {
  const _RebuildTracker({required this.label, required this.child});

  final String label;
  final Widget child;

  static final Map<String, int> _counts = <String, int>{};

  static const bool _enabled = bool.fromEnvironment(
    'ENABLE_REBUILD_TRACKER',
    defaultValue: false,
  );

  @override
  Widget build(BuildContext context) {
    if (!_enabled) return child;
    assert(() {
      final next = (_counts[label] ?? 0) + 1;
      _counts[label] = next;
      debugPrint('REBUILD [$label] #$next');
      return true;
    }());
    return child;
  }
}

class HomeV2SectionRenderer {
  HomeV2SectionRenderer({
    required this.items,
    required this.isRefreshing,
    required this.isLoadingMore,
    required this.hasMore,
  });

  final List<Product> items;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool hasMore;

  static const _categories = <_HomeCategory>[
    _HomeCategory(
      name: 'Groceries',
      imageUrl:
          'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=400&q=70',
    ),
    _HomeCategory(
      name: 'Restaurants',
      imageUrl:
          'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?auto=format&fit=crop&w=400&q=70',
    ),
    _HomeCategory(
      name: 'Pharmacy',
      imageUrl:
          'https://images.unsplash.com/photo-1580281658628-95e5b6f3c4f9?auto=format&fit=crop&w=400&q=70',
    ),
    _HomeCategory(
      name: 'Coffee',
      imageUrl:
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=400&q=70',
    ),
    _HomeCategory(
      name: 'Bakery',
      imageUrl:
          'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?auto=format&fit=crop&w=400&q=70',
    ),
    _HomeCategory(
      name: 'Electronics',
      imageUrl:
          'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=400&q=70',
    ),
    _HomeCategory(
      name: 'Flowers',
      imageUrl:
          'https://images.unsplash.com/photo-1490750967868-88aa4486c946?auto=format&fit=crop&w=400&q=70',
    ),
    _HomeCategory(
      name: 'Pet Supplies',
      imageUrl:
          'https://images.unsplash.com/photo-1548767797-d8c844163c4c?auto=format&fit=crop&w=400&q=70',
    ),
    _HomeCategory(
      name: 'Cosmetics',
      imageUrl:
          'https://images.unsplash.com/photo-1526045478516-99145907023c?auto=format&fit=crop&w=400&q=70',
    ),
    _HomeCategory(
      name: 'Snacks',
      imageUrl:
          'https://images.unsplash.com/photo-1584270354949-1d52f0d8c2d0?auto=format&fit=crop&w=400&q=70',
    ),
    _HomeCategory(
      name: 'Drinks',
      imageUrl:
          'https://images.unsplash.com/photo-1544145945-f90425340c7e?auto=format&fit=crop&w=400&q=70',
    ),
    _HomeCategory(
      name: 'Baby',
      imageUrl:
          'https://images.unsplash.com/photo-1588072432836-10c7f2d9c1f2?auto=format&fit=crop&w=400&q=70',
    ),
  ];

  List<Widget> buildSlivers({
    required BuildContext context,
    required WidgetRef ref,
    required List<HomeSectionState> sectionStates,
  }) {
    final out = <Widget>[];

    for (final s in sectionStates) {
      out.addAll(_buildSection(context: context, ref: ref, state: s));
    }

    if (isLoadingMore) {
      out.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 18.h),
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
      out.add(const SliverToBoxAdapter(child: SizedBox(height: 18)));
    }

    return out;
  }

  List<Widget> _buildSection({
    required BuildContext context,
    required WidgetRef ref,
    required HomeSectionState state,
  }) {
    List<Product> takeSafe(Iterable<Product> src, int n) {
      return src.take(n).toList(growable: false);
    }
    void openTrending() => context.push(AppRoutes.trendingNow);
    void openPicked() => context.push(AppRoutes.pickedForYou);

    return switch (state.id) {
      HomeSectionId.heroCarousel => _heroCarouselSlivers(
        context: context,
        items: takeSafe(items, 5),
      ),
      HomeSectionId.categoriesGrid => _categoriesSlivers(context: context),
      HomeSectionId.editorialBanner => _editorialBannerSlivers(
        context: context,
      ),
      HomeSectionId.trendsEditorial => _trendsEditorialSlivers(
        context: context,
      ),
      HomeSectionId.trendingHeader => _headerSliver(
        title: 'Trending now',
        subtitle: 'Ranked by what people are tapping today',
        onSeeAll: openTrending,
      ),
      HomeSectionId.trendingFeed => _trendingSlivers(
        context: context,
        ref: ref,
        items: takeSafe(items, 10),
      ),
      HomeSectionId.pickedHeader => _headerSliver(
        title: 'Picked for you',
        subtitle: 'Quick matches based on your taste (demo)',
        onSeeAll: openPicked,
      ),
      HomeSectionId.pickedFeed => _pickedForYouSlivers(
        context: context,
        ref: ref,
        items: takeSafe(items.reversed, 10),
        onTapSeeAll: openPicked,
      ),
      HomeSectionId.browseResults => const <Widget>[],
    };
  }

  List<Widget> _trendsEditorialSlivers({required BuildContext context}) {
    return const [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(12, 8, 12, 0),
        sliver: SliverToBoxAdapter(
          child: NovaSectionHeader(
            title: 'Curated trends',
            subtitle: 'Editor’s picks — styled, versatile, and easy to pair.',
          ),
        ),
      ),
      TrendsEditorialSliverSection(),
    ];
  }

  List<Widget> _headerSliver({
    required String title,
    required String subtitle,
    required VoidCallback onSeeAll,
  }) {
    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 0),
        sliver: SliverToBoxAdapter(
          child: NovaSectionHeader(
            title: title,
            subtitle: subtitle,
            trailing: IconButton(
              tooltip: 'See all',
              onPressed: onSeeAll,
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _heroCarouselSlivers({
    required BuildContext context,
    required List<Product> items,
  }) {
    if (items.isEmpty) return const <Widget>[];

    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        sliver: SliverToBoxAdapter(
          child: _HeroCarousel(
            items: items,
            onTap: (p) => context.push('${AppRoutes.product}?id=${p.id}'),
          ),
        ),
      ),
      SliverToBoxAdapter(child: SizedBox(height: 14.h)),
    ];
  }

  List<Widget> _categoriesSlivers({required BuildContext context}) {
    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 0),
        sliver: SliverToBoxAdapter(
          child: NovaSectionHeader(
            title: 'Shop by category',
            subtitle: 'Quick entry points',
            trailing: TextButton.icon(
              onPressed: () => context.push(AppRoutes.search),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('See all'),
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.crossAxisExtent;
            final spacing = 10.0;

            final tileHeight = width < 360
                ? 118.0
                : (width < 480 ? 128.0 : (width < 720 ? 132.0 : 146.0));

            final maxVisible = ResponsiveGridDelegate.maxVisibleItems(
              width: width,
              maxRows: 2,
            );

            final visibleCategoriesCount = (maxVisible - 1).clamp(
              0,
              _categories.length,
            );

            final childCount = visibleCategoriesCount + 1;

            return SliverGrid(
              gridDelegate: ResponsiveGridDelegate.sliverGridDelegate(
                width: width,
                spacing: spacing,
                tileHeight: tileHeight,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index == childCount - 1) {
                  return RepaintBoundary(
                    child: CategoryTile.seeAll(
                      onTap: () => context.push(AppRoutes.search),
                    ),
                  );
                }

                final c = _categories[index];
                final badgeText = index == 1 ? 'New' : null;
                final subtitle = '${120 + (index * 18)} items';

                return RepaintBoundary(
                  child: CategoryTile(
                    title: c.name,
                    subtitle: subtitle,
                    badgeText: badgeText,
                    icon: _iconForCategory(c.name),
                    onTap: () => context.push(AppRoutes.search),
                  ),
                );
              }, childCount: childCount),
            );
          },
        ),
      ),
    ];
  }

  List<Widget> _editorialBannerSlivers({required BuildContext context}) {
    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 6.h),
        sliver: SliverToBoxAdapter(
          child: _EditorialBanner(
            title: 'Weekend Sale',
            subtitle: 'Extra 15% off selected items',
            cta: 'Shop now',
            imageUrl:
                'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=1200&q=70',
            onTap: () => context.push(AppRoutes.search),
          ),
        ),
      ),
      SliverToBoxAdapter(child: SizedBox(height: 10.h)),
    ];
  }

  List<Widget> _pickedForYouSlivers({
    required BuildContext context,
    required WidgetRef ref,
    required List<Product> items,
    required VoidCallback onTapSeeAll,
  }) {
    if (items.isEmpty) return const <Widget>[];

    final wishlistIds = ref.watch(wishlistIdsProvider);

    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(0, 6.h, 0, 0),
        sliver: SliverToBoxAdapter(
          child: PickedForYouCarousel(
            items: items,
            isSaved: (p) => wishlistIds.contains(p.id),
            onToggleSaved: (p) =>
                ref.read(wishlistViewModelProvider.notifier).toggle(p.id),
            onTap: (p) => context.push('${AppRoutes.product}?id=${p.id}'),
            onTapSeeAll: onTapSeeAll,
          ),
        ),
      ),
      SliverToBoxAdapter(child: SizedBox(height: 10.h)),
      SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.crossAxisExtent;
          if (width < 600) return const SliverToBoxAdapter();

          final crossAxisCount = width < 900 ? 2 : 3;
          const spacing = 10.0;

          final availableWidth = width - 24.w;
          final tileWidth =
              (availableWidth - (crossAxisCount - 1) * spacing) /
              crossAxisCount;

          return SliverPadding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                childAspectRatio: 0.80,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index >= items.length) return const SizedBox.shrink();
                final p = items[index];
                final saved = wishlistIds.contains(p.id);

                return PickedForYouCard(
                  product: p,
                  isSaved: saved,
                  imageWidth: tileWidth,
                  compact: true,
                  onTap: () => context.push('${AppRoutes.product}?id=${p.id}'),
                  onToggleSaved: () =>
                      ref.read(wishlistViewModelProvider.notifier).toggle(p.id),
                );
              }, childCount: items.length),
            ),
          );
        },
      ),
    ];
  }

  List<Widget> _trendingSlivers({
    required BuildContext context,
    required WidgetRef ref,
    required List<Product> items,
  }) {
    if (items.isEmpty) return const <Widget>[];

    final wishlistIds = ref.watch(wishlistIdsProvider);

    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 10.h),
        sliver: const SliverToBoxAdapter(child: _TrendingMetaRow()),
      ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.crossAxisExtent;

            final crossAxisCount = width < 420
                ? 1
                : (width < 720 ? 2 : (width < 940 ? 3 : 4));

            if (crossAxisCount == 1) {
              final hero = items.first;
              final rest = items.skip(1).toList(growable: false);

              final isHeroSaved = wishlistIds.contains(hero.id);

              return SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: TrendingHeroCard(
                      rank: 1,
                      product: hero,
                      isSaved: isHeroSaved,
                      onTap: () =>
                          context.push('${AppRoutes.product}?id=${hero.id}'),
                      onToggleSaved: () => ref
                          .read(wishlistViewModelProvider.notifier)
                          .toggle(hero.id),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final p = rest[index];
                      final rank = index + 2;
                      final isSaved = wishlistIds.contains(p.id);

                      return Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: TrendingRankRow(
                          rank: rank,
                          product: p,
                          isSaved: isSaved,
                          onTap: () =>
                              context.push('${AppRoutes.product}?id=${p.id}'),
                          onToggleSaved: () => ref
                              .read(wishlistViewModelProvider.notifier)
                              .toggle(p.id),
                        ),
                      );
                    }, childCount: rest.length),
                  ),
                ],
              );
            }

            const spacing = 10.0;
            final tileWidth =
                (width - (crossAxisCount - 1) * spacing) / crossAxisCount;

            return SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                childAspectRatio: 0.62,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final p = items[index];
                final rank = index + 1;
                final isSaved = wishlistIds.contains(p.id);

                return TrendingCard(
                  rank: rank,
                  product: p,
                  imageWidth: tileWidth,
                  isSaved: isSaved,
                  onTap: () => context.push('${AppRoutes.product}?id=${p.id}'),
                  onToggleSaved: () =>
                      ref.read(wishlistViewModelProvider.notifier).toggle(p.id),
                );
              }, childCount: items.length),
            );
          },
        ),
      ),
      SliverToBoxAdapter(child: SizedBox(height: 4.h)),
    ];
  }
}

class _HomeV2Skeleton extends StatelessWidget {
  const _HomeV2Skeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          titleSpacing: 12,
          title: Row(
            children: [
              const Text('Nova'),
              SizedBox(width: 10.w),
              const SizedBox(
                width: 110,
                child: NovaSkeleton(child: NovaSkeletonBox(height: 28)),
              ),
              const Spacer(),
              IconButton(
                key: const Key('home_messages_button'),
                tooltip: 'Messages',
                onPressed: () {},
                icon: const Icon(Icons.chat_bubble_outline_rounded),
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: AppInsets.screen,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const NovaSkeleton(child: NovaSkeletonBox(height: 46)),
              const SizedBox(height: 12),
              const NovaSkeleton(child: NovaSkeletonBox(height: 34)),
              const SizedBox(height: 12),
              const NovaSkeleton(child: NovaSkeletonBox(height: 220)),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final crossAxisCount =
                      ResponsiveGridDelegate.crossAxisCountForWidth(width);
                  final itemCount = (crossAxisCount * 2).clamp(0, 12);

                  return NovaSkeleton(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.15,
                      ),
                      itemBuilder: (context, index) {
                        return const NovaSkeletonBox(height: 116, radius: 18);
                      },
                      itemCount: itemCount,
                    ),
                  );
                },
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.onTap,
    required this.onOpenFilters,
    this.compact = false,
  });

  final VoidCallback onTap;
  final VoidCallback onOpenFilters;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final radius = BorderRadius.circular(AppRadii.xl);
    final borderSide = BorderSide(
      color: cs.outlineVariant.withValues(alpha: 0.72),
    );
    final fillColor = cs.surfaceContainerHighest;

    return Material(
      color: fillColor,
      shape: RoundedRectangleBorder(borderRadius: radius, side: borderSide),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: compact ? 10.h : 12.h,
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: cs.onSurface.withValues(alpha: 0.6)),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Search products',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Filters',
                onPressed: onOpenFilters,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                icon: Icon(
                  Icons.tune,
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTabsRow extends ConsumerWidget {
  const _CategoryTabsRow({required this.categories});

  final List<String> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final active = ref.watch(homeActiveCategoryProvider);

    return SizedBox(
      height: 34.h,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final label = categories[index];
          final selected = label == active;
          return _CategoryTabChip(
            label: label,
            selected: selected,
            onTap: () =>
                ref.read(homeActiveCategoryProvider.notifier).state = label,
            cs: cs,
            index: index,
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemCount: categories.length,
      ),
    );
  }
}

class _CategoryTabChip extends StatelessWidget {
  const _CategoryTabChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.cs,
    required this.index,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme cs;
  final int index;

  @override
  Widget build(BuildContext context) {
    final borderC = HomeFilterChipStyle.borderColor(
      cs: cs,
      index: index,
      selected: selected,
    );
    final fillC = HomeFilterChipStyle.fillColor(
      cs: cs,
      index: index,
      selected: selected,
    );

    final shadows = HomeFilterChipStyle.shadows(
      cs: cs,
      index: index,
      selected: selected,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(999.r),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: fillC,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: borderC),
          boxShadow: shadows,
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: HomeFilterChipStyle.labelStyle(
              context: context,
              cs: cs,
              index: index,
              selected: selected,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel({required this.items, required this.onTap});

  final List<Product> items;
  final ValueChanged<Product> onTap;

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  late final PageController _controller = PageController(
    viewportFraction: 0.92,
  );
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220.h,
          child: PageView.builder(
            controller: _controller,
            padEnds: false,
            itemCount: widget.items.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final p = widget.items[i];
              final isLast = i == widget.items.length - 1;

              return Padding(
                padding: EdgeInsets.only(
                  left: i == 0 ? 12.w : 0,
                  right: isLast ? 0 : 10.w,
                ),
                child: _HeroDealCard(product: p, onTap: () => widget.onTap(p)),
              );
            },
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.items.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: i == _index ? 18.w : 7.w,
                height: 7.w,
                decoration: BoxDecoration(
                  color:
                      (i == _index
                              ? cs.primary
                              : cs.onSurface.withValues(alpha: 0.28))
                          .withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _HeroDealCard extends StatelessWidget {
  const _HeroDealCard({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppRadii.xl);
    final dpr = MediaQuery.devicePixelRatioOf(context);

    return InkWell(
      borderRadius: radius,
      onTap: onTap,
      child: RepaintBoundary(
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: radius),
          child: Stack(
            children: [
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final memCacheWidth = (constraints.maxWidth * dpr).round();
                    final memCacheHeight = (constraints.maxHeight * dpr)
                        .round();
                    return AppCachedNetworkImage(
                      url: product.imageUrl,
                      backgroundColor: cs.surfaceContainerHigh,
                      memCacheWidth: memCacheWidth,
                      memCacheHeight: memCacheHeight,
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.58, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.12),
                        Colors.black.withValues(alpha: 0.52),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16.w,
                right: 16.w,
                bottom: 16.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.10,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: cs.surface.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.45),
                        ),
                        boxShadow: AppShadows.sm(),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        child: Text(
                          '${product.currency} ${product.price.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface,
                              ),
                        ),
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

class _EditorialBanner extends StatelessWidget {
  const _EditorialBanner({
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.imageUrl,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String cta;
  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppRadii.xl);
    final dpr = MediaQuery.devicePixelRatioOf(context);

    return InkWell(
      borderRadius: radius,
      onTap: onTap,
      child: RepaintBoundary(
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: radius),
          child: SizedBox(
            height: 170.h,
            child: Stack(
              children: [
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final memCacheWidth = (constraints.maxWidth * dpr)
                          .round();
                      final memCacheHeight = (constraints.maxHeight * dpr)
                          .round();
                      return AppCachedNetworkImage(
                        url: imageUrl,
                        backgroundColor: cs.surfaceContainerHigh,
                        memCacheWidth: memCacheWidth,
                        memCacheHeight: memCacheHeight,
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.0, 0.55, 1.0],
                        colors: [
                          cs.primary.withValues(alpha: 0.44),
                          Colors.black.withValues(alpha: 0.28),
                          Colors.black.withValues(alpha: 0.46),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 14.w,
                  right: 14.w,
                  bottom: 14.h,
                  top: 14.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 160.w,
                        child: AppButton.primary(label: cta, onPressed: onTap),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrendingMetaRow extends StatelessWidget {
  const _TrendingMetaRow();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          Icons.local_fire_department_outlined,
          size: 18.r,
          color: cs.primary.withValues(alpha: 0.92),
        ),
        SizedBox(width: 6.w),
        Text(
          'Updated today',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurface.withValues(alpha: 0.70),
          ),
        ),
        const Spacer(),
        Icon(
          Icons.trending_up_rounded,
          size: 18.r,
          color: cs.onSurface.withValues(alpha: 0.55),
        ),
      ],
    );
  }
}

class TrendingHeroCard extends StatelessWidget {
  const TrendingHeroCard({
    super.key,
    required this.rank,
    required this.product,
    required this.isSaved,
    required this.onTap,
    required this.onToggleSaved,
    this.discountText,
  });

  final int rank;
  final Product product;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onToggleSaved;
  final String? discountText;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppRadii.xl);
    final dpr = ScreenUtil().pixelRatio ?? 1.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
        boxShadow: AppShadows.lg(),
      ),
      child: Material(
        color: cs.surface,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;
                      final memCacheWidth = (w * dpr).round();
                      final memCacheHeight = (h * dpr).round();

                      return Hero(
                        tag: 'product-${product.id}',
                        child: AppCachedNetworkImage(
                          url: product.imageUrl,
                          fit: BoxFit.cover,
                          memCacheWidth: memCacheWidth,
                          memCacheHeight: memCacheHeight,
                          backgroundColor: cs.surfaceContainerHigh,
                        ),
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.55, 1.0],
                        colors: [
                          Colors.black.withValues(alpha: 0.08),
                          Colors.black.withValues(alpha: 0.16),
                          Colors.black.withValues(alpha: 0.52),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 12.w,
                  top: 12.h,
                  child: _TrendingRankBadge(rank: rank, large: true),
                ),
                Positioned(
                  right: 10.w,
                  top: 10.h,
                  child: _TrendingWishlistButton(
                    isSaved: isSaved,
                    onPressed: onToggleSaved,
                    large: true,
                  ),
                ),
                Positioned(
                  left: 16.w,
                  right: 16.w,
                  bottom: 16.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.brand.trim().isNotEmpty) ...[
                        Text(
                          product.brand.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.80),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.7,
                              ),
                        ),
                        SizedBox(height: 6.h),
                      ],
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.10,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          _TrendingPriceChip(
                            text:
                                '${product.currency} ${product.price.toStringAsFixed(0)}',
                          ),
                          if (discountText != null &&
                              discountText!.trim().isNotEmpty) ...[
                            SizedBox(width: 8.w),
                            _TrendingDiscountChip(text: discountText!),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TrendingRankRow extends StatelessWidget {
  const TrendingRankRow({
    super.key,
    required this.rank,
    required this.product,
    required this.isSaved,
    required this.onTap,
    required this.onToggleSaved,
  });

  final int rank;
  final Product product;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppRadii.lg);
    final dpr = MediaQuery.devicePixelRatioOf(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: radius,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
        boxShadow: AppShadows.md(),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 78.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    child: SizedBox(
                      width: 58.w,
                      height: 58.w,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final memCacheWidth =
                                    (constraints.maxWidth * dpr).round();
                                final memCacheHeight =
                                    (constraints.maxHeight * dpr).round();

                                return AppCachedNetworkImage(
                                  url: product.imageUrl,
                                  fit: BoxFit.cover,
                                  backgroundColor: cs.surfaceContainerHigh,
                                  memCacheWidth: memCacheWidth,
                                  memCacheHeight: memCacheHeight,
                                );
                              },
                            ),
                          ),
                          Positioned(
                            left: 6.w,
                            top: 6.h,
                            child: _TrendingRankBadge(rank: rank),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          product.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        if (product.brand.trim().isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            product.brand,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: cs.onSurface.withValues(alpha: 0.55),
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${product.currency} ${product.price.toStringAsFixed(0)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            size: 16.r,
                            color: cs.primary.withValues(alpha: 0.85),
                          ),
                          SizedBox(width: 6.w),
                          _TrendingWishlistButton(
                            isSaved: isSaved,
                            onPressed: onToggleSaved,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TrendingCard extends StatelessWidget {
  const TrendingCard({
    super.key,
    required this.rank,
    required this.product,
    required this.imageWidth,
    required this.isSaved,
    required this.onTap,
    required this.onToggleSaved,
  });

  final int rank;
  final Product product;
  final double imageWidth;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppRadii.lg);
    final dpr = ScreenUtil().pixelRatio ?? 1.0;

    final memCacheWidth = (imageWidth * dpr).round();
    final memCacheHeight = (imageWidth * dpr).round();

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
          boxShadow: AppShadows.md(),
        ),
        child: Material(
          color: cs.surface,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Hero(
                          tag: 'product-${product.id}',
                          child: AppCachedNetworkImage(
                            url: product.imageUrl,
                            fit: BoxFit.cover,
                            memCacheWidth: memCacheWidth,
                            memCacheHeight: memCacheHeight,
                            backgroundColor: cs.surfaceContainerHigh,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8.w,
                        top: 8.h,
                        child: _TrendingRankBadge(rank: rank),
                      ),
                      Positioned(
                        right: 6.w,
                        top: 6.h,
                        child: _TrendingWishlistButton(
                          isSaved: isSaved,
                          onPressed: onToggleSaved,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.brand.trim().isNotEmpty) ...[
                        Text(
                          product.brand.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.7,
                                color: cs.onSurface.withValues(alpha: 0.55),
                              ),
                        ),
                        SizedBox(height: 4.h),
                      ],
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      _TrendingPriceChip(
                        text:
                            '${product.currency} ${product.price.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrendingRankBadge extends StatelessWidget {
  const _TrendingRankBadge({required this.rank, this.large = false});

  final int rank;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final r = BorderRadius.circular(AppRadii.pill);

    final padding = large
        ? EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h)
        : EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h);

    final textStyle = large
        ? Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          )
        : Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        gradient: LinearGradient(
          colors: [
            cs.primary.withValues(alpha: 0.98),
            cs.tertiary.withValues(alpha: 0.92),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppShadows.sm(),
      ),
      child: Padding(
        padding: padding,
        child: Text('#$rank', style: textStyle),
      ),
    );
  }
}

class _TrendingWishlistButton extends StatelessWidget {
  const _TrendingWishlistButton({
    required this.isSaved,
    required this.onPressed,
    this.large = false,
  });

  final bool isSaved;
  final VoidCallback onPressed;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = large ? 52.r : 48.r;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
        boxShadow: AppShadows.sm(),
      ),
      child: IconButton(
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(width: size, height: size),
        onPressed: onPressed,
        icon: Icon(
          isSaved ? Icons.favorite : Icons.favorite_border,
          color: isSaved ? cs.primary : cs.onSurface.withValues(alpha: 0.78),
          size: large ? 20.r : 18.r,
        ),
      ),
    );
  }
}

class _TrendingPriceChip extends StatelessWidget {
  const _TrendingPriceChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
        boxShadow: AppShadows.sm(),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
      ),
    );
  }
}

class _TrendingDiscountChip extends StatelessWidget {
  const _TrendingDiscountChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: AppShadows.sm(),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onErrorContainer,
          ),
        ),
      ),
    );
  }
}

class PickedForYouCarousel extends StatefulWidget {
  const PickedForYouCarousel({
    super.key,
    required this.items,
    required this.isSaved,
    required this.onTap,
    required this.onToggleSaved,
    required this.onTapSeeAll,
  });

  final List<Product> items;
  final bool Function(Product product) isSaved;
  final void Function(Product product) onTap;
  final void Function(Product product) onToggleSaved;
  final VoidCallback onTapSeeAll;

  @override
  State<PickedForYouCarousel> createState() => _PickedForYouCarouselState();
}

class _PickedForYouCarouselState extends State<PickedForYouCarousel> {
  PageController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  double _viewportFractionForWidth(double width) {
    if (width < 420) return 0.86;
    if (width < 720) return 0.72;
    if (width < 940) return 0.46;
    return 0.36;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final vf = _viewportFractionForWidth(width);
        final controller = _controller;

        if (controller == null ||
            (controller.viewportFraction - vf).abs() > 0.001) {
          _controller?.dispose();
          _controller = PageController(viewportFraction: vf);
        }

        final activeController = _controller!;

        final cardWidth = width * vf;
        final cardHeight = (cardWidth / 0.80).clamp(260.0, 420.0).toDouble();

        return SizedBox(
          height: cardHeight + 6.h,
          child: Stack(
            children: [
              PageView.builder(
                controller: activeController,
                padEnds: false,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final p = widget.items[index];
                  final saved = widget.isSaved(p);

                  return AnimatedBuilder(
                    animation: activeController,
                    builder: (context, child) {
                      final page = activeController.hasClients
                          ? (activeController.page ??
                                activeController.initialPage.toDouble())
                          : activeController.initialPage.toDouble();
                      final delta = (page - index).abs();
                      final t = (1 - (delta * 0.18)).clamp(0.86, 1.0);

                      return Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 12.w : 10.w,
                          right: 10.w,
                          bottom: 6.h,
                        ),
                        child: Transform.scale(
                          scale: t,
                          alignment: Alignment.center,
                          child: child,
                        ),
                      );
                    },
                    child: PickedForYouCard(
                      product: p,
                      isSaved: saved,
                      imageWidth: cardWidth,
                      onTap: () => widget.onTap(p),
                      onToggleSaved: () => widget.onToggleSaved(p),
                    ),
                  );
                },
              ),
              Positioned(
                right: 10.w,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.surface.withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.45),
                    ),
                    boxShadow: AppShadows.sm(),
                  ),
                  child: IconButton(
                    tooltip: 'See all',
                    onPressed: widget.onTapSeeAll,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    constraints: BoxConstraints.tightFor(
                      width: 48.r,
                      height: 48.r,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PickedForYouCard extends StatelessWidget {
  const PickedForYouCard({
    super.key,
    required this.product,
    required this.isSaved,
    required this.imageWidth,
    required this.onTap,
    required this.onToggleSaved,
    this.discountText,
    this.compact = false,
  });

  final Product product;
  final bool isSaved;
  final double imageWidth;
  final VoidCallback onTap;
  final VoidCallback onToggleSaved;
  final String? discountText;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(compact ? AppRadii.lg : AppRadii.xl);
    final dpr = ScreenUtil().pixelRatio ?? 1.0;

    final memCacheWidth = (imageWidth * dpr).round();
    final memCacheHeight = (imageWidth * dpr).round();

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
          boxShadow: compact ? AppShadows.md() : AppShadows.lg(),
        ),
        child: Material(
          color: cs.surface,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: AspectRatio(
              aspectRatio: 0.80,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: 'product-${product.id}',
                      child: AppCachedNetworkImage(
                        url: product.imageUrl,
                        fit: BoxFit.cover,
                        memCacheWidth: memCacheWidth,
                        memCacheHeight: memCacheHeight,
                        backgroundColor: cs.surfaceContainerHigh,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.04),
                            Colors.black.withValues(alpha: 0.14),
                            Colors.black.withValues(alpha: 0.52),
                          ],
                          stops: const [0.0, 0.58, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10.w,
                    top: 10.h,
                    child: const _PickedForYouBadge(),
                  ),
                  Positioned(
                    right: 10.w,
                    top: 10.h,
                    child: _PickedWishlistButton(
                      isSaved: isSaved,
                      onPressed: onToggleSaved,
                      large: !compact,
                    ),
                  ),
                  Positioned(
                    left: 12.w,
                    right: 12.w,
                    bottom: 12.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.brand.trim().isNotEmpty) ...[
                          Text(
                            product.brand.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.82),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.7,
                                ),
                          ),
                          SizedBox(height: 6.h),
                        ],
                        Text(
                          product.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                height: 1.10,
                              ),
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            _PickedPriceChip(
                              text:
                                  '${product.currency} ${product.price.toStringAsFixed(0)}',
                            ),
                            if (discountText != null &&
                                discountText!.trim().isNotEmpty) ...[
                              SizedBox(width: 8.w),
                              _PickedDiscountChip(text: discountText!),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickedForYouBadge extends StatelessWidget {
  const _PickedForYouBadge();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final r = BorderRadius.circular(AppRadii.pill);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
        gradient: LinearGradient(
          colors: [
            cs.secondary.withValues(alpha: 0.96),
            cs.primary.withValues(alpha: 0.88),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppShadows.sm(),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 16.r, color: Colors.white),
            SizedBox(width: 6.w),
            Text(
              'Picked for you',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickedWishlistButton extends StatelessWidget {
  const _PickedWishlistButton({
    required this.isSaved,
    required this.onPressed,
    required this.large,
  });

  final bool isSaved;
  final VoidCallback onPressed;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = large ? 52.r : 48.r;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
        boxShadow: AppShadows.sm(),
      ),
      child: IconButton(
        tooltip: isSaved ? 'Remove from wishlist' : 'Add to wishlist',
        onPressed: onPressed,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(width: size, height: size),
        icon: Icon(
          isSaved ? Icons.favorite : Icons.favorite_border,
          color: isSaved ? cs.primary : cs.onSurface.withValues(alpha: 0.78),
          size: large ? 20.r : 18.r,
        ),
      ),
    );
  }
}

class _PickedPriceChip extends StatelessWidget {
  const _PickedPriceChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
        boxShadow: AppShadows.sm(),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
      ),
    );
  }
}

class _PickedDiscountChip extends StatelessWidget {
  const _PickedDiscountChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: AppShadows.sm(),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onErrorContainer,
          ),
        ),
      ),
    );
  }
}

class _HomeCategory {
  const _HomeCategory({required this.name, required this.imageUrl});

  final String name;
  final String imageUrl;
}
