import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_tokens.dart';

class CategoryTile extends StatefulWidget {
  const CategoryTile({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.badgeText,
    this.onTap,
  }) : isSeeAll = false;

  const CategoryTile.seeAll({super.key, this.onTap})
    : title = 'See all',
      subtitle = null,
      badgeText = null,
      icon = Icons.arrow_forward_rounded,
      isSeeAll = true;

  final String title;
  final String? subtitle;
  final String? badgeText;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isSeeAll;

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppRadii.xl);

    final baseTint = widget.isSeeAll
        ? cs.primary.withValues(alpha: 0.08)
        : cs.surfaceContainerHigh.withValues(alpha: 0.70);

    final gradA = widget.isSeeAll
        ? cs.primary.withValues(alpha: 0.16)
        : cs.primary.withValues(alpha: 0.10);

    final gradB = widget.isSeeAll
        ? cs.secondary.withValues(alpha: 0.10)
        : cs.secondary.withValues(alpha: 0.06);

    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: AppShadows.shadowColor.withValues(alpha: 0.18),
              blurRadius: 40,
              offset: const Offset(0, 18),
            ),
            BoxShadow(
              color: AppShadows.shadowColor.withValues(alpha: 0.10),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Material(
            color: baseTint,
            child: InkWell(
              onTap: widget.onTap,
              onTapDown: (_) => setState(() => _pressed = true),
              onTapCancel: () => setState(() => _pressed = false),
              onTapUp: (_) => setState(() => _pressed = false),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [gradA, gradB],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _IconCapsule(
                        icon: widget.icon,
                        isSeeAll: widget.isSeeAll,
                      ),
                      SizedBox(height: 8.h),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                  if (widget.badgeText != null &&
                                      widget.badgeText!.trim().isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(left: 8.w),
                                      child: _Badge(text: widget.badgeText!),
                                    ),
                                ],
                              ),
                              if (widget.subtitle != null &&
                                  widget.subtitle!.trim().isNotEmpty) ...[
                                SizedBox(height: 2.h),
                                Text(
                                  widget.subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: cs.onSurface.withValues(
                                          alpha: 0.70,
                                        ),
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconCapsule extends StatelessWidget {
  const _IconCapsule({required this.icon, required this.isSeeAll});

  final IconData icon;
  final bool isSeeAll;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = isSeeAll
        ? cs.primary.withValues(alpha: 0.16)
        : cs.surface.withValues(alpha: 0.70);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: AppShadows.sm(),
      ),
      child: SizedBox(
        width: 44.r,
        height: 44.r,
        child: Center(
          child: Icon(
            icon,
            size: 26.r,
            color: cs.primary.withValues(alpha: 0.95),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.primary.withValues(alpha: 0.95),
          ),
        ),
      ),
    );
  }
}
