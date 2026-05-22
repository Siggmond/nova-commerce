import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/widgets/app_cached_network_image.dart';

class CategoryTile extends StatefulWidget {
  const CategoryTile({
    super.key,
    required this.title,
    required this.icon,
    this.backgroundAsset,
    this.subtitle,
    this.badgeText,
    this.imageUrl,
    this.onTap,
    this.reduceEffects = false,
  }) : isSeeAll = false;

  const CategoryTile.seeAll({
    super.key,
    required this.title,
    this.onTap,
    this.reduceEffects = false,
  }) : subtitle = null,
       badgeText = null,
       imageUrl = null,
       backgroundAsset = 'assets/icons/see-all.svg',
       icon = Icons.arrow_forward_rounded,
       isSeeAll = true;

  final String title;
  final String? subtitle;
  final String? badgeText;
  final String? imageUrl;
  final String? backgroundAsset;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isSeeAll;
  final bool reduceEffects;

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final radius = BorderRadius.circular(AppRadii.xl);
    final hasImage =
        !widget.isSeeAll &&
        widget.imageUrl != null &&
        widget.imageUrl!.trim().isNotEmpty;
    final hasSvgBackground =
        !hasImage &&
        widget.backgroundAsset != null &&
        widget.backgroundAsset!.trim().isNotEmpty;
    final hasArtwork = hasImage || hasSvgBackground;

    return RepaintBoundary(
      child: AnimatedScale(
        scale: widget.reduceEffects ? 1 : (_pressed ? 0.98 : 1),
        duration: widget.reduceEffects
            ? Duration.zero
            : const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: widget.reduceEffects
                ? const <BoxShadow>[]
                : (hasArtwork
                      ? AppShadows.md(
                          color: Colors.black.withValues(alpha: 0.20),
                        )
                      : AppShadows.sm()),
          ),
          child: Material(
            color: cs.surfaceContainerHigh,
            borderRadius: radius,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: radius,
              onTapDown: widget.reduceEffects
                  ? null
                  : (_) => setState(() => _pressed = true),
              onTapCancel: widget.reduceEffects
                  ? null
                  : () => setState(() => _pressed = false),
              onTapUp: widget.reduceEffects
                  ? null
                  : (_) => setState(() => _pressed = false),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final dpr = MediaQuery.devicePixelRatioOf(context);
                  final w =
                      constraints.hasBoundedWidth &&
                          constraints.maxWidth.isFinite
                      ? constraints.maxWidth
                      : 170.w;
                  final h = constraints.maxHeight.isFinite
                      ? constraints.maxHeight
                      : 156.h;
                  final tight = h <= 140;
                  final pad = tight ? 10.r : 12.r;
                  final iconSize = tight ? 42.r : 48.r;
                  final memCacheWidth = (w * dpr).round();
                  final memCacheHeight = (h * dpr).round();
                  final titleStyle = tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.10,
                    color: hasArtwork ? Colors.white : cs.onSurface,
                  );
                  final subtitleStyle = tt.labelMedium?.copyWith(
                    color: hasArtwork
                        ? Colors.white.withValues(alpha: 0.84)
                        : cs.onSurface.withValues(alpha: 0.74),
                    fontWeight: FontWeight.w600,
                  );
                  final hasBadge =
                      widget.badgeText != null &&
                      widget.badgeText!.trim().isNotEmpty;

                  final baseTint = widget.isSeeAll
                      ? cs.primary.withValues(alpha: 0.10)
                      : cs.surfaceContainerHigh.withValues(alpha: 0.78);

                  final gradA = widget.isSeeAll
                      ? cs.primary.withValues(alpha: 0.22)
                      : cs.primary.withValues(alpha: 0.12);

                  final gradB = widget.isSeeAll
                      ? cs.secondary.withValues(alpha: 0.14)
                      : cs.secondary.withValues(alpha: 0.08);

                  final content = Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: hasImage
                            ? AppCachedNetworkImage(
                                url: widget.imageUrl!,
                                fit: BoxFit.cover,
                                borderRadius: radius,
                                backgroundColor: cs.surfaceContainerHigh,
                                memCacheWidth: memCacheWidth,
                                memCacheHeight: memCacheHeight,
                              )
                            : hasSvgBackground
                            ? DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: radius,
                                  color: cs.surfaceContainerHigh,
                                ),
                                child: ClipRRect(
                                  borderRadius: radius,
                                  child: SvgPicture.asset(
                                    widget.backgroundAsset!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: radius,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [baseTint, baseTint],
                                  ),
                                ),
                              ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: radius,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: hasArtwork
                                  ? [
                                      Colors.black.withValues(alpha: 0.12),
                                      Colors.black.withValues(alpha: 0.26),
                                      Colors.black.withValues(alpha: 0.68),
                                    ]
                                  : [gradA, gradB],
                              stops: hasArtwork
                                  ? const [0.0, 0.54, 1.0]
                                  : const [0.0, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(pad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _IconCapsule(
                                  icon: widget.icon,
                                  isSeeAll: widget.isSeeAll,
                                  onImage: hasArtwork,
                                  size: iconSize,
                                  reduceEffects: widget.reduceEffects,
                                ),
                                if (hasBadge) ...[
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Align(
                                      alignment: AlignmentDirectional.topEnd,
                                      child: _Badge(
                                        text: widget.badgeText!,
                                        onImage: hasArtwork,
                                      ),
                                    ),
                                  ),
                                ] else
                                  const Spacer(),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              widget.title,
                              maxLines: tight ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                              style: titleStyle,
                            ),
                            if (widget.subtitle != null &&
                                widget.subtitle!.trim().isNotEmpty) ...[
                              SizedBox(height: 4.h),
                              Text(
                                widget.subtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: subtitleStyle,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );

                  if (!constraints.hasBoundedHeight ||
                      !constraints.maxHeight.isFinite) {
                    return SizedBox(height: 156.h, child: content);
                  }

                  return content;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconCapsule extends StatelessWidget {
  const _IconCapsule({
    required this.icon,
    required this.isSeeAll,
    required this.onImage,
    required this.reduceEffects,
    this.size,
  });

  final IconData icon;
  final bool isSeeAll;
  final bool onImage;
  final bool reduceEffects;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = onImage
        ? Colors.black.withValues(alpha: 0.34)
        : isSeeAll
        ? cs.primary.withValues(alpha: 0.22)
        : cs.surface.withValues(alpha: 0.76);
    final iconColor = onImage
        ? Colors.white
        : cs.primary.withValues(alpha: 0.95);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: onImage
              ? Colors.white.withValues(alpha: 0.30)
              : cs.outlineVariant.withValues(alpha: 0.24),
        ),
        boxShadow: reduceEffects ? const <BoxShadow>[] : AppShadows.sm(),
      ),
      child: SizedBox(
        width: size ?? 44.r,
        height: size ?? 44.r,
        child: Center(
          child: Icon(
            icon,
            size: (size != null) ? (size! * 0.60) : 26.r,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.onImage});

  final String text;
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: onImage
            ? Colors.black.withValues(alpha: 0.46)
            : cs.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: onImage
              ? Colors.white.withValues(alpha: 0.26)
              : Colors.transparent,
        ),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 24.h),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: onImage
                    ? Colors.white
                    : cs.primary.withValues(alpha: 0.95),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
