import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_routes.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_cached_network_image.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/nova_skeleton.dart';
import '../../../domain/entities/offer.dart';
import '../../../domain/repositories/offers_repository.dart';
import 'offers_viewmodel.dart';
import 'widgets/offer_card.dart';

class OffersScreen extends ConsumerStatefulWidget {
  const OffersScreen({super.key});

  @override
  ConsumerState<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends ConsumerState<OffersScreen> {
  late final TextEditingController _search = TextEditingController();
  late final ScrollController _scroll = ScrollController();

  late final PageController _featuredController = PageController(
    viewportFraction: 0.92,
  );
  final ValueNotifier<int> _featuredIndex = ValueNotifier<int>(0);

  DateTime? _lastLoadMoreAt;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    _search.dispose();
    _featuredController.dispose();
    _featuredIndex.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    if (!position.hasPixels || !position.hasContentDimensions) return;
    if (position.extentAfter > 520) return;

    final now = DateTime.now();
    final last = _lastLoadMoreAt;
    if (last != null && now.difference(last).inMilliseconds < 500) return;
    _lastLoadMoreAt = now;
    ref.read(offersViewModelProvider.notifier).loadMore();
  }

  Future<void> _openFilters() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _OffersFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(offersViewModelProvider);

    if (_search.text != (state.query.searchText ?? '')) {
      final q = state.query.searchText ?? '';
      _search
        ..text = q
        ..selection = TextSelection.collapsed(offset: q.length);
    }

    final featuredList = state.items
        .where((o) => o.isFeatured)
        .take(6)
        .toList(growable: false);
    final heroList = featuredList.isNotEmpty
        ? featuredList
        : state.items.take(6).toList(growable: false);

    Widget buildSkeleton() {
      return Padding(
        padding: AppInsets.screen,
        child: Column(
          children: [
            NovaSkeleton(
              child: NovaSkeletonBox(height: 46.h, radius: AppRadii.lg),
            ),
            SizedBox(height: AppSpace.md),
            NovaSkeleton(
              child: NovaSkeletonBox(height: 44.h, radius: AppRadii.pill),
            ),
            SizedBox(height: AppSpace.md),
            NovaSkeleton(
              child: NovaSkeletonBox(height: 164.h, radius: AppRadii.lg),
            ),
            SizedBox(height: AppSpace.md),
            NovaSkeleton(
              child: NovaSkeletonBox(height: 440.h, radius: AppRadii.lg),
            ),
          ],
        ),
      );
    }

    Widget buildSearchPill() {
      return SizedBox(
        height: 46.h,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.28),
            ),
            boxShadow: AppShadows.sm(),
          ),
          child: TextField(
            controller: _search,
            onChanged: (v) => ref
                .read(offersViewModelProvider.notifier)
                .setSearchTextDebounced(v),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search offers',
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(14.w, 12.h, 10.w, 12.h),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 24.r,
                color: cs.onSurface.withValues(alpha: 0.72),
              ),
              suffixIcon: (state.query.searchText ?? '').trim().isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      onPressed: () {
                        _search.clear();
                        ref
                            .read(offersViewModelProvider.notifier)
                            .setSearchTextDebounced('');
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        size: 22.r,
                        color: cs.onSurface.withValues(alpha: 0.72),
                      ),
                    ),
            ),
          ),
        ),
      );
    }

    Widget buildQuickTabs() {
      return _PremiumQuickTabs(
        value: state.quickFilter,
        onChanged: (next) =>
            ref.read(offersViewModelProvider.notifier).setQuickFilter(next),
      );
    }

    Widget buildHero() {
      if (heroList.isEmpty) return const SizedBox.shrink();
      return _FeaturedOffersCarousel(
        offers: heroList,
        controller: _featuredController,
        indexListenable: _featuredIndex,
        onOpenFilters: _openFilters,
        onTapOffer: (offer) => context.push('${AppRoutes.offers}/${offer.id}'),
      );
    }

    Widget buildResultsSliver() {
      return SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.crossAxisExtent;

          final isPhoneList = width < 520;
          final itemCount = state.items.length + (state.isLoadingMore ? 1 : 0);

          if (isPhoneList) {
            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index >= state.items.length) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    child: const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ),
                  );
                }

                final offer = state.items[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: OfferCard(
                    key: ValueKey('offer_${offer.id}'),
                    offer: offer,
                    variant: OfferCardVariant.row,
                    onTap: () =>
                        context.push('${AppRoutes.offers}/${offer.id}'),
                  ),
                );
              }, childCount: itemCount),
            );
          }

          final crossAxisCount = width < 720 ? 2 : 3;

          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 10.w,
              childAspectRatio: 1.35,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index >= state.items.length) {
                return const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                );
              }

              final offer = state.items[index];
              return OfferCard(
                key: ValueKey('offer_${offer.id}'),
                offer: offer,
                variant: OfferCardVariant.grid,
                onTap: () => context.push('${AppRoutes.offers}/${offer.id}'),
              );
            }, childCount: itemCount),
          );
        },
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(offersViewModelProvider.notifier)
            .refresh(showLoading: false),
        child: CustomScrollView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              toolbarHeight: 72.h,
              title: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
                child: Row(
                  children: [
                    _NovaOffersBadge(size: 40.r),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Offers',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.35,
                                ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Exclusive deals curated for you',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.65),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Filters',
                      onPressed: _openFilters,
                      icon: const Icon(Icons.tune_rounded),
                    ),
                  ],
                ),
              ),
            ),
            if (state.isLoading && state.items.isEmpty) ...[
              SliverToBoxAdapter(child: buildSkeleton()),
            ] else ...[
              SliverPadding(
                padding: AppInsets.screenTight,
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6.h),
                      buildSearchPill(),
                      SizedBox(height: 10.h),
                      buildQuickTabs(),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(0, 8.h, 0, 0),
                sliver: SliverToBoxAdapter(child: buildHero()),
              ),
              if (state.error != null && state.items.isEmpty) ...[
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppErrorState(
                    title: 'Could not load offers',
                    subtitle: state.error.toString(),
                    actionText: 'Retry',
                    onAction: () => ref
                        .read(offersViewModelProvider.notifier)
                        .refresh(showLoading: true),
                  ),
                ),
              ] else if (state.items.isEmpty) ...[
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(
                    title: 'No offers found',
                    subtitle: 'Try a different filter or search.',
                    icon: Icons.local_offer_outlined,
                  ),
                ),
              ] else ...[
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 16.h),
                  sliver: buildResultsSliver(),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _NovaOffersBadge extends StatelessWidget {
  const _NovaOffersBadge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, cs.primaryContainer],
        ),
        boxShadow: AppShadows.sm(),
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(
          Icons.local_offer_rounded,
          color: Colors.white,
          size: (size * 0.52),
        ),
      ),
    );
  }
}

class _PremiumQuickTabs extends StatelessWidget {
  const _PremiumQuickTabs({required this.value, required this.onChanged});

  final OffersQuickFilter value;
  final ValueChanged<OffersQuickFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    const items = <({String label, OffersQuickFilter value})>[
      (label: 'All', value: OffersQuickFilter.all),
      (label: 'New', value: OffersQuickFilter.newOffers),
      (label: 'Popular', value: OffersQuickFilter.popular),
      (label: 'Expiring', value: OffersQuickFilter.expiring),
      (label: 'Online', value: OffersQuickFilter.online),
      (label: 'In-store', value: OffersQuickFilter.inStore),
    ];

    return SizedBox(
      height: 42.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = items[index];
          final selected = item.value == value;

          return InkWell(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            onTap: () => onChanged(item.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: selected
                    ? cs.surfaceContainerLow
                    : cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(
                  color: selected
                      ? cs.primary.withValues(alpha: 0.75)
                      : cs.outlineVariant.withValues(alpha: 0.25),
                  width: selected ? 1.4 : 1,
                ),
                boxShadow: selected
                    ? AppShadows.sm(color: cs.primary.withValues(alpha: 0.22))
                    : AppShadows.sm(
                        color: AppShadows.shadowColor.withValues(alpha: 0.10),
                      ),
              ),
              child: Center(
                child: Text(
                  item.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.1,
                    color: selected
                        ? cs.primary
                        : cs.onSurface.withValues(alpha: 0.78),
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemCount: items.length,
      ),
    );
  }
}

class _FeaturedOffersCarousel extends StatelessWidget {
  const _FeaturedOffersCarousel({
    required this.offers,
    required this.controller,
    required this.indexListenable,
    required this.onOpenFilters,
    required this.onTapOffer,
  });

  final List<Offer> offers;
  final PageController controller;
  final ValueNotifier<int> indexListenable;
  final VoidCallback onOpenFilters;
  final ValueChanged<Offer> onTapOffer;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        SizedBox(
          height: 176.h,
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollUpdateNotification && controller.page != null) {
                final next = controller.page!.round().clamp(
                  0,
                  offers.length - 1,
                );
                if (indexListenable.value != next) indexListenable.value = next;
              }
              return false;
            },
            child: PageView.builder(
              controller: controller,
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final offer = offers[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: _FeaturedHeroCard(
                    offer: offer,
                    onTap: () => onTapOffer(offer),
                    onOpenFilters: onOpenFilters,
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 10.h),
        ValueListenableBuilder<int>(
          valueListenable: indexListenable,
          builder: (context, index, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < offers.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    width: i == index ? 18.w : 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: i == index
                          ? cs.primary.withValues(alpha: 0.92)
                          : cs.outlineVariant.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _FeaturedHeroCard extends StatelessWidget {
  const _FeaturedHeroCard({
    required this.offer,
    required this.onTap,
    required this.onOpenFilters,
  });

  final Offer offer;
  final VoidCallback onTap;
  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppRadii.xl);

    return InkWell(
      borderRadius: radius,
      onTap: onTap,
      child: Card(
        elevation: AppElevation.card,
        shadowColor: AppShadows.shadowColor.withValues(alpha: 0.14),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: radius),
        child: Stack(
          children: [
            Positioned.fill(
              child: AppCachedNetworkImage(
                url: offer.imageUrl,
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
                      Colors.black.withValues(alpha: 0.06),
                      Colors.black.withValues(alpha: 0.62),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14.w,
              right: 14.w,
              top: 12.h,
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      child: Text(
                        'Featured Deal',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Filters',
                    onPressed: onOpenFilters,
                    icon: Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 22.r,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 14.w,
              right: 14.w,
              bottom: 14.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    offer.brandName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  AppButton.primary(
                    label: 'Shop deal',
                    onPressed: onTap,
                    icon: Icons.arrow_forward_rounded,
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

enum _OfferPriceTier { under25, under50, highValue }

class _OffersFilterSheet extends ConsumerStatefulWidget {
  const _OffersFilterSheet();

  @override
  ConsumerState<_OffersFilterSheet> createState() => _OffersFilterSheetState();
}

class _OffersFilterSheetState extends ConsumerState<_OffersFilterSheet> {
  late OfferSort _sort;
  late _OfferPriceTier? _priceTier;
  late OfferChannel? _channel;
  late Set<String> _categories;

  @override
  void initState() {
    super.initState();
    final s = ref.read(offersViewModelProvider);
    _sort = s.query.sort;
    _channel = s.query.channel;
    _priceTier = null;
    _categories = <String>{...(s.query.tags ?? const <String>[])};
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.vertical(top: Radius.circular(22.r));
    final primary = cs.primary;

    return DraggableScrollableSheet(
      initialChildSize: 0.70,
      minChildSize: 0.56,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, scrollController) {
        return Material(
          color: cs.surface,
          shape: RoundedRectangleBorder(borderRadius: radius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: AppShadows.lg(),
            ),
            child: Column(
              children: [
                SizedBox(height: 8.h),
                Container(
                  width: 42.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 10.w, 8.h),
                  child: Row(
                    children: [
                      Text(
                        'Filters',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          ref
                              .read(offersViewModelProvider.notifier)
                              .clearAllFiltersPreserveSearch();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Clear all',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
                    children: [
                      _SheetSectionTitle(title: 'Sort by'),
                      SizedBox(height: 8.h),
                      _SortChips(
                        value: _sort,
                        onChanged: (v) => setState(() => _sort = v),
                      ),
                      SizedBox(height: 16.h),
                      _SheetSectionTitle(title: 'Price tier'),
                      SizedBox(height: 8.h),
                      _PriceTierChips(
                        value: _priceTier,
                        onChanged: (v) => setState(() => _priceTier = v),
                      ),
                      SizedBox(height: 16.h),
                      _SheetSectionTitle(title: 'Channel'),
                      SizedBox(height: 8.h),
                      _ChannelChips(
                        value: _channel,
                        onChanged: (v) => setState(() => _channel = v),
                      ),
                      SizedBox(height: 16.h),
                      _SheetSectionTitle(title: 'Categories'),
                      SizedBox(height: 8.h),
                      _CategoryChips(
                        selected: _categories,
                        onToggle: (tag) {
                          setState(() {
                            if (_categories.contains(tag)) {
                              _categories.remove(tag);
                            } else {
                              _categories.add(tag);
                            }
                          });
                        },
                      ),
                      SizedBox(height: 18.h),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
                    child: SizedBox(
                      width: double.infinity,
                      child: AppButton.primary(
                        label: 'Apply',
                        onPressed: () {
                          final tags = <String>{..._categories};
                          final tier = _priceTier;
                          if (tier != null) {
                            tags.add(switch (tier) {
                              _OfferPriceTier.under25 => 'under25',
                              _OfferPriceTier.under50 => 'under50',
                              _OfferPriceTier.highValue => 'highvalue',
                            });
                          }

                          ref
                              .read(offersViewModelProvider.notifier)
                              .applyFilters(
                                sort: _sort,
                                tags: tags.isEmpty
                                    ? null
                                    : tags.toList(growable: false),
                                channel: _channel,
                              );
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SheetSectionTitle extends StatelessWidget {
  const _SheetSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _SortChips extends StatelessWidget {
  const _SortChips({required this.value, required this.onChanged});

  final OfferSort value;
  final ValueChanged<OfferSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: [
        _FilterChip(
          label: 'Recommended',
          selected: value == OfferSort.recommended,
          onTap: () => onChanged(OfferSort.recommended),
        ),
        _FilterChip(
          label: 'Ending soon',
          selected: value == OfferSort.endingSoon,
          onTap: () => onChanged(OfferSort.endingSoon),
        ),
        _FilterChip(
          label: 'Highest discount',
          selected: value == OfferSort.highestDiscount,
          onTap: () => onChanged(OfferSort.highestDiscount),
        ),
        _FilterChip(
          label: 'Newest',
          selected: value == OfferSort.newest,
          onTap: () => onChanged(OfferSort.newest),
        ),
      ],
    );
  }
}

class _PriceTierChips extends StatelessWidget {
  const _PriceTierChips({required this.value, required this.onChanged});

  final _OfferPriceTier? value;
  final ValueChanged<_OfferPriceTier?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: [
        _FilterChip(
          label: 'Under \$25',
          selected: value == _OfferPriceTier.under25,
          onTap: () => onChanged(
            value == _OfferPriceTier.under25 ? null : _OfferPriceTier.under25,
          ),
        ),
        _FilterChip(
          label: 'Under \$50',
          selected: value == _OfferPriceTier.under50,
          onTap: () => onChanged(
            value == _OfferPriceTier.under50 ? null : _OfferPriceTier.under50,
          ),
        ),
        _FilterChip(
          label: 'High value',
          selected: value == _OfferPriceTier.highValue,
          onTap: () => onChanged(
            value == _OfferPriceTier.highValue
                ? null
                : _OfferPriceTier.highValue,
          ),
        ),
      ],
    );
  }
}

class _ChannelChips extends StatelessWidget {
  const _ChannelChips({required this.value, required this.onChanged});

  final OfferChannel? value;
  final ValueChanged<OfferChannel?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: [
        _FilterChip(
          label: 'All',
          selected: value == null,
          onTap: () => onChanged(null),
        ),
        _FilterChip(
          label: 'Online',
          selected: value == OfferChannel.online,
          onTap: () => onChanged(OfferChannel.online),
        ),
        _FilterChip(
          label: 'In-store',
          selected: value == OfferChannel.inStore,
          onTap: () => onChanged(OfferChannel.inStore),
        ),
      ],
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onToggle});

  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    const categories = <String>[
      'fashion',
      'shoes',
      'beauty',
      'electronics',
      'home',
      'grocery',
      'fitness',
    ];

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: [
        for (final c in categories)
          _FilterChip(
            label: _capitalize(c),
            selected: selected.contains(c),
            onTap: () => onToggle(c),
          ),
      ],
    );
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s.substring(0, 1).toUpperCase() + s.substring(1);
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected
              ? cs.primary.withValues(alpha: 0.10)
              : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: selected
                ? cs.primary.withValues(alpha: 0.5)
                : cs.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: selected
                  ? cs.primary
                  : cs.onSurface.withValues(alpha: 0.78),
            ),
          ),
        ),
      ),
    );
  }
}
