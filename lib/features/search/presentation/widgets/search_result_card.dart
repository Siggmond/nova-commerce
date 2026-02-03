import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_routes.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_cached_network_image.dart';
import '../../../../domain/entities/product.dart';

enum SearchResultCardVariant { row, grid }

class SearchResultCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppRadii.xl);

    final border = Border.all(color: cs.outlineVariant.withValues(alpha: 0.32));

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: radius,
          border: border,
          boxShadow: AppShadows.md(),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Material(
            color: cs.surface,
            child: InkWell(
              onTap: () =>
                  context.push('${AppRoutes.product}?id=${product.id}'),
              child: switch (variant) {
                SearchResultCardVariant.row => _SearchResultRowBody(
                  product: product,
                  isSaved: isSaved,
                  onToggleSaved: onToggleSaved,
                ),
                SearchResultCardVariant.grid => _SearchResultGridBody(
                  product: product,
                  isSaved: isSaved,
                  onToggleSaved: onToggleSaved,
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

  static const double _rowCardExtent = 96;

  final Product product;
  final bool isSaved;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w900,
      letterSpacing: -0.2,
    );
    final brandStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
      color: cs.onSurface.withValues(alpha: 0.62),
    );
    final priceStyle = Theme.of(
      context,
    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900);

    final imageRadius = BorderRadius.circular(14.r);

    return SizedBox(
      height: _rowCardExtent.h,
      child: Padding(
        padding: AppInsets.card,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: imageRadius,
              child: SizedBox(
                width: 72.r,
                height: 72.r,
                child: AppCachedNetworkImage(
                  url: product.imageUrl,
                  fit: BoxFit.cover,
                  backgroundColor: cs.surfaceContainerHigh,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 56.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          product.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: titleStyle,
                        ),
                        if (product.brand.trim().isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text(
                            product.brand,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: brandStyle,
                          ),
                        ],
                        SizedBox(height: 6.h),
                        Text(
                          '${product.currency} ${product.price.toStringAsFixed(0)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: priceStyle,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _WishlistIconButton(
                      isSaved: isSaved,
                      onPressed: onToggleSaved,
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

    final titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w900,
      letterSpacing: -0.2,
    );
    final brandStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
      color: cs.onSurface.withValues(alpha: 0.62),
    );
    final priceStyle = Theme.of(
      context,
    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900);

    final imageRadius = BorderRadius.circular(16.r);

    return Padding(
      padding: AppInsets.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 138.h,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: imageRadius,
                    child: AppCachedNetworkImage(
                      url: product.imageUrl,
                      fit: BoxFit.cover,
                      backgroundColor: cs.surfaceContainerHigh,
                    ),
                  ),
                ),
                Positioned(
                  top: 6.h,
                  right: 6.w,
                  child: _WishlistIconButton(
                    isSaved: isSaved,
                    onPressed: onToggleSaved,
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
            style: titleStyle,
          ),
          if (product.brand.trim().isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              product.brand,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: brandStyle,
            ),
          ],
          const Spacer(),
          Text(
            '${product.currency} ${product.price.toStringAsFixed(0)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: priceStyle,
          ),
        ],
      ),
    );
  }
}

class _WishlistIconButton extends StatelessWidget {
  const _WishlistIconButton({required this.isSaved, required this.onPressed});

  final bool isSaved;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final icon = isSaved
        ? Icons.favorite_rounded
        : Icons.favorite_border_rounded;

    final iconColor = isSaved ? cs.error : cs.onSurface.withValues(alpha: 0.72);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.34)),
        boxShadow: AppShadows.sm(),
      ),
      child: SizedBox(
        width: 48,
        height: 48,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: iconColor, size: 20.r),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          splashRadius: 24,
          tooltip: isSaved ? 'Remove from wishlist' : 'Add to wishlist',
        ),
      ),
    );
  }
}
