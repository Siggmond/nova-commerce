import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_tokens.dart';
import '../search_categories.dart';
import '../search_filters.dart';

class FilterSectionSurface extends StatelessWidget {
  const FilterSectionSurface({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppRadii.xl);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: radius,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.25)),
        boxShadow: AppShadows.sm(),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 10.h),
            child,
          ],
        ),
      ),
    );
  }
}

class SortBySection extends StatelessWidget {
  const SortBySection({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final SearchSort value;
  final ValueChanged<SearchSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return FilterSectionSurface(
      title: 'Sort by',
      child: Column(
        children: [
          _RadioRow(
            label: 'Recommended',
            selected: value == SearchSort.recommended,
            onTap: () => onChanged(SearchSort.recommended),
          ),
          _RadioRow(
            label: 'Popular',
            selected: value == SearchSort.popular,
            onTap: () => onChanged(SearchSort.popular),
          ),
          _RadioRow(
            label: 'Rating',
            selected: value == SearchSort.rating,
            onTap: () => onChanged(SearchSort.rating),
          ),
        ],
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  const _RadioRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpace.xs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected
                      ? cs.primary
                      : cs.onSurface.withValues(alpha: 0.55),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
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

class PriceTierSection extends StatelessWidget {
  const PriceTierSection({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final SearchPriceTier? value;
  final ValueChanged<SearchPriceTier?> onChanged;

  @override
  Widget build(BuildContext context) {
    return FilterSectionSurface(
      title: 'Price tier',
      child: Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: [
          _TierChip(
            label: 'Lowest price',
            selected: value == SearchPriceTier.lowest,
            onTap: () => onChanged(
              value == SearchPriceTier.lowest ? null : SearchPriceTier.lowest,
            ),
          ),
          _TierChip(
            label: 'Mid range',
            selected: value == SearchPriceTier.midRange,
            onTap: () => onChanged(
              value == SearchPriceTier.midRange
                  ? null
                  : SearchPriceTier.midRange,
            ),
          ),
          _TierChip(
            label: 'High end',
            selected: value == SearchPriceTier.highEnd,
            onTap: () => onChanged(
              value == SearchPriceTier.highEnd ? null : SearchPriceTier.highEnd,
            ),
          ),
        ],
      ),
    );
  }
}

class _TierChip extends StatelessWidget {
  const _TierChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final radius = BorderRadius.circular(AppRadii.pill);
    final borderColor = selected
        ? cs.primary
        : cs.outlineVariant.withValues(alpha: 0.50);

    final textColor = selected
        ? cs.primary
        : cs.onSurface.withValues(alpha: 0.78);

    final fill = selected
        ? cs.primary.withValues(alpha: 0.10)
        : cs.surfaceContainerHigh;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: radius,
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: AppShadows.sm(),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FilterSectionSurface(
      title: 'Categories',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width < 420 ? 2 : (width < 720 ? 3 : 4);
          final itemWidth = (width - (columns - 1) * 10.w) / columns;

          final out = <Widget>[];
          for (final name in searchCategoryNames) {
            final selected = value == name;
            final borderColor = selected
                ? cs.primary
                : cs.outlineVariant.withValues(alpha: 0.50);
            final textColor = selected
                ? cs.primary
                : cs.onSurface.withValues(alpha: 0.82);

            final fill = selected
                ? cs.primary.withValues(alpha: 0.10)
                : cs.surfaceContainerHigh;

            out.add(
              SizedBox(
                width: itemWidth,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onChanged(name),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    child: Ink(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 11.h,
                      ),
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        border: Border.all(color: borderColor, width: 1.2),
                        boxShadow: AppShadows.sm(),
                      ),
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return Wrap(spacing: 10.w, runSpacing: 10.h, children: out);
        },
      ),
    );
  }
}
