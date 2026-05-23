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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxHeight = constraints.maxHeight.isFinite
                    ? constraints.maxHeight
                    : (height ?? 252.h);
                final compact = maxHeight < 220.h;
                final imageHeight =
                    (maxHeight - 24.r - (compact ? 10.h : 12.h) - 60.h)
                        .clamp(88.h, 142.h)
                        .toDouble();

                return Padding(
                  padding: AppInsets.cardTight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(height: imageHeight, radius: 16.r),
                      SizedBox(height: compact ? 10.h : 12.h),
                      _SkeletonTextBlock(compact: compact),
                    ],
                  ),
                );
              },
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
        padding: AppInsets.state,
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
                  color: cs.outlineVariant.withValues(alpha: 0.28),
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
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 340.w),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.68),
                  height: 1.3,
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              alignment: WrapAlignment.center,
              children: [
                for (final tip in suggestions)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.24),
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
                          color: cs.onSurface.withValues(alpha: 0.80),
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
        padding: AppInsets.state,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                color: cs.errorContainer.withValues(alpha: 0.50),
                shape: BoxShape.circle,
                border: Border.all(color: cs.error.withValues(alpha: 0.20)),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 34.r,
                color: cs.error,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 340.w),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.68),
                  height: 1.3,
                ),
              ),
            ),
            SizedBox(height: 16.h),
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
