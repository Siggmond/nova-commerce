import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nova_commerce/core/domain/entities/product.dart';
import 'package:nova_commerce/features/wishlist/wishlist.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

import 'search_result_card.dart';
import 'states.dart';

class SearchResultsView extends StatelessWidget {
  const SearchResultsView({
    super.key,
    required this.results,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
    required this.errorTitle,
    required this.errorSubtitle,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.itemKeyPrefix,
  });

  final List<Product> results;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onRetry;
  final String errorTitle;
  final String errorSubtitle;
  final String emptyTitle;
  final String emptySubtitle;
  final String itemKeyPrefix;

  static const double _breakpointCompactList = 430;
  static const double _rowCardExtent = 112;
  static const double _rowCardGap = 10;
  static const double _gridCardExtent = 264;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    if (isLoading) {
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.crossAxisExtent;
            if (width < _breakpointCompactList) {
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: _rowCardGap.h),
                      child: SearchSkeletonCard(
                        variant: SearchSkeletonVariant.row,
                        height: _rowCardExtent.h,
                      ),
                    );
                  },
                  childCount: 6,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: false,
                ),
              );
            }

            final crossAxisCount = width < 760 ? 2 : 3;
            const spacing = 10.0;
            return SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                mainAxisExtent: _gridCardExtent.h,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return SearchSkeletonCard(
                    variant: SearchSkeletonVariant.grid,
                    height: _gridCardExtent.h,
                  );
                },
                childCount: crossAxisCount * 3,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
              ),
            );
          },
        ),
      );
    }

    if (hasError) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: SearchErrorState(
          title: errorTitle,
          subtitle: errorSubtitle,
          onRetry: onRetry,
          retryLabel: t.commonRetry,
        ),
      );
    }

    if (results.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: SearchEmptyState(title: emptyTitle, subtitle: emptySubtitle),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.crossAxisExtent;

          if (width < _breakpointCompactList) {
            return SliverFixedExtentList(
              itemExtent: (_rowCardExtent + _rowCardGap).h,
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = results[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: _rowCardGap.h),
                    child: Consumer(
                      builder: (context, ref, _) {
                        final isSaved = ref.watch(
                          wishlistIdsProvider.select(
                            (ids) => ids.contains(product.id),
                          ),
                        );
                        return SearchResultCard(
                          key: ValueKey('${itemKeyPrefix}_${product.id}'),
                          product: product,
                          variant: SearchResultCardVariant.row,
                          isSaved: isSaved,
                          onToggleSaved: () => ref
                              .read(wishlistViewModelProvider.notifier)
                              .toggle(product.id),
                        );
                      },
                    ),
                  );
                },
                childCount: results.length,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
              ),
            );
          }

          final crossAxisCount = width < 760 ? 2 : 3;
          const spacing = 10.0;

          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              mainAxisExtent: _gridCardExtent.h,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = results[index];
                return Consumer(
                  builder: (context, ref, _) {
                    final isSaved = ref.watch(
                      wishlistIdsProvider.select(
                        (ids) => ids.contains(product.id),
                      ),
                    );
                    return SearchResultCard(
                      key: ValueKey('${itemKeyPrefix}_${product.id}'),
                      product: product,
                      variant: SearchResultCardVariant.grid,
                      isSaved: isSaved,
                      onToggleSaved: () => ref
                          .read(wishlistViewModelProvider.notifier)
                          .toggle(product.id),
                    );
                  },
                );
              },
              childCount: results.length,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
            ),
          );
        },
      ),
    );
  }
}
