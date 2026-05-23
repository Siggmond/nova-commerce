import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nova_commerce/app/theme/app_shadows.dart';
import 'package:nova_commerce/app/theme/app_tokens.dart';
import 'package:nova_commerce/core/widgets/app_button.dart';
import 'package:nova_commerce/features/search/presentation/collection_viewmodel.dart';
import 'package:nova_commerce/features/search/presentation/search_categories.dart';
import 'package:nova_commerce/features/search/presentation/search_filters.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

class PremiumFilterSheet extends ConsumerStatefulWidget {
  const PremiumFilterSheet.search({super.key})
    : collectionId = null,
      includeCategories = true;

  const PremiumFilterSheet.collection({super.key, required this.collectionId})
    : includeCategories = false;

  final String? collectionId;
  final bool includeCategories;

  @override
  ConsumerState<PremiumFilterSheet> createState() => _PremiumFilterSheetState();
}

class _PremiumFilterSheetState extends ConsumerState<PremiumFilterSheet> {
  late SearchFilters _draft;

  @override
  void initState() {
    super.initState();
    _draft = _readCurrentFilters();
  }

  SearchFilters _readCurrentFilters() {
    final collectionId = widget.collectionId;
    if (collectionId == null) {
      return ref.read(searchFiltersProvider);
    }
    return ref.read(collectionFiltersProvider(collectionId));
  }

  SearchFiltersController _readController() {
    final collectionId = widget.collectionId;
    if (collectionId == null) {
      return ref.read(searchFiltersProvider.notifier);
    }
    return ref.read(collectionFiltersProvider(collectionId).notifier);
  }

  int _activeCount(SearchFilters filters) {
    var count = 0;
    if (filters.sort != SearchSort.recommended) count++;
    if (filters.priceTier != null) count++;
    if (widget.includeCategories && filters.category != 'all') count++;
    return count;
  }

  void _clearDraft() {
    final query = _readCurrentFilters().query;
    setState(() => _draft = SearchFilters(query: query));
  }

  void _apply() {
    final controller = _readController();
    controller.setSort(_draft.sort);
    controller.setPriceTier(_draft.priceTier);
    if (widget.includeCategories) {
      controller.setCategory(_draft.category);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final activeCount = _activeCount(_draft);
    final applyLabel = activeCount == 0
        ? t.searchFiltersApply
        : '${t.searchFiltersApply} ($activeCount)';

    final radius = BorderRadius.vertical(top: Radius.circular(28.r));
    final sectionRadius = BorderRadius.circular(AppRadii.xl);

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.56,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, scrollController) {
        return Material(
          color: cs.surface,
          shape: RoundedRectangleBorder(borderRadius: radius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: AppShadows.lg(),
            ),
            child: Column(
              children: [
                SizedBox(height: 8.h),
                Container(
                  width: 42.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant.withValues(alpha: 0.60),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 2.h, 12.w, 10.h),
                  child: Row(
                    children: [
                      Text(
                        t.searchFiltersTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _clearDraft,
                        child: Text(
                          t.searchFiltersClearAll,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 14.h),
                    children: [
                      _FilterSurface(
                        title: t.searchFiltersSortByTitle,
                        radius: sectionRadius,
                        child: SegmentedButton<SearchSort>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment<SearchSort>(
                              value: SearchSort.recommended,
                              label: Text(t.searchFiltersSortRecommended),
                            ),
                            ButtonSegment<SearchSort>(
                              value: SearchSort.popular,
                              label: Text(t.searchFiltersSortPopular),
                            ),
                            ButtonSegment<SearchSort>(
                              value: SearchSort.rating,
                              label: Text(t.searchFiltersSortRating),
                            ),
                          ],
                          selected: {_draft.sort},
                          style: _segmentedStyle(context),
                          onSelectionChanged: (next) {
                            if (next.isEmpty) return;
                            setState(
                              () => _draft = _draft.copyWith(sort: next.first),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _FilterSurface(
                        title: t.searchFiltersPriceTierTitle,
                        radius: sectionRadius,
                        child: SegmentedButton<SearchPriceTier>(
                          showSelectedIcon: false,
                          emptySelectionAllowed: true,
                          segments: [
                            ButtonSegment<SearchPriceTier>(
                              value: SearchPriceTier.lowest,
                              label: Text(t.searchFiltersPriceTierLowest),
                            ),
                            ButtonSegment<SearchPriceTier>(
                              value: SearchPriceTier.midRange,
                              label: Text(t.searchFiltersPriceTierMid),
                            ),
                            ButtonSegment<SearchPriceTier>(
                              value: SearchPriceTier.highEnd,
                              label: Text(t.searchFiltersPriceTierHigh),
                            ),
                          ],
                          selected: _draft.priceTier == null
                              ? <SearchPriceTier>{}
                              : {_draft.priceTier!},
                          style: _segmentedStyle(context),
                          onSelectionChanged: (next) {
                            setState(
                              () => _draft = _draft.copyWith(
                                priceTier: next.isEmpty ? null : next.first,
                              ),
                            );
                          },
                        ),
                      ),
                      if (widget.includeCategories) ...[
                        SizedBox(height: 12.h),
                        _FilterSurface(
                          title: t.searchFiltersCategoriesTitle,
                          radius: sectionRadius,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              final columns = width < 420 ? 2 : 3;
                              final spacing = 10.w;
                              final itemWidth =
                                  (width - (columns - 1) * spacing) / columns;

                              return Wrap(
                                spacing: spacing,
                                runSpacing: 10.h,
                                children: [
                                  for (final categoryId in searchCategoryIds)
                                    _CategoryTile(
                                      width: itemWidth,
                                      icon: _categoryIcon(categoryId),
                                      label: _categoryLabel(t, categoryId),
                                      selected: _draft.category == categoryId,
                                      onTap: () {
                                        setState(
                                          () => _draft = _draft.copyWith(
                                            category: categoryId,
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 14.h),
                    child: SizedBox(
                      width: double.infinity,
                      child: AppButton.primary(
                        label: applyLabel,
                        onPressed: _apply,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterSurface extends StatelessWidget {
  const _FilterSurface({
    required this.title,
    required this.radius,
    required this.child,
  });

  final String title;
  final BorderRadius radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: radius,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10.h),
            child,
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.width,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = selected ? cs.primary : cs.onSurface.withValues(alpha: 0.82);
    final bg = selected
        ? cs.primary.withValues(alpha: 0.12)
        : cs.surfaceContainerHigh;

    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Ink(
            padding: EdgeInsets.fromLTRB(8.w, 10.h, 8.w, 10.h),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(
                color: selected
                    ? cs.primary.withValues(alpha: 0.45)
                    : cs.outlineVariant.withValues(alpha: 0.30),
              ),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: 58.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18.r, color: fg),
                  SizedBox(height: 6.h),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

ButtonStyle _segmentedStyle(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  return ButtonStyle(
    visualDensity: VisualDensity.standard,
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 10.w, vertical: 11.h),
    ),
    side: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return BorderSide(color: cs.primary.withValues(alpha: 0.45));
      }
      return BorderSide(color: cs.outlineVariant.withValues(alpha: 0.30));
    }),
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return cs.primary.withValues(alpha: 0.12);
      }
      return cs.surfaceContainerHigh;
    }),
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return cs.primary;
      return cs.onSurface.withValues(alpha: 0.82);
    }),
    textStyle: WidgetStatePropertyAll(
      Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
    ),
  );
}

IconData _categoryIcon(String id) {
  return switch (id.toLowerCase()) {
    'all' => Icons.apps_rounded,
    'groceries' => Icons.local_grocery_store_rounded,
    'restaurants' => Icons.restaurant_rounded,
    'pharmacy' => Icons.local_pharmacy_rounded,
    'coffee' => Icons.local_cafe_rounded,
    'bakery' => Icons.cake_rounded,
    'electronics' => Icons.devices_rounded,
    'flowers' => Icons.local_florist_rounded,
    'pet' => Icons.pets_rounded,
    'cosmetics' => Icons.face_retouching_natural_rounded,
    'snacks' => Icons.fastfood_rounded,
    'drinks' => Icons.local_drink_rounded,
    'baby' => Icons.child_care_rounded,
    _ => Icons.category_rounded,
  };
}

String _categoryLabel(AppLocalizations t, String categoryId) {
  switch (categoryId.toLowerCase()) {
    case 'all':
      return t.cartFilterAll;
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
