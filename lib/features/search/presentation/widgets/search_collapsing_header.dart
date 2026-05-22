import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nova_commerce/app/theme/app_tokens.dart';

class SearchCollapsingHeader extends StatelessWidget {
  const SearchCollapsingHeader({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.query,
    required this.title,
    required this.hintText,
    required this.searchTooltip,
    required this.filterTooltip,
    required this.onChanged,
    required this.onSubmitted,
    required this.onSearchPressed,
    required this.onClearQuery,
    required this.onFilterPressed,
    this.hasActiveFilters = false,
    this.expandedHeight = 152,
    this.collapsedHeight = 80,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String query;
  final String title;
  final String hintText;
  final String searchTooltip;
  final String filterTooltip;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onSearchPressed;
  final VoidCallback onClearQuery;
  final VoidCallback onFilterPressed;
  final bool hasActiveFilters;
  final double expandedHeight;
  final double collapsedHeight;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SearchCollapsingHeaderDelegate(
        topInset: topInset,
        controller: controller,
        focusNode: focusNode,
        query: query,
        title: title,
        hintText: hintText,
        searchTooltip: searchTooltip,
        filterTooltip: filterTooltip,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onSearchPressed: onSearchPressed,
        onClearQuery: onClearQuery,
        onFilterPressed: onFilterPressed,
        hasActiveFilters: hasActiveFilters,
        expandedHeight: expandedHeight,
        collapsedHeight: collapsedHeight,
      ),
    );
  }
}

class _SearchCollapsingHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SearchCollapsingHeaderDelegate({
    required this.topInset,
    required this.controller,
    required this.focusNode,
    required this.query,
    required this.title,
    required this.hintText,
    required this.searchTooltip,
    required this.filterTooltip,
    required this.onChanged,
    required this.onSubmitted,
    required this.onSearchPressed,
    required this.onClearQuery,
    required this.onFilterPressed,
    required this.hasActiveFilters,
    required this.expandedHeight,
    required this.collapsedHeight,
  });

  final double topInset;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String query;
  final String title;
  final String hintText;
  final String searchTooltip;
  final String filterTooltip;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onSearchPressed;
  final VoidCallback onClearQuery;
  final VoidCallback onFilterPressed;
  final bool hasActiveFilters;
  final double expandedHeight;
  final double collapsedHeight;

  @override
  double get maxExtent => expandedHeight.h + topInset;

  @override
  double get minExtent => collapsedHeight.h + topInset;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final collapseRange = (maxExtent - minExtent).clamp(1.0, double.infinity);
    final t = (shrinkOffset / collapseRange).clamp(0.0, 1.0);

    double lerp(double a, double b) => lerpDouble(a, b, t) ?? b;

    final surfaceAlpha = lerp(0.88, 0.97);
    final shadowAlpha = lerp(0.03, 0.12);
    final shadowBlur = lerp(8, 18);
    final titleOpacity = (1 - Curves.easeOut.transform(t)).clamp(0.0, 1.0);

    final topPadding = lerp(12.h, 6.h);
    final bottomPadding = lerp(12.h, 8.h);
    final titleBottomSpacing = lerp(10.h, 2.h);
    final sidePadding = 12.w;

    final fieldHeight = lerp(52.h, 40.h);
    final fieldRadius = lerp(20.r, 16.r);
    final fieldVerticalPadding = lerp(12.h, 8.h);

    final iconSize = lerp(22.r, 18.r);
    final filterIconSize = lerp(16.r, 13.r);
    final trailingIconSize = lerp(20.r, 18.r);
    final showFilterLabel = t < 0.45;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: surfaceAlpha),
        border: Border(
          bottom: BorderSide(
            color: cs.outlineVariant.withValues(alpha: lerp(0.08, 0.30)),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: shadowAlpha),
            blurRadius: shadowBlur,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          sidePadding,
          topInset + topPadding,
          sidePadding,
          bottomPadding,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (titleOpacity > 0.01)
              ClipRect(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  heightFactor: titleOpacity,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: titleBottomSpacing),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleLarge?.copyWith(
                        color: cs.onSurface.withValues(alpha: titleOpacity),
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.25,
                      ),
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(fieldRadius),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.28),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: lerp(6, 12),
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: fieldHeight,
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: onChanged,
                        onSubmitted: onSubmitted,
                        textInputAction: TextInputAction.search,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: hintText,
                          border: InputBorder.none,
                          isDense: true,
                          prefixIcon: IconButton(
                            tooltip: searchTooltip,
                            onPressed: onSearchPressed,
                            icon: Icon(Icons.search_rounded, size: iconSize),
                          ),
                          prefixIconConstraints: BoxConstraints(
                            minWidth: 44.w,
                            minHeight: fieldHeight,
                          ),
                          contentPadding: EdgeInsets.fromLTRB(
                            8.w,
                            fieldVerticalPadding,
                            8.w,
                            fieldVerticalPadding,
                          ),
                          suffixIconConstraints: const BoxConstraints(
                            minHeight: 0,
                            minWidth: 0,
                          ),
                          suffixIcon: query.trim().isNotEmpty
                              ? IconButton(
                                  tooltip: MaterialLocalizations.of(
                                    context,
                                  ).deleteButtonTooltip,
                                  onPressed: onClearQuery,
                                  icon: Icon(
                                    Icons.close_rounded,
                                    size: trailingIconSize,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                _FilterActionButton(
                  height: fieldHeight,
                  iconSize: filterIconSize,
                  showLabel: showFilterLabel,
                  tooltip: filterTooltip,
                  hasActiveFilters: hasActiveFilters,
                  onPressed: onFilterPressed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchCollapsingHeaderDelegate oldDelegate) {
    return oldDelegate.query != query ||
        oldDelegate.hasActiveFilters != hasActiveFilters ||
        oldDelegate.title != title ||
        oldDelegate.hintText != hintText ||
        oldDelegate.topInset != topInset ||
        oldDelegate.expandedHeight != expandedHeight ||
        oldDelegate.collapsedHeight != collapsedHeight;
  }
}

class _FilterActionButton extends StatelessWidget {
  const _FilterActionButton({
    required this.height,
    required this.iconSize,
    required this.showLabel,
    required this.tooltip,
    required this.hasActiveFilters,
    required this.onPressed,
  });

  final double height;
  final double iconSize;
  final bool showLabel;
  final String tooltip;
  final bool hasActiveFilters;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bgColor = hasActiveFilters
        ? cs.primary.withValues(alpha: 0.14)
        : cs.surfaceContainerLow;
    final fgColor = hasActiveFilters
        ? cs.primary
        : cs.onSurface.withValues(alpha: 0.80);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Ink(
          height: height,
          padding: EdgeInsets.symmetric(
            horizontal: showLabel ? 12.w : 10.w,
            vertical: 0,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.30),
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: iconSize + 6.r,
                  height: iconSize + 6.r,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Icon(Icons.tune_rounded, size: iconSize, color: fgColor),
                      if (hasActiveFilters)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: cs.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: cs.surface, width: 1.2),
                            ),
                            child: SizedBox(width: 8.r, height: 8.r),
                          ),
                        ),
                    ],
                  ),
                ),
                if (showLabel) ...[
                  SizedBox(width: 6.w),
                  Text(
                    tooltip,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: fgColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
