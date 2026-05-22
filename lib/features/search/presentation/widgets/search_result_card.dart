import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nova_commerce/app/router/app_routes.dart';
import 'package:nova_commerce/app/theme/app_shadows.dart';
import 'package:nova_commerce/app/theme/app_tokens.dart';
import 'package:nova_commerce/core/domain/entities/product.dart';
import 'package:nova_commerce/core/widgets/app_cached_network_image.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

enum SearchResultCardVariant { row, grid }

class SearchResultCard extends StatefulWidget {
  const SearchResultCard({
    super.key,
    required this.product,
    required this.variant,
    required this.isSaved,
    required this.onToggleSaved,
  });

  final Product product;
  final SearchResultCardVariant variant;
  final bool isSaved;
  final VoidCallback onToggleSaved;

  @override
  State<SearchResultCard> createState() => _SearchResultCardState();
}

class _SearchResultCardState extends State<SearchResultCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppRadii.xl);

    return AnimatedScale(
      scale: _pressed ? 0.986 : 1,
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOutCubic,
      child: RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: radius,
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.28),
            ),
            boxShadow: AppShadows.sm(),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: radius,
              onTap: () =>
                  context.push('${AppRoutes.product}?id=${widget.product.id}'),
              onHighlightChanged: (value) => setState(() => _pressed = value),
              child: switch (widget.variant) {
                SearchResultCardVariant.row => _SearchResultRowBody(
                  product: widget.product,
                  isSaved: widget.isSaved,
                  onToggleSaved: widget.onToggleSaved,
                ),
                SearchResultCardVariant.grid => _SearchResultGridBody(
                  product: widget.product,
                  isSaved: widget.isSaved,
                  onToggleSaved: widget.onToggleSaved,
                ),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchResultRowBody extends StatelessWidget {
  const _SearchResultRowBody({
    required this.product,
    required this.isSaved,
    required this.onToggleSaved,
  });

  final Product product;
  final bool isSaved;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final rating = _stableRating(product.id);
    final imageExtent = 82.r;
    final memCacheExtent = (imageExtent * dpr).round();

    return Padding(
      padding: AppInsets.cardTight,
      child: Row(
        children: [
          Stack(
            children: [
              SizedBox(
                width: imageExtent,
                height: imageExtent,
                child: AppCachedNetworkImage(
                  url: product.imageUrl,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(16.r),
                  memCacheWidth: memCacheExtent,
                  memCacheHeight: memCacheExtent,
                  backgroundColor: cs.surfaceContainerHigh,
                ),
              ),
              Positioned(
                left: 6.w,
                top: 6.h,
                child: _RatingBadge(rating: rating),
              ),
            ],
          ),
          SizedBox(width: 12.w),
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
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                if (product.brand.trim().isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    product.brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.60),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                SizedBox(height: 8.h),
                Text(
                  '${product.currency} ${product.price.toStringAsFixed(0)}',
                  style: tt.titleSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.15,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          _WishlistFab(isSaved: isSaved, onPressed: onToggleSaved),
        ],
      ),
    );
  }
}

class _SearchResultGridBody extends StatelessWidget {
  const _SearchResultGridBody({
    required this.product,
    required this.isSaved,
    required this.onToggleSaved,
  });

  final Product product;
  final bool isSaved;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final rating = _stableRating(product.title);

    return Padding(
      padding: AppInsets.cardTight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 142.h,
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
                        borderRadius: BorderRadius.circular(16.r),
                        memCacheWidth: memCacheWidth,
                        memCacheHeight: memCacheHeight,
                        backgroundColor: cs.surfaceContainerHigh,
                      );
                    },
                  ),
                ),
                Positioned(
                  left: 8.w,
                  top: 8.h,
                  child: _RatingBadge(rating: rating),
                ),
                Positioned(
                  right: 8.w,
                  top: 8.h,
                  child: _WishlistFab(
                    isSaved: isSaved,
                    onPressed: onToggleSaved,
                    compact: true,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            product.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          if (product.brand.trim().isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              product.brand,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.labelSmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.60),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const Spacer(),
          Text(
            '${product.currency} ${product.price.toStringAsFixed(0)}',
            style: tt.titleSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, size: 14.r, color: Colors.amber.shade700),
            SizedBox(width: 4.w),
            Text(
              rating.toStringAsFixed(1),
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistFab extends StatelessWidget {
  const _WishlistFab({
    required this.isSaved,
    required this.onPressed,
    this.compact = false,
  });

  final bool isSaved;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final size = compact ? 34.r : 40.r;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.92),
        shape: BoxShape.circle,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.30)),
        boxShadow: AppShadows.sm(),
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: compact ? 18.r : 20.r,
            color: isSaved ? cs.error : cs.onSurface.withValues(alpha: 0.72),
          ),
          padding: EdgeInsets.zero,
          tooltip: isSaved
              ? t.productRemoveFromWishlistTooltip
              : t.productSaveToWishlistTooltip,
        ),
      ),
    );
  }
}

double _stableRating(String source) {
  var hash = 0;
  for (final u in source.codeUnits) {
    hash = (hash * 31 + u) & 0x7fffffff;
  }
  final tenths = 36 + (hash % 15); // 3.6 to 5.0
  return math.min(5.0, tenths / 10.0);
}
