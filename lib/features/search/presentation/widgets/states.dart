import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nova_commerce/app/theme/app_tokens.dart';
import 'package:nova_commerce/core/widgets/app_button.dart';
import 'package:nova_commerce/core/widgets/shimmer.dart';

enum SearchSkeletonVariant { row, grid }

class SearchSkeletonCard extends StatelessWidget {
  const SearchSkeletonCard({super.key, required this.variant, this.height});

  final SearchSkeletonVariant variant;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppRadii.xl);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: radius,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Shimmer(
        child: switch (variant) {
          SearchSkeletonVariant.row => SizedBox(
            height: height ?? 104.h,
            child: Padding(
              padding: AppInsets.cardTight,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14.r),
                    child: SkeletonBox(height: 72.r, radius: 14.r),
                  ),
                  SizedBox(width: 12.w),
                  const Expanded(child: _SkeletonTextBlock(compact: true)),
                ],
              ),
            ),
          ),
          SearchSkeletonVariant.grid => SizedBox(
            height: height ?? 252.h,
            child: Padding(
              padding: AppInsets.cardTight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(height: 136.h, radius: 16.r),
                  SizedBox(height: 12.h),
                  const _SkeletonTextBlock(compact: false),
                  SizedBox(height: 8.h),
                  SkeletonBox(height: 16.h, radius: 8.r),
                ],
              ),
            ),
          ),
        },
      ),
    );
  }
}

class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.suggestions = const <String>[
      'Try fewer words',
      'Check spelling',
      'Adjust your filters',
    ],
  });

  final String title;
  final String subtitle;
  final List<String> suggestions;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82.r,
              height: 82.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.surfaceContainerHigh,
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 38.r,
                color: cs.outline,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.66),
              ),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              alignment: WrapAlignment.center,
              children: [
                for (final tip in suggestions)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.26),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      child: Text(
                        tip,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface.withValues(alpha: 0.78),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SearchErrorState extends StatelessWidget {
  const SearchErrorState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onRetry,
    this.retryLabel = 'Retry',
  });

  final String title;
  final String subtitle;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 44.r, color: cs.outline),
            SizedBox(height: 10.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 5.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.66),
              ),
            ),
            SizedBox(height: 14.h),
            AppButton.primary(label: retryLabel, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

class _SkeletonTextBlock extends StatelessWidget {
  const _SkeletonTextBlock({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SkeletonBox(height: compact ? 14.h : 16.h, radius: 8.r),
        SizedBox(height: 8.h),
        SizedBox(
          width: compact ? 120.w : 140.w,
          child: SkeletonBox(height: 12.h, radius: 8.r),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: compact ? 84.w : 90.w,
          child: SkeletonBox(height: 16.h, radius: 8.r),
        ),
      ],
    );
  }
}
