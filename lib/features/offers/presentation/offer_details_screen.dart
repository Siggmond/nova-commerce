import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_cached_network_image.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../domain/entities/offer.dart';
import 'offer_image_fallback.dart';
import 'offers_viewmodel.dart';

class OfferDetailsScreen extends ConsumerWidget {
  const OfferDetailsScreen({super.key, required this.offerId});

  final String offerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final offerAsync = ref.watch(offerByIdProvider(offerId));

    return Scaffold(
      appBar: AppBar(title: Text(t.offerDetailsTitle)),
      body: offerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorState(
          title: t.offerLoadErrorTitle,
          subtitle: e.toString(),
          actionText: t.commonRetry,
          onAction: () => ref.invalidate(offerByIdProvider(offerId)),
        ),
        data: (offer) {
          if (offer == null) {
            return AppEmptyState(
              title: t.offerNotFoundTitle,
              subtitle: '',
              icon: Icons.local_offer_outlined,
            );
          }

          final cs = Theme.of(context).colorScheme;

          final expiresIn = offer.endAt.difference(DateTime.now());
          final expiresText = expiresIn.isNegative
              ? t.offerExpiresExpired
              : (expiresIn.inDays >= 1
                    ? t.offerExpiresEndsInDays(expiresIn.inDays)
                    : (expiresIn.inHours >= 1
                          ? t.offerExpiresEndsInHours(expiresIn.inHours)
                          : t.offerExpiresEndsSoon));

          Future<void> openTerms() async {
            final url = offer.termsUrl;
            if (url == null || url.trim().isEmpty) return;
            final uri = Uri.tryParse(url);
            if (uri == null) return;
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }

          Future<void> copyCode() async {
            final code = offer.promoCode;
            if (code == null || code.trim().isEmpty) return;
            await Clipboard.setData(ClipboardData(text: code));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text(t.offerPromoCodeCopied),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(milliseconds: 1200),
                ),
              );
          }

          void shopProducts() {
            final q = offer.brandName.trim().isNotEmpty
                ? offer.brandName.trim()
                : offer.title;
            context.push('${AppRoutes.search}?q=${Uri.encodeComponent(q)}');
          }

          return ListView(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.22),
                  ),
                ),
                clipBehavior: Clip.hardEdge,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: AppCachedNetworkImage(
                    url: offer.imageUrl,
                    fallbackUrl: offerFallbackImagePath(offer),
                    fit: BoxFit.cover,
                    backgroundColor: cs.surfaceContainerHigh,
                  ),
                ),
              ),
              SizedBox(height: AppSpace.lg),
              Text(
                offer.brandName,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                  color: cs.onSurface.withValues(alpha: 0.65),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                offer.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                  height: 1.12,
                ),
              ),
              SizedBox(height: AppSpace.xs),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 18.r,
                    color: cs.onSurface.withValues(alpha: 0.58),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      expiresText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpace.md),
              Text(
                offer.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.82),
                  height: 1.25,
                ),
              ),
              SizedBox(height: AppSpace.md),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  for (final channel in offer.channels)
                    _OfferInfoChip(label: _channelLabel(t, channel)),
                  if (offer.promoCode != null)
                    _OfferInfoChip(label: t.offersPillCode),
                  if (offer.isFeatured)
                    _OfferInfoChip(label: t.offersPillFeatured),
                ],
              ),
              SizedBox(height: AppSpace.md),
              if (offer.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    for (final tag in offer.tags.take(8))
                      _OfferInfoChip(label: tag, subdued: true),
                  ],
                ),
                SizedBox(height: AppSpace.md),
              ],
              Card(
                elevation: 0,
                color: cs.surface,
                shadowColor: AppShadows.shadowColor.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  side: BorderSide(
                    color: cs.outlineVariant.withValues(alpha: 0.26),
                  ),
                ),
                child: Padding(
                  padding: AppInsets.card,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            t.offerRedeemTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const Spacer(),
                          if (offer.termsUrl != null)
                            TextButton(
                              onPressed: openTerms,
                              child: Text(
                                t.offerTerms,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: cs.primary,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      if (offer.promoCode != null) ...[
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                            border: Border.all(
                              color: cs.outlineVariant.withValues(alpha: 0.24),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(12.w, 10.h, 8.w, 10.h),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    offer.promoCode!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0,
                                        ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: t.offerCopyCodeTooltip,
                                  onPressed: copyCode,
                                  icon: const Icon(Icons.copy_rounded),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          t.offerUseCodeAtCheckout,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ] else ...[
                        Text(
                          t.offerNoPromoCodeRequired,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.75),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        child: AppButton.primary(
                          label: t.offerShopProductsInThisOffer,
                          onPressed: shopProducts,
                          icon: Icons.search_rounded,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        expiresText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.62),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpace.lg),
            ],
          );
        },
      ),
    );
  }
}

class _OfferInfoChip extends StatelessWidget {
  const _OfferInfoChip({required this.label, this.subdued = false});

  final String label;
  final bool subdued;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: subdued
            ? cs.surfaceContainerLow
            : cs.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: subdued
              ? cs.outlineVariant.withValues(alpha: 0.24)
              : cs.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: subdued ? cs.onSurface.withValues(alpha: 0.74) : cs.primary,
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
