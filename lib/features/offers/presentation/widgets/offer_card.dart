import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/widgets/app_cached_network_image.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';
import 'package:nova_commerce/features/offers/domain/entities/offer.dart';
import '../offer_image_fallback.dart';

enum OfferCardVariant { row, grid }

class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.offer,
    required this.onTap,
    this.variant = OfferCardVariant.row,
    this.reduceEffects = false,
  });

  final Offer offer;
  final VoidCallback onTap;
  final OfferCardVariant variant;
  final bool reduceEffects;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final radius = BorderRadius.circular(AppRadii.xl);

    final expiresIn = offer.endAt.difference(DateTime.now());
    final expiresText = expiresIn.isNegative
        ? t.offerExpiresExpired
        : (expiresIn.inDays >= 1
              ? t.offerExpiresEndsInDays(expiresIn.inDays)
              : (expiresIn.inHours >= 1
                    ? t.offerExpiresEndsInHours(expiresIn.inHours)
                    : t.offerExpiresEndsSoon));

    String badgeText() {
      final locale = Localizations.localeOf(context).toLanguageTag();
      final numFmt = NumberFormat.decimalPattern(locale);
      return switch (offer.discountType) {
        OfferDiscountType.percent => t.offersBadgePercentOff(
          numFmt.format(offer.discountValue.round()),
        ),
        OfferDiscountType.amount => t.offersBadgeAmountOff(
          numFmt.format(offer.discountValue.round()),
        ),
        OfferDiscountType.bogo => t.offersBadgeBogo,
        OfferDiscountType.other => t.offersBadgeDeal,
      };
    }

    final isRow = variant == OfferCardVariant.row;
    final imageWidth = (isRow ? 116.0 : 132.0).w;
    final imageHeight = (isRow ? 108.0 : 112.0).h;

    final memCacheWidth = (imageWidth * dpr).round();
    final memCacheHeight = (imageHeight * dpr).round();

    return RepaintBoundary(
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Card(
          elevation: 0,
          color: cs.surface,
          shadowColor: AppShadows.shadowColor.withValues(alpha: 0.06),
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.24)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: imageWidth,
                  height: imageHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: AppCachedNetworkImage(
                            url: offer.imageUrl,
                            fallbackUrl: offerFallbackImagePath(offer),
                            fit: BoxFit.cover,
                            memCacheWidth: memCacheWidth,
                            memCacheHeight: memCacheHeight,
                            backgroundColor: cs.surfaceContainerHigh,
                          ),
                        ),
                        Positioned(
                          top: 8.h,
                          left: 8.w,
                          child: _Badge(
                            text: badgeText(),
                            reduceEffects: reduceEffects,
                          ),
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              offer.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                                height: 1.08,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        offer.brandName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.72),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 7.h),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 15.r,
                            color: cs.onSurface.withValues(alpha: 0.56),
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              expiresText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.66),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 6.h,
                        children: [
                          for (final channel in offer.channels.take(2))
                            _Pill(text: _channelLabel(t, channel)),
                          if (offer.promoCode != null)
                            _Pill(text: t.offersPillCode),
                          if (offer.isFeatured)
                            _Pill(text: t.offersPillFeatured),
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
                              color: cs.primary.withValues(alpha: 0.20),
                            ),
                            boxShadow: reduceEffects
                                ? const <BoxShadow>[]
                                : AppShadows.sm(),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                            child: Text(
                              t.offersViewDealCta,
                              style: tt.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
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
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.reduceEffects});

  final String text;
  final bool reduceEffects;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: reduceEffects ? const <BoxShadow>[] : AppShadows.sm(),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        child: Text(
          text,
          style: tt.labelSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

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
          style: tt.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.primary,
          ),
        ),
      ),
    );
  }
}

String _channelLabel(AppLocalizations t, OfferChannel channel) {
  return switch (channel) {
    OfferChannel.online => t.offersChannelOnline,
    OfferChannel.inStore => t.offersChannelInStore,
    OfferChannel.other => t.offersChannelAll,
  };
}
