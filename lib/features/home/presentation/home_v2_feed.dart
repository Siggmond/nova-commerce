import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:nova_commerce/gen_l10n/app_localizations.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/router/app_tabs.dart';
import '../../../app/config/low_end_device_mode.dart';
import '../../../app/perf/performance_engine.dart';
import '../../../core/errors/app_error_mapper.dart';
import '../../../core/images/image_policy.dart';
import '../../../core/images/nova_image.dart';
import '../../../core/perf/perf_markers.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/nova_section_header.dart';
import '../../../core/widgets/nova_skeleton.dart';
import '../../../core/widgets/responsive_grid_delegate.dart';
import '../../../core/domain/entities/product.dart';
import 'package:nova_commerce/features/wishlist/wishlist.dart';
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

const double _homeHorizontalPadding = 16;
const double _homeSectionGap = 16;
const double _homeSectionTightGap = 12;

class _GoldGiftButton extends StatelessWidget {
  const _GoldGiftButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: AppHitTargets.comfortable,
          height: AppHitTargets.comfortable,
          child: Center(
            child: SizedBox(
              width: 40.r,
              height: 40.r,
              child: SvgPicture.asset(
                'assets/icons/gold.svg',
                fit: BoxFit.contain,
              ),
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
    case 'restaurants':
      return Icons.restaurant_menu_outlined;
    case 'pharmacy':
      return Icons.local_pharmacy_outlined;
    case 'coffee':
      return Icons.local_cafe_outlined;
    case 'electronics':
      return Icons.devices_other_outlined;
    case 'flowers':
      return Icons.local_florist_outlined;
    case 'pet':
      return Icons.pets_outlined;
    case 'cosmetics':
      return Icons.brush_outlined;
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
  late final HomeViewModel _homeViewModelNotifier;

  static const bool _enableFrameTimings = bool.fromEnvironment(
    'ENABLE_FRAME_TIMINGS',
    defaultValue: false,
  );
  static const int _frameJankLogCooldownMs = 950;
  int _lastJankLogMs = 0;

  TimingsCallback? _timingsCallback;

  static const double _searchDockThreshold = 84.0;
  late final ValueNotifier<double> _searchDockTNotifier = ValueNotifier(0);

  static const double _dockedSearchHeight = 48.0;
  static const double _dockedSearchTopPadding = 8.0;
  static const double _dockedSearchBottomPadding = 8.0;
  static const double _dockedSearchPreferredHeight =
      _dockedSearchTopPadding +
      _dockedSearchHeight +
      _dockedSearchBottomPadding;

  int _lastLoadMoreAttemptMs = 0;

  bool _didPrecache = false;
  bool _firstProductsFrameMarked = false;
  bool _productsScrollActive = false;
  Timer? _hintTimer;
  bool _hintShown = false;
  static const bool _enableStartupHintScroll = bool.fromEnvironment(
    'ENABLE_HOME_HINT_SCROLL',
    defaultValue: false,
  );

  @override
  void initState() {
    super.initState();
    _homeViewModelNotifier = ref.read(homeViewModelProvider.notifier);
    _scrollController.addListener(_onScroll);

    if (_enableFrameTimings) {
      _timingsCallback = (timings) {
        for (final t in timings) {
          final buildMs = t.buildDuration.inMicroseconds / 1000.0;
          final rasterMs = t.rasterDuration.inMicroseconds / 1000.0;
          final totalMs = buildMs + rasterMs;
          final now = DateTime.now().millisecondsSinceEpoch;
          if (totalMs > 24 && now - _lastJankLogMs >= _frameJankLogCooldownMs) {
            _lastJankLogMs = now;
            debugPrint(
              'FRAME_JANK build=${buildMs.toStringAsFixed(1)}ms raster=${rasterMs.toStringAsFixed(1)}ms total=${totalMs.toStringAsFixed(1)}ms',
            );
          }
        }
      };
      SchedulerBinding.instance.addTimingsCallback(_timingsCallback!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await SchedulerBinding.instance.endOfFrame;
      if (!mounted) return;
      await _maybePrecacheFirstImages();
      if (!mounted) return;

      final allowHintMotion = ref
          .read(performanceEngineProvider)
          .allowDecorativeMotion;

      if (_enableStartupHintScroll && allowHintMotion) {
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
      }
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    if (_productsScrollActive) {
      _productsScrollActive = false;
      PerfMarkers.productsScrollEnd();
    }
    _homeViewModelNotifier.cancelInFlightPageFetches();
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

  Future<void> _maybePrecacheFirstImages() async {
    if (!mounted) return;
    if (_didPrecache) return;
    final state = ref.read(homeViewModelProvider);
    final items = switch (state) {
      HomeData(:final items) => items,
      _ => const <Product>[],
    };
    if (items.isEmpty) return;

    final urls = items
        .map((item) => item.imageUrl)
        .where((url) => url.trim().isNotEmpty)
        .skip(1)
        .take(8)
        .toList(growable: false);
    if (urls.isEmpty) return;

    _didPrecache = true;
    final logicalWidth = (MediaQuery.sizeOf(context).width / 2).clamp(
      140.0,
      220.0,
    );
    final logicalHeight = (logicalWidth * 1.1).clamp(150.0, 260.0);

    await NovaImagePolicy.prefetchRouteImages(
      context: context,
      urls: urls,
      route: NovaImageRoute.productsGrid,
      logicalWidth: logicalWidth,
      logicalHeight: logicalHeight,
      maxItems: 8,
    );
  }

  void _onScroll() {
    if (!mounted) return;
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;

    final perfState = ref.read(performanceEngineProvider);
    final rawDockT = perfState.highPressure
        ? (position.pixels >= _searchDockThreshold ? 1.0 : 0.0)
        : (position.pixels / _searchDockThreshold).clamp(0.0, 1.0).toDouble();
    final nextT = perfState.highPressure
        ? rawDockT
        : ((rawDockT * 8).round() / 8).clamp(0.0, 1.0).toDouble();
    final prevT = _searchDockTNotifier.value;
    final dockDelta = perfState.highPressure ? 1.0 : 0.12;
    if ((nextT - prevT).abs() >= dockDelta) {
      _searchDockTNotifier.value = nextT;
    }

    final loadMoreTriggerExtent = perfState.homeLoadMoreTriggerExtent;

    if (position.extentAfter < loadMoreTriggerExtent) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final throttleMs = perfState.homeLoadMoreThrottleMs;
      if (now - _lastLoadMoreAttemptMs < throttleMs) return;
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

  bool _onScrollNotification(ScrollNotification notification) {
    if (!mounted) return false;
    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }

    if (notification is ScrollStartNotification ||
        notification is ScrollUpdateNotification) {
      _startProductsScrollWindow();
      return false;
    }

    if (notification is ScrollEndNotification) {
      _endProductsScrollWindow();
      return false;
    }

    if (notification is UserScrollNotification &&
        notification.direction == ScrollDirection.idle) {
      _endProductsScrollWindow();
    }
    return false;
  }

  void _startProductsScrollWindow() {
    if (_productsScrollActive) return;
    _productsScrollActive = true;
    PerfMarkers.productsScrollStart();
  }

  void _endProductsScrollWindow() {
    if (!_productsScrollActive) return;
    _productsScrollActive = false;
    PerfMarkers.productsScrollEnd();
  }

  Future<void> _openCityPicker() async {
    final t = AppLocalizations.of(context)!;
    final resolvedCities = <String>[
      t.homeCityBeirut,
      t.homeCityTripoli,
      t.homeCitySidon,
      t.homeCityTyre,
      t.homeCityJounieh,
      t.homeCityByblos,
      t.homeCityZahle,
      t.homeCityBaalbek,
      t.homeCityNabatieh,
      t.homeCityBatroun,
      t.homeCityBsharri,
      t.homeCityAley,
    ];
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: ListView.separated(
            itemCount: resolvedCities.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final city = resolvedCities[i];
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
    if (!mounted) return;
    await ref.read(deliveryLocationProvider.notifier).setCity(selected);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final homeCacheExtent = ref.watch(
      performanceEngineProvider.select((s) => s.homeScrollCacheExtent),
    );
    final lowEndMode = ref.watch(lowEndDeviceModeProvider);
    final perfReduceMotion = ref.watch(
      performanceEngineProvider.select((s) => !s.allowDecorativeMotion),
    );
    final reduceMotion = lowEndMode || perfReduceMotion;
    final disableExpensiveEffects = lowEndMode || reduceMotion;
    final phase = ref.watch(
      homeViewModelProvider.select(
        (s) => switch (s) {
          HomeLoading() => 0,
          HomeError() => 1,
          HomeData() => 2,
        },
      ),
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
            titleSpacing: _homeHorizontalPadding,
            title: Row(
              children: [
                Text(t.brandName),
                const Spacer(),
                IconButton(
                  key: const Key('home_messages_button'),
                  tooltip: t.messagesTitle,
                  onPressed: () => context.push(AppRoutes.messages),
                  icon: SizedBox(
                    width: 30.r,
                    height: 30.r,
                    child: SvgPicture.asset(
                      'assets/icons/chat.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: AppErrorState(
              title: msg.title,
              subtitle: msg.subtitle,
              actionText: t.commonRetry,
              onAction: () =>
                  ref.read(homeViewModelProvider.notifier).refresh(),
            ),
          ),
        ],
      );
    }

    final shouldPrecache = ref.watch(
      homeViewModelProvider.select(
        (s) => s is HomeData ? s.items.isNotEmpty : false,
      ),
    );

    if (!_didPrecache && shouldPrecache) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await _maybePrecacheFirstImages();
      });
    }

    final snapshot = ref.watch(
      homeViewModelProvider.select(
        (s) => switch (s) {
          HomeData(
            :final items,
            :final isRefreshing,
            :final isLoadingMore,
            :final hasMore,
          ) =>
            (
              items: items,
              isRefreshing: isRefreshing,
              isLoadingMore: isLoadingMore,
              hasMore: hasMore,
            ),
          _ => (
            items: const <Product>[],
            isRefreshing: false,
            isLoadingMore: false,
            hasMore: false,
          ),
        },
      ),
    );
    if (!_firstProductsFrameMarked && snapshot.items.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _firstProductsFrameMarked) return;
        _firstProductsFrameMarked = true;
        PerfMarkers.firstProductsFrame();
      });
    }
    final sectionStates = ref.watch(homeFeedControllerProvider);
    final sectionSlivers = HomeV2SectionRenderer(
      items: snapshot.items,
      isRefreshing: snapshot.isRefreshing,
      isLoadingMore: snapshot.isLoadingMore,
      hasMore: snapshot.hasMore,
      reduceMotion: reduceMotion,
      disableExpensiveEffects: disableExpensiveEffects,
    ).buildSlivers(context: context, ref: ref, sectionStates: sectionStates);

    return RepaintBoundary(
      child: RefreshIndicator(
        onRefresh: () => ref
            .read(homeViewModelProvider.notifier)
            .refresh(showLoading: false),
        child: NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification,
          child: CustomScrollView(
            key: const Key('home_scroll_view'),
            // ignore: deprecated_member_use
            cacheExtent: homeCacheExtent,
            controller: _scrollController,
            slivers: [
              ValueListenableBuilder<double>(
                valueListenable: _searchDockTNotifier,
                builder: (context, dockT, _) {
                  final showDockedSearch = dockT >= 0.85;
                  return _RebuildTracker(
                    label: 'home.header.appbar',
                    child: SliverAppBar(
                      pinned: true,
                      automaticallyImplyLeading: false,
                      titleSpacing: _homeHorizontalPadding,
                      title: Row(
                        children: [
                          Text(
                            t.brandName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(width: AppSpace.sm),
                          Flexible(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 190.w),
                              child: DeliveryLocationChip(
                                onTap: _openCityPicker,
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpace.xs),
                          _GoldGiftButton(
                            onTap: () => context.push(AppRoutes.gold),
                          ),
                        ],
                      ),
                      actions: [
                        IconButton(
                          key: const Key('home_messages_button'),
                          tooltip: t.messagesTitle,
                          onPressed: () => context.push(AppRoutes.messages),
                          icon: SizedBox(
                            width: 30.r,
                            height: 30.r,
                            child: SvgPicture.asset(
                              'assets/icons/chat.svg',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                      bottom: PreferredSize(
                        preferredSize: Size.fromHeight(
                          showDockedSearch ? _dockedSearchPreferredHeight.h : 0,
                        ),
                        child: IgnorePointer(
                          ignoring: !showDockedSearch,
                          child: showDockedSearch
                              ? Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    _homeHorizontalPadding.w,
                                    _dockedSearchTopPadding.h,
                                    _homeHorizontalPadding.w,
                                    _dockedSearchBottomPadding.h,
                                  ),
                                  child: SizedBox(
                                    height: _dockedSearchHeight.h,
                                    child: SearchBarFrame(
                                      docked: true,
                                      reduceEffects: disableExpensiveEffects,
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
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  );
                },
              ),
              ValueListenableBuilder<double>(
                valueListenable: _searchDockTNotifier,
                builder: (context, dockT, _) {
                  final showInlineSearch = dockT <= 0.15;
                  return _RebuildTracker(
                    label: 'home.header.searchInline',
                    child: SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          _homeHorizontalPadding.w,
                          _homeSectionTightGap.h,
                          _homeHorizontalPadding.w,
                          0,
                        ),
                        child: IgnorePointer(
                          ignoring: !showInlineSearch,
                          child: showInlineSearch
                              ? SearchBarFrame(
                                  reduceEffects: disableExpensiveEffects,
                                  child: _SearchBar(
                                    onTap: () {
                                      ref
                                          .read(
                                            homeBrowseFiltersProvider.notifier,
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
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    _homeHorizontalPadding.w,
                    _homeSectionTightGap.h,
                    0,
                    0,
                  ),
                  child: _CategoryTabsRow(
                    categories: HomeV2SectionRenderer.categoryTabIds,
                    disableExpensiveEffects: disableExpensiveEffects,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: _homeSectionGap.h)),
              ...sectionSlivers,
              SliverToBoxAdapter(child: SizedBox(height: _homeSectionGap.h)),
            ],
          ),
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
    required this.reduceMotion,
    required this.disableExpensiveEffects,
  });

  final List<Product> items;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool hasMore;
  final bool reduceMotion;
  final bool disableExpensiveEffects;

  static final List<String> categoryTabIds = <String>[
    'all',
    ..._categories.take(8).map((c) => c.id),
  ];

  static const _categories = <_HomeCategory>[
    _HomeCategory(
      id: 'groceries',
      imageUrl: '',
      backgroundAsset: 'assets/icons/groceries.svg',
    ),
    _HomeCategory(
      id: 'restaurants',
      imageUrl: '',
      backgroundAsset: 'assets/icons/restaurants.svg',
    ),
    _HomeCategory(
      id: 'pharmacy',
      imageUrl: '',
      backgroundAsset: 'assets/icons/pharmacy.svg',
    ),
    _HomeCategory(
      id: 'coffee',
      imageUrl: '',
      backgroundAsset: 'assets/icons/coffee.svg',
    ),
    _HomeCategory(
      id: 'bakery',
      imageUrl: '',
      backgroundAsset: 'assets/icons/bakery.svg',
    ),
    _HomeCategory(id: 'electronics', imageUrl: ''),
    _HomeCategory(id: 'flowers', imageUrl: ''),
    _HomeCategory(id: 'pet', imageUrl: ''),
    _HomeCategory(id: 'cosmetics', imageUrl: ''),
    _HomeCategory(id: 'snacks', imageUrl: ''),
    _HomeCategory(id: 'drinks', imageUrl: ''),
    _HomeCategory(id: 'baby', imageUrl: ''),
  ];

  static String categoryLabel(AppLocalizations t, String id) {
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

  List<Widget> buildSlivers({
    required BuildContext context,
    required WidgetRef ref,
    required List<HomeSectionState> sectionStates,
  }) {
    final t = AppLocalizations.of(context)!;
    final out = <Widget>[];

    for (final s in sectionStates) {
      out.addAll(_buildSection(context: context, ref: ref, state: s, t: t));
    }

    if (isLoadingMore) {
      out.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 18.h),
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.32),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppSpace.md),
                  child: SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      out.add(SliverToBoxAdapter(child: SizedBox(height: _homeSectionGap.h)));
    }

    return out;
  }

  List<Widget> _buildSection({
    required BuildContext context,
    required WidgetRef ref,
    required HomeSectionState state,
    required AppLocalizations t,
  }) {
    List<Product> takeSafe(Iterable<Product> src, int n) {
      final safe = n < 1 ? 1 : n;
      return src.take(safe).toList(growable: false);
    }

    void openTrending() => context.push(AppRoutes.trendingNow);
    void openPicked() => context.push(AppRoutes.pickedForYou);

    return switch (state.id) {
      HomeSectionId.heroCarousel => _heroCarouselSlivers(
        context: context,
        items: takeSafe(items, 5),
        reduceMotion: reduceMotion,
      ),
      HomeSectionId.categoriesGrid => _categoriesSlivers(context: context),
      HomeSectionId.editorialBanner => _editorialBannerSlivers(
        context: context,
      ),
      HomeSectionId.trendsEditorial => _trendsEditorialSlivers(
        context: context,
      ),
      HomeSectionId.trendingHeader => _headerSliver(
        title: t.homeTrendingNowTitle,
        subtitle: t.homeTrendingNowSubtitle,
        onSeeAll: openTrending,
        t: t,
      ),
      HomeSectionId.trendingFeed => _trendingSlivers(
        context: context,
        ref: ref,
        items: takeSafe(items, 10),
      ),
      HomeSectionId.pickedHeader => _headerSliver(
        title: t.homePickedForYouTitle,
        subtitle: t.homePickedForYouSubtitle,
        onSeeAll: openPicked,
        t: t,
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
    final t = AppLocalizations.of(context)!;
    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          _homeHorizontalPadding.w,
          _homeSectionTightGap.h,
          _homeHorizontalPadding.w,
          0,
        ),
        sliver: SliverToBoxAdapter(
          child: NovaSectionHeader(
            title: t.homeCuratedTrendsTitle,
            subtitle: t.homeCuratedTrendsSubtitle,
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
    required AppLocalizations t,
  }) {
    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          _homeHorizontalPadding.w,
          _homeSectionGap.h,
          _homeHorizontalPadding.w,
          0,
        ),
        sliver: SliverToBoxAdapter(
          child: NovaSectionHeader(
            title: title,
            subtitle: subtitle,
            trailing: IconButton(
              tooltip: t.commonSeeAll,
              onPressed: onSeeAll,
              style: IconButton.styleFrom(
                minimumSize: Size(
                  AppHitTargets.comfortable,
                  AppHitTargets.comfortable,
                ),
              ),
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
    required bool reduceMotion,
  }) {
    if (items.isEmpty) return const <Widget>[];

    return [
      SliverPadding(
        padding: EdgeInsets.zero,
        sliver: SliverToBoxAdapter(
          child: _HeroCarousel(
            items: items,
            reduceMotion: reduceMotion,
            disableExpensiveEffects: disableExpensiveEffects,
            onTap: (p) => context.push('${AppRoutes.product}?id=${p.id}'),
          ),
        ),
      ),
      SliverToBoxAdapter(child: SizedBox(height: _homeSectionGap.h)),
    ];
  }

  List<Widget> _categoriesSlivers({required BuildContext context}) {
    final t = AppLocalizations.of(context)!;
    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          _homeHorizontalPadding.w,
          _homeSectionTightGap.h,
          _homeHorizontalPadding.w,
          0,
        ),
        sliver: SliverToBoxAdapter(
          child: NovaSectionHeader(
            title: t.homeShopByCategoryTitle,
            subtitle: t.homeShopByCategorySubtitle,
            trailing: TextButton.icon(
              onPressed: () => context.push(AppRoutes.search),
              icon: Icon(Icons.arrow_forward_rounded, size: 18.r),
              label: Text(t.commonSeeAll),
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          _homeHorizontalPadding.w,
          _homeSectionTightGap.h,
          _homeHorizontalPadding.w,
          _homeSectionTightGap.h,
        ),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.crossAxisExtent;
            final spacing = _homeSectionTightGap;
            final crossAxisCount =
                ResponsiveGridDelegate.crossAxisCountForWidth(width);
            final tileWidth =
                ((width - ((crossAxisCount - 1) * spacing)) / crossAxisCount)
                    .clamp(92.0, 260.0)
                    .toDouble();
            final tileHeight = tileWidth;

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
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == childCount - 1) {
                    return RepaintBoundary(
                      child: CategoryTile.seeAll(
                        title: t.commonSeeAll,
                        reduceEffects: disableExpensiveEffects,
                        onTap: () => context.push(AppRoutes.search),
                      ),
                    );
                  }

                  final c = _categories[index];
                  final badgeText = index == 1 ? t.homeBadgeNew : null;
                  final subtitle = t.homeCategoryItemsCount(120 + (index * 18));

                  return RepaintBoundary(
                    child: CategoryTile(
                      title: HomeV2SectionRenderer.categoryLabel(t, c.id),
                      subtitle: subtitle,
                      badgeText: badgeText,
                      imageUrl: c.imageUrl,
                      backgroundAsset: c.backgroundAsset,
                      icon: _iconForCategory(c.id),
                      reduceEffects: disableExpensiveEffects,
                      onTap: () => context.push(AppRoutes.search),
                    ),
                  );
                },
                childCount: childCount,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
              ),
            );
          },
        ),
      ),
    ];
  }

  List<Widget> _editorialBannerSlivers({required BuildContext context}) {
    final t = AppLocalizations.of(context)!;
    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          _homeHorizontalPadding.w,
          _homeSectionTightGap.h,
          _homeHorizontalPadding.w,
          _homeSectionTightGap.h,
        ),
        sliver: SliverToBoxAdapter(
          child: _EditorialBanner(
            title: t.homeWeekendSaleTitle,
            subtitle: t.homeWeekendSaleSubtitle,
            cta: t.homeWeekendSaleCta,
            backgroundAsset: 'assets/images/weekend-sale.png',
            onTap: () => context.push(AppRoutes.search),
          ),
        ),
      ),
      SliverToBoxAdapter(child: SizedBox(height: _homeSectionTightGap.h)),
    ];
  }

  List<Widget> _pickedForYouSlivers({
    required BuildContext context,
    required WidgetRef ref,
    required List<Product> items,
    required VoidCallback onTapSeeAll,
  }) {
    if (items.isEmpty) return const <Widget>[];

    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(0, _homeSectionTightGap.h, 0, 0),
        sliver: SliverToBoxAdapter(
          child: PickedForYouCarousel(
            items: items,
            reduceMotion: reduceMotion,
            disableExpensiveEffects: disableExpensiveEffects,
            onToggleSaved: (p) =>
                ref.read(wishlistViewModelProvider.notifier).toggle(p.id),
            onTap: (p) => context.push('${AppRoutes.product}?id=${p.id}'),
            onTapSeeAll: onTapSeeAll,
          ),
        ),
      ),
      SliverToBoxAdapter(child: SizedBox(height: _homeSectionTightGap.h)),
      SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.crossAxisExtent;
          if (width < 600) return const SliverToBoxAdapter();

          final crossAxisCount = width < 900 ? 2 : 3;
          const spacing = _homeSectionTightGap;

          final availableWidth = width - (_homeHorizontalPadding * 2).w;
          final tileWidth =
              (availableWidth - (crossAxisCount - 1) * spacing) /
              crossAxisCount;

          return SliverPadding(
            padding: EdgeInsets.fromLTRB(
              _homeHorizontalPadding.w,
              0,
              _homeHorizontalPadding.w,
              _homeSectionTightGap.h,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                childAspectRatio: 0.80,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= items.length) return const SizedBox.shrink();
                  final p = items[index];

                  return Consumer(
                    builder: (context, ref, _) {
                      final saved = ref.watch(
                        wishlistIdsProvider.select((ids) => ids.contains(p.id)),
                      );

                      return PickedForYouCard(
                        product: p,
                        isSaved: saved,
                        imageWidth: tileWidth,
                        compact: true,
                        disableExpensiveEffects: disableExpensiveEffects,
                        onTap: () =>
                            context.push('${AppRoutes.product}?id=${p.id}'),
                        onToggleSaved: () => ref
                            .read(wishlistViewModelProvider.notifier)
                            .toggle(p.id),
                      );
                    },
                  );
                },
                childCount: items.length,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
              ),
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

    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          _homeHorizontalPadding.w,
          _homeSectionTightGap.h,
          _homeHorizontalPadding.w,
          _homeSectionTightGap.h,
        ),
        sliver: SliverToBoxAdapter(child: _TrendingMetaRow()),
      ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          _homeHorizontalPadding.w,
          0,
          _homeHorizontalPadding.w,
          _homeSectionTightGap.h,
        ),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.crossAxisExtent;

            final crossAxisCount = width < 420
                ? 1
                : (width < 720 ? 2 : (width < 940 ? 3 : 4));

            if (crossAxisCount == 1) {
              final hero = items.first;
              final rest = items.skip(1).toList(growable: false);
              final childCount = rest.isEmpty ? 1 : rest.length + 2;

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0) {
                      return Consumer(
                        builder: (context, ref, _) {
                          final isHeroSaved = ref.watch(
                            wishlistIdsProvider.select(
                              (ids) => ids.contains(hero.id),
                            ),
                          );

                          return TrendingHeroCard(
                            rank: 1,
                            product: hero,
                            isSaved: isHeroSaved,
                            disableExpensiveEffects: disableExpensiveEffects,
                            onTap: () => context.push(
                              '${AppRoutes.product}?id=${hero.id}',
                            ),
                            onToggleSaved: () => ref
                                .read(wishlistViewModelProvider.notifier)
                                .toggle(hero.id),
                          );
                        },
                      );
                    }

                    if (index == 1) {
                      return SizedBox(height: 12.h);
                    }

                    final restIndex = index - 2;
                    final p = rest[restIndex];
                    final rank = restIndex + 2;
                    return Consumer(
                      builder: (context, ref, _) {
                        final isSaved = ref.watch(
                          wishlistIdsProvider.select(
                            (ids) => ids.contains(p.id),
                          ),
                        );

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: _homeSectionTightGap.h,
                          ),
                          child: TrendingRankRow(
                            rank: rank,
                            product: p,
                            isSaved: isSaved,
                            disableExpensiveEffects: disableExpensiveEffects,
                            onTap: () =>
                                context.push('${AppRoutes.product}?id=${p.id}'),
                            onToggleSaved: () => ref
                                .read(wishlistViewModelProvider.notifier)
                                .toggle(p.id),
                          ),
                        );
                      },
                    );
                  },
                  childCount: childCount,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: false,
                ),
              );
            }

            const spacing = _homeSectionTightGap;
            final tileWidth =
                (width - (crossAxisCount - 1) * spacing) / crossAxisCount;

            return SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                childAspectRatio: 0.62,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final p = items[index];
                  final rank = index + 1;

                  return Consumer(
                    builder: (context, ref, _) {
                      final isSaved = ref.watch(
                        wishlistIdsProvider.select((ids) => ids.contains(p.id)),
                      );

                      return TrendingCard(
                        rank: rank,
                        product: p,
                        isSaved: isSaved,
                        imageWidth: tileWidth,
                        disableExpensiveEffects: disableExpensiveEffects,
                        onTap: () =>
                            context.push('${AppRoutes.product}?id=${p.id}'),
                        onToggleSaved: () => ref
                            .read(wishlistViewModelProvider.notifier)
                            .toggle(p.id),
                      );
                    },
                  );
                },
                childCount: items.length,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
              ),
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
    final t = AppLocalizations.of(context)!;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          titleSpacing: _homeHorizontalPadding,
          title: Row(
            children: [
              Text(t.brandName),
              SizedBox(width: AppSpace.md),
              SizedBox(
                width: 110.w,
                child: NovaSkeleton(child: NovaSkeletonBox(height: 28.h)),
              ),
              const Spacer(),
              IconButton(
                key: const Key('home_messages_button'),
                tooltip: t.messagesTitle,
                onPressed: () {},
                icon: SizedBox(
                  width: 30.r,
                  height: 30.r,
                  child: SvgPicture.asset(
                    'assets/icons/chat.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: AppInsets.screen,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              NovaSkeleton(child: NovaSkeletonBox(height: 46.h)),
              SizedBox(height: 12.h),
              NovaSkeleton(child: NovaSkeletonBox(height: 34.h)),
              SizedBox(height: 12.h),
              NovaSkeleton(child: NovaSkeletonBox(height: 220.h)),
              SizedBox(height: 14.h),
            ]),
          ),
        ),
        SliverPadding(
          padding: AppInsets.screen,
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.crossAxisExtent;
              final crossAxisCount =
                  ResponsiveGridDelegate.crossAxisCountForWidth(width);
              final itemCount = (crossAxisCount * 2).clamp(0, 12);

              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                  childAspectRatio: 1.15,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  return NovaSkeleton(
                    child: NovaSkeletonBox(height: 116.h, radius: 18.r),
                  );
                }, childCount: itemCount),
              );
            },
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
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final radius = BorderRadius.circular(AppRadii.xl);
    final borderSide = BorderSide(
      color: cs.outlineVariant.withValues(alpha: 0.54),
    );
    final fillColor = cs.surfaceContainerHigh;

    return Material(
      color: fillColor,
      shape: RoundedRectangleBorder(borderRadius: radius, side: borderSide),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
          child: Row(
            children: [
              Icon(
                Icons.search,
                size: 20.r,
                color: cs.onSurface.withValues(alpha: 0.62),
              ),
              SizedBox(width: AppSpace.sm),
              Expanded(
                child: Text(
                  t.searchHintSearchForProducts,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: t.searchTooltipFilters,
                onPressed: onOpenFilters,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: compact ? 40.r : AppHitTargets.min,
                  minHeight: compact ? 40.r : AppHitTargets.min,
                ),
                icon: Icon(
                  Icons.tune,
                  size: 20.r,
                  color: cs.onSurface.withValues(alpha: 0.64),
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
  const _CategoryTabsRow({
    required this.categories,
    required this.disableExpensiveEffects,
  });

  final List<String> categories;
  final bool disableExpensiveEffects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final active = ref.watch(homeActiveCategoryProvider);

    return SizedBox(
      height: AppHitTargets.min,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final label = categories[index];
          final selected = label == active;
          return _CategoryTabChip(
            label: label == 'all'
                ? t.cartFilterAll
                : HomeV2SectionRenderer.categoryLabel(t, label),
            selected: selected,
            onTap: () =>
                ref.read(homeActiveCategoryProvider.notifier).state = label,
            cs: cs,
            index: index,
            disableExpensiveEffects: disableExpensiveEffects,
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
    required this.disableExpensiveEffects,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme cs;
  final int index;
  final bool disableExpensiveEffects;

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
      enabled: !disableExpensiveEffects,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(999.r),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
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
  const _HeroCarousel({
    required this.items,
    required this.onTap,
    required this.reduceMotion,
    required this.disableExpensiveEffects,
  });

  final List<Product> items;
  final ValueChanged<Product> onTap;
  final bool reduceMotion;
  final bool disableExpensiveEffects;

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
            allowImplicitScrolling: false,
            itemCount: widget.items.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final p = widget.items[i];
              final isLast = i == widget.items.length - 1;

              return Padding(
                padding: EdgeInsets.only(
                  left: i == 0 ? _homeHorizontalPadding.w : 0,
                  right: isLast ? _homeHorizontalPadding.w : 12.w,
                ),
                child: _HeroDealCard(
                  product: p,
                  onTap: () => widget.onTap(p),
                  disableExpensiveEffects: widget.disableExpensiveEffects,
                ),
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
                duration: widget.reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
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
  const _HeroDealCard({
    required this.product,
    required this.onTap,
    required this.disableExpensiveEffects,
  });

  final Product product;
  final VoidCallback onTap;
  final bool disableExpensiveEffects;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final radius = BorderRadius.circular(AppRadii.xl);

    return InkWell(
      borderRadius: radius,
      onTap: onTap,
      child: RepaintBoundary(
        child: Card(
          elevation: 0,
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(borderRadius: radius),
          child: Stack(
            children: [
              Positioned.fill(
                child: NovaImage(
                  url: product.imageUrl,
                  route: NovaImageRoute.productsGrid,
                  backgroundColor: cs.surfaceContainerHigh,
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
                      style: tt.labelSmall?.copyWith(
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
                      style: tt.titleLarge?.copyWith(
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
                        boxShadow: disableExpensiveEffects
                            ? const <BoxShadow>[]
                            : AppShadows.sm(),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        child: Text(
                          '${product.currency} ${product.price.toStringAsFixed(0)}',
                          style: tt.labelLarge?.copyWith(
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
    required this.backgroundAsset,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String cta;
  final String backgroundAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final radius = BorderRadius.circular(AppRadii.xl);
    final hasBackgroundAsset = backgroundAsset.trim().isNotEmpty;

    return InkWell(
      borderRadius: radius,
      onTap: onTap,
      child: RepaintBoundary(
        child: Card(
          elevation: 0,
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(borderRadius: radius),
          child: SizedBox(
            height: 170.h,
            child: Stack(
              children: [
                Positioned.fill(
                  child: hasBackgroundAsset
                      ? Image.asset(backgroundAsset, fit: BoxFit.cover)
                      : DecoratedBox(
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHigh,
                          ),
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
                        style: tt.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodyMedium?.copyWith(
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
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Row(
      children: [
        Icon(
          Icons.local_fire_department_outlined,
          size: 18.r,
          color: cs.primary.withValues(alpha: 0.92),
        ),
        SizedBox(width: 6.w),
        Text(
          t.homeUpdatedToday,
          style: tt.labelMedium?.copyWith(
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
    required this.disableExpensiveEffects,
    required this.onTap,
    required this.onToggleSaved,
    this.discountText,
  });

  final int rank;
  final Product product;
  final bool isSaved;
  final bool disableExpensiveEffects;
  final VoidCallback onTap;
  final VoidCallback onToggleSaved;
  final String? discountText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final radius = BorderRadius.circular(AppRadii.xl);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
        boxShadow: disableExpensiveEffects
            ? const <BoxShadow>[]
            : AppShadows.sm(color: Colors.black.withValues(alpha: 0.10)),
      ),
      child: Material(
        color: cs.surface,
        borderRadius: radius,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Hero(
                    tag: 'product-${product.id}',
                    child: NovaImage(
                      url: product.imageUrl,
                      route: NovaImageRoute.productsGrid,
                      fit: BoxFit.cover,
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
                  child: _TrendingRankBadge(
                    rank: rank,
                    large: true,
                    disableExpensiveEffects: disableExpensiveEffects,
                  ),
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
                          style: tt.labelSmall?.copyWith(
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
                        style: tt.titleLarge?.copyWith(
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
    required this.disableExpensiveEffects,
    required this.onTap,
    required this.onToggleSaved,
  });

  final int rank;
  final Product product;
  final bool isSaved;
  final bool disableExpensiveEffects;
  final VoidCallback onTap;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final radius = BorderRadius.circular(AppRadii.lg);

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: radius,
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
          boxShadow: disableExpensiveEffects
              ? const <BoxShadow>[]
              : AppShadows.sm(color: Colors.black.withValues(alpha: 0.10)),
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
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: 58.w,
                        height: 58.w,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: NovaImage(
                                url: product.imageUrl,
                                route: NovaImageRoute.productsGrid,
                                fit: BoxFit.cover,
                                backgroundColor: cs.surfaceContainerHigh,
                              ),
                            ),
                            Positioned(
                              left: 6.w,
                              top: 6.h,
                              child: _TrendingRankBadge(
                                rank: rank,
                                disableExpensiveEffects:
                                    disableExpensiveEffects,
                              ),
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
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (product.brand.trim().isNotEmpty) ...[
                            SizedBox(height: 2.h),
                            Text(
                              product.brand,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tt.labelSmall?.copyWith(
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
                          style: tt.titleSmall?.copyWith(
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
    required this.disableExpensiveEffects,
    required this.onTap,
    required this.onToggleSaved,
  });

  final int rank;
  final Product product;
  final double imageWidth;
  final bool isSaved;
  final bool disableExpensiveEffects;
  final VoidCallback onTap;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final radius = BorderRadius.circular(AppRadii.lg);

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
          boxShadow: disableExpensiveEffects
              ? const <BoxShadow>[]
              : AppShadows.sm(color: Colors.black.withValues(alpha: 0.10)),
        ),
        child: Material(
          color: cs.surface,
          borderRadius: radius,
          clipBehavior: Clip.hardEdge,
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
                          child: NovaImage(
                            url: product.imageUrl,
                            route: NovaImageRoute.productsGrid,
                            fit: BoxFit.cover,
                            logicalDecodeWidth: imageWidth,
                            logicalDecodeHeight: imageWidth,
                            backgroundColor: cs.surfaceContainerHigh,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8.w,
                        top: 8.h,
                        child: _TrendingRankBadge(
                          rank: rank,
                          disableExpensiveEffects: disableExpensiveEffects,
                        ),
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
                          style: tt.labelSmall?.copyWith(
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
                        style: tt.titleSmall?.copyWith(
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
  const _TrendingRankBadge({
    required this.rank,
    this.large = false,
    this.disableExpensiveEffects = false,
  });

  final int rank;
  final bool large;
  final bool disableExpensiveEffects;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final r = BorderRadius.circular(AppRadii.pill);

    final padding = large
        ? EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h)
        : EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h);

    final textStyle = large
        ? tt.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          )
        : tt.labelSmall?.copyWith(
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
        boxShadow: disableExpensiveEffects
            ? const <BoxShadow>[]
            : AppShadows.sm(),
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        child: Text(
          text,
          style: tt.labelLarge?.copyWith(
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        child: Text(
          text,
          style: tt.labelLarge?.copyWith(
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
    required this.reduceMotion,
    required this.disableExpensiveEffects,
    required this.onTap,
    required this.onToggleSaved,
    required this.onTapSeeAll,
  });

  final List<Product> items;
  final bool reduceMotion;
  final bool disableExpensiveEffects;
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
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
                allowImplicitScrolling: false,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final p = widget.items[index];

                  return Consumer(
                    builder: (context, ref, _) {
                      final saved = ref.watch(
                        wishlistIdsProvider.select((ids) => ids.contains(p.id)),
                      );
                      final card = PickedForYouCard(
                        product: p,
                        isSaved: saved,
                        imageWidth: cardWidth,
                        disableExpensiveEffects: widget.disableExpensiveEffects,
                        onTap: () => widget.onTap(p),
                        onToggleSaved: () => widget.onToggleSaved(p),
                      );

                      if (widget.reduceMotion) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: index == 0 ? _homeHorizontalPadding.w : 10.w,
                            right: _homeSectionTightGap.w,
                            bottom: 6.h,
                          ),
                          child: card,
                        );
                      }

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
                              left: index == 0
                                  ? _homeHorizontalPadding.w
                                  : 10.w,
                              right: _homeSectionTightGap.w,
                              bottom: 6.h,
                            ),
                            child: Transform.scale(
                              scale: t,
                              alignment: Alignment.center,
                              child: child,
                            ),
                          );
                        },
                        child: card,
                      );
                    },
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
                    boxShadow: widget.disableExpensiveEffects
                        ? const <BoxShadow>[]
                        : AppShadows.sm(),
                  ),
                  child: IconButton(
                    tooltip: t.commonSeeAll,
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
    required this.disableExpensiveEffects,
    required this.onTap,
    required this.onToggleSaved,
    this.discountText,
    this.compact = false,
  });

  final Product product;
  final bool isSaved;
  final double imageWidth;
  final bool disableExpensiveEffects;
  final VoidCallback onTap;
  final VoidCallback onToggleSaved;
  final String? discountText;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final radius = BorderRadius.circular(compact ? AppRadii.lg : AppRadii.xl);

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
          boxShadow: disableExpensiveEffects
              ? const <BoxShadow>[]
              : AppShadows.sm(color: Colors.black.withValues(alpha: 0.10)),
        ),
        child: Material(
          color: cs.surface,
          borderRadius: radius,
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: onTap,
            child: AspectRatio(
              aspectRatio: 0.80,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: 'product-${product.id}',
                      child: NovaImage(
                        url: product.imageUrl,
                        route: NovaImageRoute.productsGrid,
                        fit: BoxFit.cover,
                        logicalDecodeWidth: imageWidth,
                        logicalDecodeHeight: imageWidth,
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
                    child: _PickedForYouBadge(
                      disableExpensiveEffects: disableExpensiveEffects,
                    ),
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
                            style: tt.labelSmall?.copyWith(
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
                          style: tt.titleMedium?.copyWith(
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
  const _PickedForYouBadge({required this.disableExpensiveEffects});

  final bool disableExpensiveEffects;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
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
        boxShadow: disableExpensiveEffects
            ? const <BoxShadow>[]
            : AppShadows.sm(),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 16.r, color: Colors.white),
            SizedBox(width: 6.w),
            Text(
              t.homePickedForYouTitle,
              style: tt.labelMedium?.copyWith(
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
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final size = large ? 52.r : 48.r;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: IconButton(
        tooltip: isSaved
            ? t.productRemoveFromWishlistTooltip
            : t.productSaveToWishlistTooltip,
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        child: Text(
          text,
          style: tt.labelLarge?.copyWith(
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        child: Text(
          text,
          style: tt.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onErrorContainer,
          ),
        ),
      ),
    );
  }
}

class _HomeCategory {
  const _HomeCategory({
    required this.id,
    required this.imageUrl,
    this.backgroundAsset,
  });

  final String id;
  final String imageUrl;
  final String? backgroundAsset;
}
