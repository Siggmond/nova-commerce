import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_routes.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_cached_network_image.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import 'offers_viewmodel.dart';

class OfferDetailsScreen extends ConsumerWidget {
  const OfferDetailsScreen({super.key, required this.offerId});

  final String offerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerAsync = ref.watch(offerByIdProvider(offerId));

    return Scaffold(
      appBar: AppBar(title: const Text('Offer details')),
      body: offerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorState(
          title: 'Could not load offer',
          subtitle: e.toString(),
          actionText: 'Retry',
          onAction: () => ref.invalidate(offerByIdProvider(offerId)),
        ),
        data: (offer) {
          if (offer == null) {
            return const AppEmptyState(
              title: 'Offer not found',
              subtitle: '',
              icon: Icons.local_offer_outlined,
            );
          }

          final cs = Theme.of(context).colorScheme;

          final expiresIn = offer.endAt.difference(DateTime.now());
          final expiresText = expiresIn.isNegative
              ? 'Expired'
              : (expiresIn.inDays >= 1
                    ? 'Ends in ${expiresIn.inDays}d'
                    : (expiresIn.inHours >= 1
                          ? 'Ends in ${expiresIn.inHours}h'
                          : 'Ends soon'));

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
                  content: const Text('Promo code copied'),
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
            padding: AppInsets.screen,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.xl),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: AppCachedNetworkImage(
                    url: offer.imageUrl,
                    fit: BoxFit.cover,
                    backgroundColor: cs.surfaceContainerHigh,
                  ),
                ),
              ),
              SizedBox(height: AppSpace.md),
              Text(
                offer.brandName.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: cs.onSurface.withValues(alpha: 0.65),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                offer.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: AppSpace.xs),
              Text(
                expiresText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w700,
                ),
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
              if (offer.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    for (final t in offer.tags.take(8))
                      Chip(
                        label: Text(t),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                SizedBox(height: AppSpace.md),
              ],
              Card(
                elevation: AppElevation.card,
                shadowColor: AppShadows.shadowColor.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                ),
                child: Padding(
                  padding: AppInsets.card,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Redeem',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const Spacer(),
                          if (offer.termsUrl != null)
                            TextButton(
                              onPressed: openTerms,
                              child: Text(
                                'Terms',
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
                              color: cs.outlineVariant.withValues(alpha: 0.26),
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
                                        ?.copyWith(fontWeight: FontWeight.w900),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Copy code',
                                  onPressed: copyCode,
                                  icon: const Icon(Icons.copy_rounded),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Use this code at checkout.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ] else ...[
                        Text(
                          'No promo code required.',
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
                          label: 'Shop products in this offer',
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
