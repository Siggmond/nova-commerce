import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:nova_commerce/app/router/app_routes.dart';
import 'package:nova_commerce/app/theme/app_shadows.dart';
import 'package:nova_commerce/app/theme/app_tokens.dart';
import 'package:nova_commerce/core/domain/entities/product.dart';
import 'package:nova_commerce/core/widgets/app_cached_network_image.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

import 'collections_section.dart';
import 'recent_searches_section.dart';
import 'states.dart';

class DiscoveryView extends StatelessWidget {
  const DiscoveryView({
    super.key,
    required this.popularProducts,
    required this.catalogIsLoading,
    required this.onSelectQuery,
  });

  final List<Product> popularProducts;
  final bool catalogIsLoading;
  final Future<void> Function(String query) onSelectQuery;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final popular = popularProducts.take(8).toList(growable: false);
    const suggestions = <_SmartSuggestion>[
      _SmartSuggestion(
        query: 'Organic groceries',
        iconAsset: 'assets/icons/organic.svg',
      ),
      _SmartSuggestion(
        query: 'Iced coffee deals',
        iconAsset: 'assets/icons/iced-coffee.svg',
      ),
      _SmartSuggestion(
        query: 'Wireless earbuds',
        iconAsset: 'assets/icons/wireless-earbuds.svg',
      ),
      _SmartSuggestion(
        query: 'Baby essentials',
        iconAsset: 'assets/icons/baby-essentials.svg',
      ),
    ];

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 10.h),
            child: Text(
              'Popular right now',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 174.h,
            child: switch ((catalogIsLoading, popular.isEmpty)) {
              (true, true) => ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 0),
                itemBuilder: (context, index) => SizedBox(
                  width: 220.w,
                  child: const SearchSkeletonCard(
                    variant: SearchSkeletonVariant.grid,
                  ),
                ),
                separatorBuilder: (_, __) => SizedBox(width: 10.w),
                itemCount: 4,
              ),
              _ => ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 2.h),
                itemBuilder: (context, index) {
                  return _PopularProductCard(product: popular[index]);
                },
                separatorBuilder: (_, __) => SizedBox(width: 10.w),
                itemCount: popular.length,
              ),
            },
          ),
        ),
        RecentSearchesSection(onSelectQuery: onSelectQuery),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
            child: Text(
              'Smart suggestions',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
            child: Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: [
                for (final suggestion in suggestions)
                  _SmartSuggestionCard(
                    suggestion: suggestion,
                    onTap: () {
                      unawaited(onSelectQuery(suggestion.query));
                    },
                  ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 0),
            child: Text(
              t.searchCollectionsTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const CollectionsSection(),
      ],
    );
  }
}

class _PopularProductCard extends StatefulWidget {
  const _PopularProductCard({required this.product});

  final Product product;

  @override
  State<_PopularProductCard> createState() => _PopularProductCardState();
}

class _PopularProductCardState extends State<_PopularProductCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final radius = BorderRadius.circular(AppRadii.xl);

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: SizedBox(
        width: 220.w,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: () =>
                context.push('${AppRoutes.product}?id=${widget.product.id}'),
            onHighlightChanged: (value) => setState(() => _pressed = value),
            child: Ink(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: radius,
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.24),
                ),
                boxShadow: AppShadows.sm(),
              ),
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
                          url: widget.product.imageUrl,
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
                            Colors.black.withValues(alpha: 0.04),
                            Colors.black.withValues(alpha: 0.24),
                            Colors.black.withValues(alpha: 0.70),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12.w,
                    right: 12.w,
                    bottom: 10.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${widget.product.currency} ${widget.product.price.toStringAsFixed(0)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.90),
                                fontWeight: FontWeight.w800,
                              ),
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

class _SmartSuggestionCard extends StatefulWidget {
  const _SmartSuggestionCard({required this.suggestion, required this.onTap});

  final _SmartSuggestion suggestion;
  final VoidCallback onTap;

  @override
  State<_SmartSuggestionCard> createState() => _SmartSuggestionCardState();
}

class _SmartSuggestionCardState extends State<_SmartSuggestionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = (MediaQuery.sizeOf(context).width - 34.w) / 2;
    final radius = BorderRadius.circular(AppRadii.lg);
    final iconSize = 30.r;

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      child: SizedBox(
        width: width,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: widget.onTap,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            child: Ink(
              padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: LinearGradient(
                  colors: [cs.surfaceContainerLow, cs.surfaceContainerHigh],
                ),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.28),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: SvgPicture.asset(
                      widget.suggestion.iconAsset,
                      fit: BoxFit.contain,
                      colorFilter: ColorFilter.mode(
                        cs.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      widget.suggestion.query,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
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

class _SmartSuggestion {
  const _SmartSuggestion({required this.query, required this.iconAsset});

  final String query;
  final String iconAsset;
}
