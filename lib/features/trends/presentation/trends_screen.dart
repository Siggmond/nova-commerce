import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import 'package:nova_commerce/app/di/app_providers.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/app_cached_network_image.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/nova_product_tile.dart';
import '../../../core/domain/entities/product.dart';
import 'package:nova_commerce/features/wishlist/wishlist.dart';

final trendingProductsProvider = FutureProvider((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final page = await repo.getFeaturedProducts(limit: 20);
  return page.items;
});

class TrendsEditorialSliverSection extends ConsumerWidget {
  const TrendsEditorialSliverSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final productsAsync = ref.watch(trendingProductsProvider);
    final cs = Theme.of(context).colorScheme;

    void toggleSaved(String id) {
      ref.read(wishlistViewModelProvider.notifier).toggle(id);
    }

    return productsAsync.when(
      loading: () => SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.34),
              ),
            ),
            child: SizedBox(
              height: 180.h,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          ),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: AppErrorState(
          title: t.homeCuratedTrendsLoadErrorTitle,
          subtitle: e.toString(),
          actionText: t.commonRetry,
          onAction: () => ref.invalidate(trendingProductsProvider),
        ),
      ),
      data: (products) {
        if (products.isEmpty) {
          return SliverToBoxAdapter(
            child: AppEmptyState(
              title: t.homeCuratedTrendsEmptyTitle,
              subtitle: t.homeCuratedTrendsIntroSubtitle,
              icon: Icons.trending_up_outlined,
            ),
          );
        }

        final hero = products.first;
        final favorites = products.skip(1).take(8).toList(growable: false);
        final worthALook = products
            .skip(1 + favorites.length)
            .take(6)
            .toList(growable: false);
        final morePicks = products
            .skip(1 + favorites.length + worthALook.length)
            .take(8)
            .toList(growable: false);

        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                child: Consumer(
                  builder: (context, ref, _) {
                    final isSaved = ref.watch(
                      wishlistIdsProvider.select(
                        (ids) => ids.contains(hero.id),
                      ),
                    );
                    return _EditorialHero(
                      product: hero,
                      isSaved: isSaved,
                      onToggleSaved: () => toggleSaved(hero.id),
                      onTap: () =>
                          context.push('${AppRoutes.product}?id=${hero.id}'),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                child: _EditorialIntroCard(
                  title: t.homeCuratedTrendsIntroTitle,
                  subtitle: t.homeCuratedTrendsIntroSubtitle,
                ),
              ),
            ),
            if (favorites.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 0, 8.h),
                  child: _EditorsFavoritesShowcase(
                    title: t.homeCuratedTrendsEditorsFavoritesTitle,
                    subtitle: t.homeCuratedTrendsEditorsFavoritesSubtitle,
                    badgeLabel: t.homeCuratedTrendsEditorsPickBadge,
                    products: favorites,
                    onTap: (product) =>
                        context.push('${AppRoutes.product}?id=${product.id}'),
                    onToggleSaved: toggleSaved,
                  ),
                ),
              ),
            if (worthALook.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 12.h),
                  child: _SectionHeader(
                    title: t.homeCuratedTrendsWorthALookTitle,
                    subtitle: t.homeCuratedTrendsWorthALookSubtitle,
                  ),
                ),
              ),
            if (worthALook.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _gridCrossAxisCount(context),
                    mainAxisSpacing: AppSpace.md,
                    crossAxisSpacing: AppSpace.md,
                    childAspectRatio: 1.9,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = worthALook[index];
                      return Consumer(
                        builder: (context, ref, _) {
                          final isSaved = ref.watch(
                            wishlistIdsProvider.select(
                              (ids) => ids.contains(product.id),
                            ),
                          );
                          return ProductCard(
                            product: product,
                            onTap: () => context.push(
                              '${AppRoutes.product}?id=${product.id}',
                            ),
                            isSaved: isSaved,
                            onToggleSaved: () => toggleSaved(product.id),
                          );
                        },
                      );
                    },
                    childCount: worthALook.length,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                  ),
                ),
              ),
            if (morePicks.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 12.h),
                  child: _SectionHeader(
                    title: t.homeCuratedTrendsMorePicksTitle,
                    subtitle: t.homeCuratedTrendsMorePicksSubtitle,
                  ),
                ),
              ),
            if (morePicks.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 228.h,
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                    scrollDirection: Axis.horizontal,
                    itemCount: morePicks.length,
                    separatorBuilder: (_, __) => SizedBox(width: AppSpace.md),
                    itemBuilder: (context, index) {
                      final product = morePicks[index];
                      return SizedBox(
                        width: 160.w,
                        child: Consumer(
                          builder: (context, ref, _) {
                            final isSaved = ref.watch(
                              wishlistIdsProvider.select(
                                (ids) => ids.contains(product.id),
                              ),
                            );
                            return NovaProductTile(
                              product: product,
                              onTap: () => context.push(
                                '${AppRoutes.product}?id=${product.id}',
                              ),
                              isSaved: isSaved,
                              onToggleSaved: () => toggleSaved(product.id),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            SliverToBoxAdapter(child: SizedBox(height: 8.h)),
          ],
        );
      },
    );
  }
}

class TrendsScreen extends ConsumerWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.trendsTitle)),
      body: CustomScrollView(slivers: const [TrendsEditorialSliverSection()]),
    );
  }
}

int _gridCrossAxisCount(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w >= 900) return 3;
  return 2;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1.12,
          ),
        ),
        SizedBox(height: AppSpace.xxs),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.72),
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class _EditorialIntroCard extends StatelessWidget {
  const _EditorialIntroCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.34)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
              ),
              child: Icon(
                Icons.trending_up_rounded,
                color: cs.primary,
                size: 20.r,
              ),
            ),
            SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.14,
                    ),
                  ),
                  SizedBox(height: AppSpace.xs),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.3,
                      color: cs.onSurface.withValues(alpha: 0.78),
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

class _EditorsFavoritesShowcase extends StatelessWidget {
  const _EditorsFavoritesShowcase({
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
    required this.products,
    required this.onTap,
    required this.onToggleSaved,
  });

  final String title;
  final String subtitle;
  final String badgeLabel;
  final List<Product> products;
  final ValueChanged<Product> onTap;
  final ValueChanged<String> onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final showcaseBorderColor = cs.outlineVariant.withValues(alpha: 0.56);
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = width >= 1200
        ? 240.0
        : (width >= 900 ? 220.0 : (width >= 600 ? 198.0 : 182.0));

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: showcaseBorderColor),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withValues(alpha: 0.06),
            cs.surfaceContainerHigh,
            cs.surfaceContainerHighest.withValues(alpha: 0.72),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 14.h, 0, 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 34.r,
                  height: 34.r,
                  child: SvgPicture.asset(
                    'assets/icons/editor-favorites.svg',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: AppSpace.xxs),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.74),
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpace.sm),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.surface.withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.52),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    child: Text(
                      badgeLabel,
                      style: tt.labelSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpace.md),
            SizedBox(
              height: 292.h,
              child: ListView.separated(
                clipBehavior: Clip.none,
                padding: EdgeInsetsDirectional.only(end: 12.w),
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, __) => SizedBox(width: 10.w),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Consumer(
                    builder: (context, ref, _) {
                      final isSaved = ref.watch(
                        wishlistIdsProvider.select(
                          (ids) => ids.contains(product.id),
                        ),
                      );
                      return SizedBox(
                        width: cardWidth,
                        child: _EditorsFavoriteCard(
                          rank: index + 1,
                          badgeLabel: badgeLabel,
                          product: product,
                          isSaved: isSaved,
                          onTap: () => onTap(product),
                          onToggleSaved: () => onToggleSaved(product.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorsFavoriteCard extends StatelessWidget {
  const _EditorsFavoriteCard({
    required this.rank,
    required this.badgeLabel,
    required this.product,
    required this.isSaved,
    required this.onTap,
    required this.onToggleSaved,
  });

  final int rank;
  final String badgeLabel;
  final Product product;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final radius = BorderRadius.circular(AppRadii.lg);

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
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
                  aspectRatio: 1.12,
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
                              url: product.imageUrl,
                              fit: BoxFit.cover,
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
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.52, 1.0],
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
                        left: 8,
                        top: 8,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.46),
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.24),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 5.h,
                            ),
                            child: Text(
                              '#$rank',
                              style: tt.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Material(
                          color: Colors.black.withValues(alpha: 0.34),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onToggleSaved,
                            child: SizedBox(
                              width: 34.r,
                              height: 34.r,
                              child: Icon(
                                isSaved
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 18,
                                color: isSaved
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.90),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 148),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: cs.surface.withValues(alpha: 0.86),
                              borderRadius: BorderRadius.circular(
                                AppRadii.pill,
                              ),
                              border: Border.all(
                                color: cs.outlineVariant.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 9.w,
                                vertical: 5.h,
                              ),
                              child: Text(
                                badgeLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tt.labelSmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.brand.trim().isNotEmpty) ...[
                          Text(
                            product.brand,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.58),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
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
                            height: 1.14,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${product.currency} ${product.price.toStringAsFixed(0)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tt.titleSmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: cs.onSurface.withValues(alpha: 0.58),
                            ),
                          ],
                        ),
                      ],
                    ),
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

class _EditorialHero extends StatelessWidget {
  const _EditorialHero({
    required this.product,
    required this.isSaved,
    required this.onToggleSaved,
    required this.onTap,
  });

  final Product product;
  final bool isSaved;
  final VoidCallback onToggleSaved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.xl),
      onTap: onTap,
      child: RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.38),
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: AspectRatio(
            aspectRatio: 16 / 10,
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
                        url: product.imageUrl,
                        fit: BoxFit.cover,
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
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.05),
                          Colors.black.withValues(alpha: 0.18),
                          Colors.black.withValues(alpha: 0.55),
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10.h,
                  left: 10.w,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: cs.surface.withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.42),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      child: Text(
                        t.homeCuratedTrendsEditorsPickBadge,
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: cs.surface.withValues(alpha: 0.86),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.42),
                      ),
                    ),
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints.tightFor(
                        width: AppHitTargets.min,
                        height: AppHitTargets.min,
                      ),
                      onPressed: onToggleSaved,
                      icon: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        color: isSaved
                            ? cs.primary
                            : cs.onSurface.withValues(alpha: 0.78),
                        size: 20.r,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 12.w,
                  right: 12.w,
                  bottom: 12.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.homeCuratedTrendsHeroPickLabel,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: AppSpace.xs),
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                        ),
                      ),
                      SizedBox(height: AppSpace.xs),
                      Text(
                        '${product.currency} ${product.price.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontWeight: FontWeight.w900,
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
    );
  }
}
