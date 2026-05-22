import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/app_cached_network_image.dart';

class RewardDetailsScreen extends StatelessWidget {
  const RewardDetailsScreen({super.key, required this.rewardId});

  final String rewardId;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  tooltip: t.goldClose,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => context.pop(),
                ),
                title: Text(t.goldRewardDetailsTitle),
              ),
              SliverPadding(
                padding: AppInsets.screen,
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadii.xl),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.55),
                          ),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: AppCachedNetworkImage(
                            url: '',
                            fit: BoxFit.cover,
                            backgroundColor: cs.surfaceContainerHigh,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        t.goldRewardDetailsPlaceholderTitle,
                        style: tt.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.35,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        t.goldRewardDetailsPlaceholderSubtitle,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            border: Border.all(
                              color: cs.outlineVariant.withValues(alpha: 0.55),
                            ),
                          ),
                          child: Text(
                            t.goldRewardPointsChip(0),
                            style: tt.labelLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppRadii.xl),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.55),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(14.r),
                          child: Text(
                            t.goldRewardTermsPlaceholder,
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.78),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 110.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: AppInsets.screen,
                child: SizedBox(
                  width: double.infinity,
                  height: AppHitTargets.min,
                  child: FilledButton(
                    onPressed: null,
                    child: Text(t.goldClaimRewardCta),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
