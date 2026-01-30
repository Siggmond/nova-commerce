import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product.dart';
import '../theme/app_tokens.dart';
import 'app_cached_network_image.dart';

class ProductTileCompact extends StatelessWidget {
  const ProductTileCompact({
    super.key,
    required this.product,
    required this.onTap,
    this.isSaved,
    this.onToggleSaved,
  });

  final Product product;
  final VoidCallback onTap;
  final bool? isSaved;
  final VoidCallback? onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppRadii.md);
    final dpr = ScreenUtil().pixelRatio ?? 1.0;

    final titleStrut = const StrutStyle(forceStrutHeight: true, height: 1.15);

    return InkWell(
      borderRadius: radius,
      onTap: onTap,
      child: Card(
        elevation: AppElevation.low,
        shadowColor: Colors.transparent,
        clipBehavior: Clip.none,
        shape: RoundedRectangleBorder(borderRadius: radius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 7,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadii.md),
                  topRight: Radius.circular(AppRadii.md),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final w = constraints.maxWidth;
                          final h = constraints.maxHeight;
                          final memCacheWidth = (w * dpr).round();
                          final memCacheHeight = (h * dpr).round();
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
                    if (isSaved != null && onToggleSaved != null)
                      Positioned(
                        top: AppSpace.xs,
                        right: AppSpace.xs,
                        child: _CompactWishlistHeart(
                          isSaved: isSaved!,
                          onPressed: onToggleSaved!,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: AppInsets.cardTight.copyWith(
                  bottom: AppInsets.cardTight.bottom + AppSpace.xxs,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.brand.trim().isNotEmpty) ...[
                      Text(
                        product.brand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        strutStyle: titleStrut,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                              color: cs.onSurface.withValues(alpha: 0.65),
                            ),
                      ),
                      SizedBox(height: AppSpace.xxs),
                    ],
                    Expanded(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          strutStyle: titleStrut,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                              ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpace.xs),
                    Text(
                      '${product.currency} ${product.price.toStringAsFixed(0)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      strutStyle: const StrutStyle(
                        forceStrutHeight: true,
                        height: 1.1,
                      ),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactWishlistHeart extends StatelessWidget {
  const _CompactWishlistHeart({required this.isSaved, required this.onPressed});

  final bool isSaved;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: IconButton(
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(width: 38.r, height: 38.r),
        onPressed: onPressed,
        icon: Icon(
          isSaved ? Icons.favorite : Icons.favorite_border,
          color: isSaved ? cs.primary : cs.onSurface.withValues(alpha: 0.78),
          size: 20.r,
        ),
      ),
    );
  }
}
