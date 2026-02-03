import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_cached_network_image.dart';
import '../../../../domain/entities/offer.dart';

enum OfferCardVariant { row, grid }

class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.offer,
    required this.onTap,
    this.variant = OfferCardVariant.row,
  });

  final Offer offer;
  final VoidCallback onTap;
  final OfferCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(AppRadii.lg);

    final expiresIn = offer.endAt.difference(DateTime.now());
    final expiresText = expiresIn.isNegative
        ? 'Expired'
        : (expiresIn.inDays >= 1
              ? 'Ends in ${expiresIn.inDays}d'
              : (expiresIn.inHours >= 1
                    ? 'Ends in ${expiresIn.inHours}h'
                    : 'Ends soon'));

    String badgeText() {
      return switch (offer.discountType) {
        OfferDiscountType.percent =>
          '${offer.discountValue.toStringAsFixed(0)}% OFF',
        OfferDiscountType.amount =>
          '\$${offer.discountValue.toStringAsFixed(0)} OFF',
        OfferDiscountType.bogo => 'BOGO',
        OfferDiscountType.other => 'DEAL',
      };
    }

    final imageWidth = (variant == OfferCardVariant.row ? 120.0 : 132.0).w;
    final imageHeight = (variant == OfferCardVariant.row ? 104.0 : 112.0).h;

    return InkWell(
      borderRadius: radius,
      onTap: onTap,
      child: Card(
        elevation: AppElevation.card,
        shadowColor: AppShadows.shadowColor.withValues(alpha: 0.12),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: radius),
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                child: SizedBox(
                  width: imageWidth,
                  height: imageHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AppCachedNetworkImage(
                          url: offer.imageUrl,
                          fit: BoxFit.cover,
                          backgroundColor: cs.surfaceContainerHigh,
                        ),
                      ),
                      Positioned(
                        top: 8.h,
                        left: 8.w,
                        child: _Badge(text: badgeText()),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.35,
                        height: 1.05,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      offer.brandName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            expiresText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.65),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        if (offer.promoCode != null) _Pill(text: 'Code'),
                        if (offer.isFeatured) ...[
                          SizedBox(width: 6.w),
                          _Pill(text: 'Featured'),
                        ],
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                          border: Border.all(
                            color: cs.primary.withValues(alpha: 0.22),
                          ),
                          boxShadow: AppShadows.sm(),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          child: Text(
                            'View deal',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.15,
                                  color: cs.primary,
                                ),
                          ),
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
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: AppShadows.sm(),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
            color: cs.onSurface,
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: cs.primary.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.primary,
          ),
        ),
      ),
    );
  }
}
