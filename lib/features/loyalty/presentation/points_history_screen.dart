import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:nova_commerce/gen_l10n/app_localizations.dart';

import '../../../app/theme/app_tokens.dart';

class PointsHistoryScreen extends ConsumerWidget {
  const PointsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(pinned: true, title: Text(t.goldPointsHistoryTitle)),
          SliverPadding(
            padding: AppInsets.screen,
            sliver: SliverToBoxAdapter(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.26),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(14.r),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 20.r,
                        color: cs.onSurface.withValues(alpha: 0.58),
                      ),
                      SizedBox(width: AppSpace.sm),
                      Expanded(
                        child: Text(
                          t.goldPointsHistoryUnavailableBody,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface.withValues(alpha: 0.78),
                                height: 1.28,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 18.h)),
        ],
      ),
    );
  }
}
