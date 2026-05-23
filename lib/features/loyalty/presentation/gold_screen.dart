import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_tokens.dart';
import '../gold_controller.dart';
import 'reward_offer_card.dart';

class GoldScreen extends ConsumerWidget {
  const GoldScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = Theme.of(context).colorScheme;
    final gold = ref.watch(goldBalanceProvider);
    final points = gold.valueOrNull ?? 0;

    final ordersCompletedThisMonth = 0;
    final monthlyTargetOrders = 0;

    final rewards =
        const <
          ({
            String id,
            String title,
            String pointsLabel,
            String imageUrl,
            String? badge,
          })
        >[];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(t.goldTitle),
            actions: [
              IconButton(
                tooltip: t.goldInfoTooltip,
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    builder: (context) {
                      return Padding(
                        padding: AppInsets.screen,
                        child: Text(
                          t.goldTierRulesPlaceholder,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.info_outline_rounded),
              ),
              SizedBox(width: 6.w),
            ],
          ),
          SliverPadding(
            padding: AppInsets.screen,
            sliver: SliverToBoxAdapter(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.primary.withValues(alpha: 0.16),
                      cs.surface,
                      cs.surfaceContainerHigh.withValues(alpha: 0.74),
                    ],
                  ),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.26),
                  ),
                  boxShadow: AppShadows.md(
                    color: cs.shadow.withValues(alpha: 0.08),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        t.goldRetentionMessage(
                          (monthlyTargetOrders - ordersCompletedThisMonth)
                              .clamp(0, 999999),
                          t.goldRetentionMonthPlaceholder,
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.78),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Center(
                        child: SizedBox(
                          width: 148.r,
                          height: 148.r,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 148.r,
                                height: 148.r,
                                child: CircularProgressIndicator(
                                  value: monthlyTargetOrders <= 0
                                      ? 0
                                      : (ordersCompletedThisMonth /
                                                monthlyTargetOrders)
                                            .clamp(0.0, 1.0),
                                  strokeWidth: 10,
                                  strokeCap: StrokeCap.round,
                                  backgroundColor: cs.onSurface.withValues(
                                    alpha: 0.08,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  gold.when(
                                    data: (_) => Text(
                                      '$points',
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0,
                                          ),
                                    ),
                                    loading: () => SizedBox(
                                      width: 22.r,
                                      height: 22.r,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: cs.primary,
                                      ),
                                    ),
                                    error: (_, __) => Text(
                                      '—',
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0,
                                          ),
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    t.goldPointsLabel,
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          color: cs.onSurface.withValues(
                                            alpha: 0.70,
                                          ),
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Center(
                        child: TextButton(
                          onPressed: () =>
                              context.push(AppRoutes.goldPointsHistory),
                          child: Text(t.goldPointsHistoryCta),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              t.goldOrdersCompletedLabel(
                                ordersCompletedThisMonth,
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            t.goldOrdersOutOfLabel(monthlyTargetOrders),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.75),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
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
                        Icons.info_outline_rounded,
                        size: 20.r,
                        color: cs.primary,
                      ),
                      SizedBox(width: AppSpace.sm),
                      Expanded(
                        child: Text(
                          t.goldNoticeSimplifiedPoints,
                          style: theme.textTheme.bodyMedium?.copyWith(
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
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 10.h),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t.goldDiscountsAndOffersTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                ],
              ),
            ),
          ),
          if (rewards.isEmpty) ...[
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
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
                          Icons.card_giftcard_outlined,
                          size: 20.r,
                          color: cs.onSurface.withValues(alpha: 0.58),
                        ),
                        SizedBox(width: AppSpace.sm),
                        Expanded(
                          child: Text(
                            t.goldRewardsUnavailableBody,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.75),
                              fontWeight: FontWeight.w700,
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
          ] else ...[
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 18.h),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 0.78,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final r = rewards[index];
                  return RewardOfferCard(
                    title: r.title,
                    pointsLabel: r.pointsLabel,
                    imageUrl: r.imageUrl,
                    badgeLabel: r.badge,
                    onTap: () =>
                        context.push('${AppRoutes.goldRewardDetails}/${r.id}'),
                  );
                }, childCount: rewards.length),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
