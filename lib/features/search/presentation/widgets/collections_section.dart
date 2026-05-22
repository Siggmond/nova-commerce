import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nova_commerce/app/router/app_routes.dart';
import 'package:nova_commerce/app/theme/app_shadows.dart';
import 'package:nova_commerce/app/theme/app_tokens.dart';
import 'package:nova_commerce/core/widgets/app_cached_network_image.dart';
import 'package:nova_commerce/features/search/presentation/collection_catalog.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

class CollectionsSection extends StatefulWidget {
  const CollectionsSection({super.key});

  @override
  State<CollectionsSection> createState() => _CollectionsSectionState();
}

class _CollectionsSectionState extends State<CollectionsSection> {
  static const double _viewportFraction = 0.86;
  static const Duration _autoPlayInterval = Duration(seconds: 7);
  static const Duration _autoPlayDuration = Duration(milliseconds: 360);

  late final PageController _pageController = PageController(
    viewportFraction: _viewportFraction,
  );
  late final ValueNotifier<double> _pageNotifier = ValueNotifier<double>(
    _pageController.initialPage.toDouble(),
  );

  Timer? _autoPlayTimer;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_syncPage);
    if (searchCollections.length > 1) {
      _autoPlayTimer = Timer.periodic(
        _autoPlayInterval,
        (_) => _goToNextPage(),
      );
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController
      ..removeListener(_syncPage)
      ..dispose();
    _pageNotifier.dispose();
    super.dispose();
  }

  void _syncPage() {
    if (!_pageController.hasClients) return;
    final next = _pageController.page ?? _pageController.initialPage.toDouble();
    if ((next - _pageNotifier.value).abs() > 0.0001) {
      _pageNotifier.value = next;
    }
  }

  void _goToNextPage() {
    if (!mounted || _isDragging) return;
    if (!_pageController.hasClients) return;
    if (searchCollections.isEmpty) return;

    final current = (_pageController.page ?? _pageNotifier.value).round();
    final next = (current + 1) % searchCollections.length;
    _pageController.animateToPage(
      next,
      duration: _autoPlayDuration,
      curve: Curves.easeOutCubic,
    );
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _isDragging = true;
    } else if (notification is ScrollEndNotification) {
      _isDragging = false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(0, 10.h, 0, 18.h),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.crossAxisExtent;
          final textScale = MediaQuery.textScalerOf(
            context,
          ).scale(1.0).clamp(1.0, 1.35);

          final baseHeight = (width * 0.52).clamp(188.0, 276.0);
          final cardHeight = (baseHeight + (textScale - 1.0) * 22.0)
              .clamp(baseHeight, baseHeight + 28.0)
              .toDouble();
          final cardWidth = (width * _viewportFraction).clamp(180.0, width);
          final dpr = MediaQuery.devicePixelRatioOf(context);
          final memCacheWidth = (cardWidth * dpr).round();
          final memCacheHeight = (cardHeight * dpr).round();
          final compact = cardHeight < 200;
          final topShadowBleed = 8.h;
          final bottomShadowBleed = 28.h;
          final carouselHeight =
              cardHeight + topShadowBleed + bottomShadowBleed;

          return SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(
                  height: carouselHeight,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _onScrollNotification,
                    child: PageView.builder(
                      controller: _pageController,
                      padEnds: true,
                      clipBehavior: Clip.none,
                      physics: const BouncingScrollPhysics(
                        parent: PageScrollPhysics(),
                      ),
                      itemCount: searchCollections.length,
                      itemBuilder: (context, index) {
                        final collection = searchCollections[index];
                        return AnimatedBuilder(
                          animation: _pageNotifier,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: EdgeInsets.only(top: topShadowBleed),
                                child: SizedBox(
                                  height: cardHeight,
                                  child: _CollectionCard(
                                    key: ValueKey(
                                      'collection_${collection.id}',
                                    ),
                                    title: _titleLabel(t, collection.id),
                                    subtitle: _subtitleLabel(t, collection.id),
                                    backgroundAsset: _collectionBackgroundAsset(
                                      collection.id,
                                    ),
                                    imageUrl: collection.imageUrl,
                                    categoryLabel: _categoryLabel(
                                      t,
                                      collection.categoryId,
                                    ),
                                    onTap: () {
                                      context.push(
                                        '${AppRoutes.searchCollection}/${collection.id}',
                                      );
                                    },
                                    surface: cs.surface,
                                    outline: cs.outlineVariant.withValues(
                                      alpha: 0.26,
                                    ),
                                    memCacheWidth: memCacheWidth,
                                    memCacheHeight: memCacheHeight,
                                    compact: compact,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          builder: (context, child) {
                            final page = _pageNotifier.value;
                            final delta = index - page;
                            final distance = delta
                                .abs()
                                .clamp(0.0, 1.0)
                                .toDouble();
                            final scale = (1 - (distance * 0.08))
                                .clamp(0.92, 1.0)
                                .toDouble();
                            final translateY = (distance * 10.0)
                                .clamp(0.0, 10.0)
                                .toDouble();
                            final translateX = (-delta * 10.0)
                                .clamp(-14.0, 14.0)
                                .toDouble();

                            return Transform.translate(
                              offset: Offset(translateX, translateY),
                              child: Transform.scale(
                                scale: scale,
                                child: child,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                ValueListenableBuilder<double>(
                  valueListenable: _pageNotifier,
                  builder: (context, page, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(searchCollections.length, (
                        index,
                      ) {
                        final absDelta = (page - index)
                            .abs()
                            .clamp(0.0, 1.0)
                            .toDouble();
                        final activeT = 1 - absDelta;
                        final dotWidth = 8.0 + (14.0 * activeT);
                        final dotColor = Color.lerp(
                          cs.outlineVariant.withValues(alpha: 0.42),
                          cs.primary.withValues(alpha: 0.96),
                          activeT,
                        );

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          curve: Curves.easeOut,
                          width: dotWidth.w,
                          height: 6.h,
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            color: dotColor,
                            boxShadow: activeT > 0.6
                                ? AppShadows.sm(
                                    color: cs.primary.withValues(alpha: 0.28),
                                  )
                                : null,
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CollectionCard extends StatefulWidget {
  const _CollectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.backgroundAsset,
    required this.imageUrl,
    required this.categoryLabel,
    required this.onTap,
    required this.surface,
    required this.outline,
    required this.memCacheWidth,
    required this.memCacheHeight,
    required this.compact,
  });

  final String title;
  final String subtitle;
  final String backgroundAsset;
  final String imageUrl;
  final String categoryLabel;
  final VoidCallback onTap;
  final Color surface;
  final Color outline;
  final int memCacheWidth;
  final int memCacheHeight;
  final bool compact;

  @override
  State<_CollectionCard> createState() => _CollectionCardState();
}

class _CollectionCardState extends State<_CollectionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final memCacheWidth = widget.memCacheWidth > 0
        ? widget.memCacheWidth
        : null;
    final memCacheHeight = widget.memCacheHeight > 0
        ? widget.memCacheHeight
        : null;
    final hasBackgroundAsset = widget.backgroundAsset.trim().isNotEmpty;

    final radius = BorderRadius.circular(AppRadii.xl);
    final titleStyle = tt.titleMedium?.copyWith(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      letterSpacing: -0.2,
      height: 1.1,
      shadows: [
        Shadow(
          color: Colors.black.withValues(alpha: 0.55),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
    final subtitleStyle = tt.labelLarge?.copyWith(
      fontSize: 13.sp,
      color: Colors.white.withValues(alpha: 0.9),
      fontWeight: FontWeight.w600,
      height: 1.1,
    );
    final chipTextStyle = tt.labelMedium?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.2,
    );

    return RepaintBoundary(
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            borderRadius: radius,
            child: Container(
              decoration: BoxDecoration(
                color: widget.surface,
                borderRadius: radius,
                border: Border.all(color: widget.outline),
                boxShadow: AppShadows.md(
                  color: cs.shadow.withValues(alpha: 0.20),
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: hasBackgroundAsset
                        ? ClipRRect(
                            borderRadius: radius,
                            child: Image.asset(
                              widget.backgroundAsset,
                              fit: BoxFit.cover,
                            ),
                          )
                        : AppCachedNetworkImage(
                            url: widget.imageUrl,
                            fit: BoxFit.cover,
                            borderRadius: radius,
                            memCacheWidth: memCacheWidth,
                            memCacheHeight: memCacheHeight,
                            backgroundColor: cs.surfaceContainerHigh,
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
                            Colors.black.withValues(alpha: 0.04),
                            Colors.black.withValues(alpha: 0.20),
                            Colors.black.withValues(alpha: 0.70),
                          ],
                          stops: const [0.0, 0.48, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16.w,
                    top: 14.h,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.30),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 5.h,
                        ),
                        child: Text(
                          widget.categoryLabel.trim().isEmpty
                              ? t.searchCollectionsExplore
                              : widget.categoryLabel.trim(),
                          style: chipTextStyle,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16.w,
                    right: 54.w,
                    bottom: 14.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          maxLines: widget.compact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: titleStyle,
                        ),
                        if (widget.subtitle.trim().isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          Text(
                            widget.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: subtitleStyle,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Positioned(
                    right: 16.w,
                    bottom: 14.h,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.30),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.r),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 18.r,
                          color: Colors.white,
                        ),
                      ),
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

String _titleLabel(AppLocalizations t, String id) {
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

String _subtitleLabel(AppLocalizations t, String id) {
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

String _collectionBackgroundAsset(String id) {
  switch (id) {
    case 'editorial_1':
      return 'assets/images/editor-selection.png';
    case 'editorial_2':
      return 'assets/images/weekend-selection.png';
    case 'editorial_3':
      return 'assets/images/clean-tech.png';
    case 'editorial_4':
      return 'assets/images/coffee-corner.png';
    case 'editorial_5':
      return 'assets/images/everyday-treats.png';
    case 'editorial_6':
      return 'assets/images/baby-family.png';
    default:
      return '';
  }
}
