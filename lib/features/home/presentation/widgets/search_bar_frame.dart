import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_tokens.dart';

class SearchBarFrame extends StatelessWidget {
  const SearchBarFrame({
    super.key,
    required this.child,
    this.docked = false,
    this.reduceEffects = false,
  });

  final Widget child;
  final bool docked;
  final bool reduceEffects;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final radius = BorderRadius.circular(AppRadii.xl);
    final frameInset = docked ? 1.0 : 2.0;
    final innerRadius = BorderRadius.circular(
      (AppRadii.xl - frameInset).clamp(0, AppRadii.xl),
    );

    final blue = AppColors.categoryChipPalette[0].withValues(alpha: 0.92);
    final red = AppColors.categoryChipPalette[5].withValues(alpha: 0.88);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [blue, cs.primary.withValues(alpha: 0.10), red],
          stops: const [0.0, 0.52, 1.0],
        ),
        boxShadow: reduceEffects
            ? const <BoxShadow>[]
            : (docked ? AppShadows.lg() : AppShadows.md()),
      ),
      child: Padding(
        padding: EdgeInsets.all(frameInset),
        child: reduceEffects
            ? DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: innerRadius,
                  color: cs.surface,
                ),
                child: child,
              )
            : ClipRRect(
                borderRadius: innerRadius,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: innerRadius,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        blue.withValues(alpha: 0.18),
                        Colors.transparent,
                        red.withValues(alpha: 0.18),
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                  child: child,
                ),
              ),
      ),
    );
  }
}
