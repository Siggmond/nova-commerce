import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nova_commerce/app/theme/app_tokens.dart';
import 'package:nova_commerce/features/search/presentation/search_filters.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

class FilterChipBar extends StatelessWidget {
  const FilterChipBar({
    super.key,
    required this.filters,
    required this.onOpenFilters,
    required this.onClearSort,
    required this.onClearPriceTier,
    this.onClearCategory,
    this.onClearAll,
    this.includeCategory = true,
  });

  final SearchFilters filters;
  final VoidCallback onOpenFilters;
  final VoidCallback onClearSort;
  final VoidCallback onClearPriceTier;
  final VoidCallback? onClearCategory;
  final VoidCallback? onClearAll;
  final bool includeCategory;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final chips = <_ActiveFilterChipData>[];

    if (filters.sort != SearchSort.recommended) {
      chips.add(
        _ActiveFilterChipData(
          label: _sortLabel(t, filters.sort),
          onRemove: onClearSort,
        ),
      );
    }
    if (filters.priceTier != null) {
      chips.add(
        _ActiveFilterChipData(
          label: _priceTierLabel(t, filters.priceTier!),
          onRemove: onClearPriceTier,
        ),
      );
    }
    if (includeCategory &&
        filters.category != 'all' &&
        onClearCategory != null) {
      chips.add(
        _ActiveFilterChipData(
          label: _categoryLabel(t, filters.category),
          onRemove: onClearCategory!,
        ),
      );
    }

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 54.h,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 2.h),
          children: [
            _PrimaryFilterChip(onTap: onOpenFilters),
            if (chips.isEmpty) ...[
              SizedBox(width: 8.w),
              _NeutralChip(label: t.searchFiltersTitle),
            ] else ...[
              for (final chip in chips) ...[
                SizedBox(width: 8.w),
                _ActiveFilterChip(label: chip.label, onRemove: chip.onRemove),
              ],
            ],
            if (chips.length > 1 && onClearAll != null) ...[
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: onClearAll,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  child: Text(
                    t.searchFiltersClearAll,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PrimaryFilterChip extends StatelessWidget {
  const _PrimaryFilterChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: cs.primary.withValues(alpha: 0.32)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune_rounded, size: 16.r, color: cs.primary),
              SizedBox(width: 6.w),
              Text(
                t.searchTooltipFilters,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: Ink(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(width: 6.w),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close_rounded,
                size: 16.r,
                color: cs.onSurface.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeutralChip extends StatelessWidget {
  const _NeutralChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.65),
          ),
        ),
      ),
    );
  }
}

class _ActiveFilterChipData {
  const _ActiveFilterChipData({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;
}

String _sortLabel(AppLocalizations t, SearchSort value) {
  return switch (value) {
    SearchSort.recommended => t.searchFiltersSortRecommended,
    SearchSort.popular => t.searchFiltersSortPopular,
    SearchSort.rating => t.searchFiltersSortRating,
  };
}

String _priceTierLabel(AppLocalizations t, SearchPriceTier value) {
  return switch (value) {
    SearchPriceTier.lowest => t.searchFiltersPriceTierLowest,
    SearchPriceTier.midRange => t.searchFiltersPriceTierMid,
    SearchPriceTier.highEnd => t.searchFiltersPriceTierHigh,
  };
}

String _categoryLabel(AppLocalizations t, String categoryId) {
  switch (categoryId.toLowerCase()) {
    case 'groceries':
      return t.homeCategoryGroceries;
    case 'restaurants':
      return t.homeCategoryRestaurants;
    case 'pharmacy':
      return t.homeCategoryPharmacy;
    case 'coffee':
      return t.homeCategoryCoffee;
    case 'bakery':
      return t.homeCategoryBakery;
    case 'electronics':
      return t.homeCategoryElectronics;
    case 'flowers':
      return t.homeCategoryFlowers;
    case 'pet':
      return t.homeCategoryPetSupplies;
    case 'cosmetics':
      return t.homeCategoryCosmetics;
    case 'snacks':
      return t.homeCategorySnacks;
    case 'drinks':
      return t.homeCategoryDrinks;
    case 'baby':
      return t.homeCategoryBaby;
    default:
      return categoryId;
  }
}
