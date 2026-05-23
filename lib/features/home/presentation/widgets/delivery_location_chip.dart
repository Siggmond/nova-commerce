import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:nova_commerce/gen_l10n/app_localizations.dart';

import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_tokens.dart';
import '../delivery_location_controller.dart';

class DeliveryLocationChip extends ConsumerWidget {
  const DeliveryLocationChip({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final cityAsync = ref.watch(deliveryLocationProvider);

    String resolveCityLabel(String city) {
      switch (city.trim().toLowerCase()) {
        case 'beirut':
          return t.homeCityBeirut;
        case 'tripoli':
          return t.homeCityTripoli;
        case 'sidon':
          return t.homeCitySidon;
        case 'tyre':
          return t.homeCityTyre;
        case 'jounieh':
          return t.homeCityJounieh;
        case 'byblos':
          return t.homeCityByblos;
        case 'zahle':
          return t.homeCityZahle;
        case 'baalbek':
          return t.homeCityBaalbek;
        case 'nabatieh':
          return t.homeCityNabatieh;
        case 'batroun':
          return t.homeCityBatroun;
        case 'bsharri':
          return t.homeCityBsharri;
        case 'aley':
          return t.homeCityAley;
        default:
          return city;
      }
    }

    final city = cityAsync.when(
      data: (v) => v,
      loading: () => '...',
      error: (_, __) => t.homeCityBeirut,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final bool ultraCompact = maxW.isFinite && maxW < 72;
        final bool compact = maxW.isFinite && maxW < 140;

        final resolvedCity = resolveCityLabel(city);
        final String label = compact
            ? resolvedCity
            : t.homeDeliverToCity(resolvedCity);

        return Material(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.50),
                ),
                boxShadow: AppShadows.sm(
                  color: Colors.black.withValues(alpha: 0.08),
                ),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: AppHitTargets.min),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ultraCompact ? AppSpace.sm : AppSpace.md,
                    vertical: AppSpace.xs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 28.r,
                        height: 28.r,
                        child: SvgPicture.asset(
                          'assets/icons/location.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                      if (!ultraCompact) ...[
                        SizedBox(width: AppSpace.sm),
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        if (!compact) ...[
                          SizedBox(width: AppSpace.xs),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 18.r,
                            color: cs.onSurface.withValues(alpha: 0.78),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
