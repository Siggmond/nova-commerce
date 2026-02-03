import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_shadows.dart';
import '../../../../core/widgets/app_button.dart';
import '../search_filters.dart';
import 'search_filter_sections.dart';

class SearchFilterSheet extends ConsumerStatefulWidget {
  const SearchFilterSheet({super.key});

  @override
  ConsumerState<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends ConsumerState<SearchFilterSheet> {
  late SearchFilters _draft;

  @override
  void initState() {
    super.initState();
    _draft = ref.read(searchFiltersProvider);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final primary = cs.primary;
    final radius = BorderRadius.vertical(top: Radius.circular(22.r));

    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.52,
      maxChildSize: 0.92,
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
                    color: cs.outlineVariant.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 10.w, 8.h),
                  child: Row(
                    children: [
                      Text(
                        'Filters',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          final currentQuery = ref
                              .read(searchFiltersProvider)
                              .query;
                          setState(
                            () => _draft = SearchFilters(query: currentQuery),
                          );
                        },
                        child: Text(
                          'Clear all',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: primary,
                                fontWeight: FontWeight.w700,
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
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
                    children: [
                      SortBySection(
                        value: _draft.sort,
                        onChanged: (next) => setState(
                          () => _draft = _draft.copyWith(sort: next),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      PriceTierSection(
                        value: _draft.priceTier,
                        onChanged: (next) => setState(
                          () => _draft = _draft.copyWith(priceTier: next),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      CategoriesSection(
                        value: _draft.category,
                        onChanged: (next) => setState(
                          () => _draft = _draft.copyWith(category: next),
                        ),
                      ),
                      SizedBox(height: 18.h),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
                    child: SizedBox(
                      width: double.infinity,
                      child: AppButton.primary(
                        label: 'Apply',
                        onPressed: () {
                          final controller = ref.read(
                            searchFiltersProvider.notifier,
                          );
                          controller.setSort(_draft.sort);
                          controller.setPriceTier(_draft.priceTier);
                          controller.setCategory(_draft.category);
                          Navigator.of(context).pop();
                        },
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
