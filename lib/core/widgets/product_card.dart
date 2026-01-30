import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_cached_network_image.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.trailing,
    this.isSaved,
    this.onToggleSaved,
    this.fillHeight = false,
    this.imageWidth,
    this.forceShowTitle = false,
    this.disableCompact = false,
    this.tightTitlePrice = false,
  });

  final Product product;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool? isSaved;
  final VoidCallback? onToggleSaved;
  final bool fillHeight;
  final double? imageWidth;
  final bool forceShowTitle;
  final bool disableCompact;
  final bool tightTitlePrice;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cs = Theme.of(context).colorScheme;
        final radius = BorderRadius.circular(16.r);
        final dpr = ScreenUtil().pixelRatio ?? 1.0;

        final defaultCardHeight = 184.h;
        final effectiveCardHeight = fillHeight
            ? (constraints.hasBoundedHeight
                ? constraints.maxHeight
                : defaultCardHeight)
            : defaultCardHeight;

        final effectiveImageHeight = fillHeight
            ? (effectiveCardHeight * 0.55)
            : (effectiveCardHeight * 0.54);

        final effectiveImageWidth = imageWidth ?? constraints.maxWidth;

        final memCacheWidth = effectiveImageWidth.isFinite
            ? (effectiveImageWidth * dpr).round()
            : null;

        final memCacheHeight = (effectiveImageHeight.isFinite &&
                effectiveImageHeight > 0)
            ? (effectiveImageHeight * dpr).round()
            : null;

        Widget imageStack() {
          return Stack(
            children: [
              Positioned.fill(
                child: Hero(
                  tag: 'product-${product.id}',
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: radius.topLeft),
                    child: AppCachedNetworkImage(
                      url: product.imageUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: memCacheWidth,
                      memCacheHeight: memCacheHeight,
                      backgroundColor: cs.surfaceContainerHigh,
                    ),
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
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.08),
                      ],
                    ),
                  ),
                ),
              ),
              if (trailing != null)
                Positioned(
                  top: 6.h,
                  right: 6.w,
                  child: _PillOverlay(child: trailing!),
                )
              else if (isSaved != null && onToggleSaved != null)
                Positioned(
                  top: 6.h,
                  right: 6.w,
                  child: _WishlistHeart(
                    isSaved: isSaved!,
                    onPressed: onToggleSaved!,
                  ),
                ),
            ],
          );
        }

        Widget detailsBody() {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isCompact =
                  !disableCompact && constraints.maxWidth < 180;

              final isVeryTight = constraints.maxHeight < 52 || constraints.maxWidth < 80;

              if (isVeryTight) {
                final titleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                    );
                final priceStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    );

                return Padding(
                  padding: EdgeInsets.all(2.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: titleStyle,
                      ),
                      SizedBox(height: 1.h),
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

              final titleStyle = Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  );

              final brandStyle = Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: cs.onSurface.withValues(alpha: 0.55),
                  );

              final priceChip = Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${product.currency} ${product.price.toStringAsFixed(0)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              );

              return Padding(
                padding: EdgeInsets.all(8.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: brandStyle,
                    ),
                    SizedBox(height: 4.h),
                    Expanded(
                      child: Text(
                        product.title,
                        maxLines: isCompact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: titleStyle,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Flexible(child: priceChip),
                        if (!isCompact) ...[
                          SizedBox(width: 6.w),
                          Flexible(child: _NewDropBadge()),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }

        final cardChild = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: fillHeight
              ? [
                  Expanded(flex: 11, child: imageStack()),
                  Expanded(flex: 9, child: detailsBody()),
                ]
              : [
                  SizedBox(
                    height: effectiveImageHeight,
                    width: double.infinity,
                    child: imageStack(),
                  ),
                  Expanded(child: detailsBody()),
                ],
        );

        return RepaintBoundary(
          child: _ScaleOnTap(
            child: InkWell(
              borderRadius: radius,
              onTap: onTap,
              child: Card(
                elevation: 1.5,
                shadowColor: Colors.black.withValues(alpha: 0.08),
                surfaceTintColor: cs.surface,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: radius),
                child: fillHeight
                    ? SizedBox.expand(child: cardChild)
                    : SizedBox(
                        height: defaultCardHeight,
                        child: cardChild,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NewDropBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'New',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.primary,
            ),
      ),
    );
  }
}

class _PillOverlay extends StatelessWidget {
  const _PillOverlay({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 12.r,
            offset: Offset(0, 6.h),
            color: Colors.black.withValues(alpha: 0.12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _WishlistHeart extends StatelessWidget {
  const _WishlistHeart({
    required this.isSaved,
    required this.onPressed,
  });

  final bool isSaved;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return _PillOverlay(
      child: IconButton(
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(
          width: 40.r,
          height: 40.r,
        ),
        onPressed: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            key: ValueKey(isSaved),
            isSaved ? Icons.favorite : Icons.favorite_border,
            color:
                isSaved ? cs.primary : cs.onSurface.withValues(alpha: 0.78),
            size: 16.r,
          ),
        ),
      ),
    );
  }
}

class _ScaleOnTap extends StatefulWidget {
  const _ScaleOnTap({required this.child});
  final Widget child;

  @override
  State<_ScaleOnTap> createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<_ScaleOnTap> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Listener(
        onPointerDown: (_) => setState(() => pressed = true),
        onPointerUp: (_) => setState(() => pressed = false),
        onPointerCancel: (_) => setState(() => pressed = false),
        child: widget.child,
      ),
    );
  }
}
