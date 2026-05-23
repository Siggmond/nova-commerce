import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nova_commerce/app/theme/app_tokens.dart';
import 'package:nova_commerce/features/search/presentation/recent_searches_viewmodel.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

class RecentSearchesSection extends ConsumerWidget {
  const RecentSearchesSection({super.key, required this.onSelectQuery});

  final Future<void> Function(String query) onSelectQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final recent = ref.watch(recentSearchesViewModelProvider);

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.searchRecentSearchesTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                if (recent.isNotEmpty)
                  TextButton(
                    onPressed: () => ref
                        .read(recentSearchesViewModelProvider.notifier)
                        .clear(),
                    style: TextButton.styleFrom(
                      foregroundColor: cs.primary,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: Size(AppHitTargets.min, AppHitTargets.min),
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                    ),
                    child: Text(
                      t.searchFiltersClearAll,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10.h),
            if (recent.isEmpty)
              _RecentSearchEmptyHint(label: t.searchRecentSearchesEmptyHint)
            else
              Column(
                children: [
                  for (final query in recent)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: _RecentSearchRow(
                        label: query,
                        onTap: () async => onSelectQuery(query),
                        onDelete: () => ref
                            .read(recentSearchesViewModelProvider.notifier)
                            .remove(query),
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

class _RecentSearchEmptyHint extends StatelessWidget {
  const _RecentSearchEmptyHint({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
        child: Row(
          children: [
            Icon(
              Icons.history_rounded,
              size: 18.r,
              color: cs.onSurface.withValues(alpha: 0.56),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.68),
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentSearchRow extends StatelessWidget {
  const _RecentSearchRow({
    required this.label,
    required this.onTap,
    required this.onDelete,
  });

  final String label;
  final Future<void> Function() onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.fromLTRB(14.w, 4.h, 4.w, 4.h),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.24),
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: AppHitTargets.min),
            child: Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 18.r,
                  color: cs.onSurface.withValues(alpha: 0.62),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface.withValues(alpha: 0.88),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  tooltip: MaterialLocalizations.of(
                    context,
                  ).deleteButtonTooltip,
                  constraints: BoxConstraints.tightFor(
                    width: AppHitTargets.min,
                    height: AppHitTargets.min,
                  ),
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18.r,
                    color: cs.onSurface.withValues(alpha: 0.62),
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
