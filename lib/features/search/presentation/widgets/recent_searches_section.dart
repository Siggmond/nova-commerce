import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_tokens.dart';
import '../recent_searches_viewmodel.dart';

class RecentSearchesSection extends ConsumerWidget {
  const RecentSearchesSection({super.key, required this.onSelectQuery});

  final Future<void> Function(String query) onSelectQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final recent = ref.watch(recentSearchesViewModelProvider);

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderRow(
              hasItems: recent.isNotEmpty,
              onClear: () =>
                  ref.read(recentSearchesViewModelProvider.notifier).clear(),
            ),
            SizedBox(height: AppSpace.xxs),
            if (recent.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: AppSpace.xxs),
                child: Text(
                  'Search for products to see them here.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: [
                  for (final q in recent)
                    RecentSearchChip(
                      key: ValueKey('recent_$q'),
                      label: q,
                      onTap: () => onSelectQuery(q),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.hasItems, required this.onClear});

  final bool hasItems;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent searches',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
        if (hasItems)
          TextButton(
            onPressed: onClear,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: cs.primary,
            ),
            child: Text(
              'Clear',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          const SizedBox(width: 0, height: 0),
      ],
    );
  }
}

class RecentSearchChip extends StatelessWidget {
  const RecentSearchChip({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final radius = BorderRadius.circular(AppRadii.pill);
    final bg = cs.surfaceContainerHigh;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            boxShadow: AppShadows.sm(),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_rounded,
                size: 14.r,
                color: cs.onSurface.withValues(alpha: 0.62),
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface.withValues(alpha: 0.86),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
