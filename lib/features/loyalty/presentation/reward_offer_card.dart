import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/app_cached_network_image.dart';

class RewardOfferCard extends StatelessWidget {
  const RewardOfferCard({
    super.key,
    required this.title,
    required this.pointsLabel,
    required this.imageUrl,
    this.badgeLabel,
    this.onTap,
  });

  final String title;
  final String pointsLabel;
  final String imageUrl;
  final String? badgeLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    final radius = BorderRadius.circular(AppRadii.xl);

    return RepaintBoundary(
      child: Material(
        color: cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.55)),
        ),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: AppShadows.sm(),
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppCachedNetworkImage(
                          url: imageUrl,
                          fit: BoxFit.cover,
                          backgroundColor: cs.surfaceContainerHigh,
                        ),
                        Positioned(
                          left: 10.w,
                          top: 10.h,
                          child:
                              badgeLabel == null || badgeLabel!.trim().isEmpty
                              ? const SizedBox.shrink()
                              : Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.pill,
                                    ),
                                  ),
                                  child: Text(
                                    badgeLabel!,
                                    style: tt.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            border: Border.all(
                              color: cs.outlineVariant.withValues(alpha: 0.55),
                            ),
                          ),
                          child: Text(
                            pointsLabel,
                            style: tt.labelMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
