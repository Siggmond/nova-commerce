import 'package:flutter/material.dart';
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
  });

  final Product product;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool? isSaved;
  final VoidCallback? onToggleSaved;
  final bool fillHeight;
  final double? imageWidth;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(22.r);
    final dpr = ScreenUtil().pixelRatio ?? 1.0;
    final w = imageWidth;
    final memCacheWidth = w == null ? null : (w * dpr).round();
    final memCacheHeight = w == null ? null : ((w * (10 / 16)) * dpr).round();

    final defaultCardHeight = 272.h;
    final imageHeight = 156.h;

    Widget imageStack() {
      return Stack(
        children: [
          Positioned.fill(
            child: AppCachedNetworkImage(
              url: product.imageUrl,
              fit: BoxFit.cover,
              memCacheWidth: memCacheWidth,
              memCacheHeight: memCacheHeight,
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
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.06),
                    Colors.black.withValues(alpha: 0.16),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          if (trailing != null)
            Positioned(
              top: 12.h,
              right: 12.w,
              child: _PillOverlay(child: trailing!),
            )
          else if (isSaved != null && onToggleSaved != null)
            Positioned(
              top: 12.h,
              right: 12.w,
              child: _WishlistHeart(
                isSaved: isSaved!,
                onPressed: onToggleSaved!,
              ),
            ),
        ],
      );
    }

    Widget detailsBody() {
      return Padding(
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.brand.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                letterSpacing: 0.8,
                fontWeight: FontWeight.w800,
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 6.h),
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${product.currency} ${product.price.toStringAsFixed(0)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999.r),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    child: Text(
                      'New drop',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final cardChild = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: fillHeight
          ? [
              Expanded(flex: 10, child: imageStack()),
              Expanded(flex: 8, child: detailsBody()),
            ]
          : [
              SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: imageStack(),
              ),
              Expanded(child: detailsBody()),
            ],
    );

    return RepaintBoundary(
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Card(
          elevation: 3,
          shadowColor: Colors.black.withValues(alpha: 0.14),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: radius),
          child: fillHeight
              ? SizedBox.expand(child: cardChild)
              : SizedBox(height: defaultCardHeight, child: cardChild),
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
        color: cs.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18.r,
            offset: Offset(0, 10.h),
            color: Colors.black.withValues(alpha: 0.18),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _WishlistHeart extends StatefulWidget {
  const _WishlistHeart({required this.isSaved, required this.onPressed});

  final bool isSaved;
  final VoidCallback onPressed;

  @override
  State<_WishlistHeart> createState() => _WishlistHeartState();
}

class _WishlistHeartState extends State<_WishlistHeart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );

  @override
  void didUpdateWidget(covariant _WishlistHeart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isSaved && widget.isSaved) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scale = Tween<double>(
      begin: 1,
      end: 1.18,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    return _PillOverlay(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(scale: scale.value, child: child);
        },
        child: IconButton(
          onPressed: widget.onPressed,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1).animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Icon(
              widget.isSaved ? Icons.favorite : Icons.favorite_border,
              key: ValueKey<bool>(widget.isSaved),
              color: widget.isSaved
                  ? cs.primary
                  : cs.onSurface.withValues(alpha: 0.78),
            ),
          ),
        ),
      ),
    );
  }
}
