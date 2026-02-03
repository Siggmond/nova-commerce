import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_shadows.dart';
import '../delivery_location_controller.dart';

class DeliveryLocationChip extends ConsumerWidget {
  const DeliveryLocationChip({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final cityAsync = ref.watch(deliveryLocationProvider);

    final city = cityAsync.when(
      data: (v) => v,
      loading: () => '…',
      error: (_, __) => 'Beirut',
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final bool ultraCompact = maxW.isFinite && maxW < 72;
        final bool compact = maxW.isFinite && maxW < 140;

        final String label = compact ? city : 'Deliver to $city';

        return Material(
          color: cs.surface,
          borderRadius: BorderRadius.circular(999.r),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999.r),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.75),
                ),
                boxShadow: AppShadows.sm(),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ultraCompact ? 8.w : 10.w,
                  vertical: 7.h,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16.r,
                      color: cs.onSurface,
                    ),
                    if (!ultraCompact) ...[
                      SizedBox(width: 6.w),
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
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 18.r,
                          color: cs.onSurface,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
