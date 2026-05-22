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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(pinned: true, title: Text(t.goldPointsHistoryTitle)),
          SliverPadding(
            padding: AppInsets.screen,
            sliver: SliverToBoxAdapter(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.55),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(14.r),
                  child: Text(
                    t.goldPointsHistoryUnavailableBody,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
