import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_routes.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_cached_network_image.dart';
import '../../../../domain/entities/product.dart';

class FeaturedSearchCard extends StatelessWidget {
  const FeaturedSearchCard({super.key, required this.product});

  final Product product;

  static const double _imageSize = 80;
  static const double _radius = 36;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final radius = BorderRadius.circular(_radius);

    return RepaintBoundary(
      child: InkWell(
        onTap: () => context.push('${AppRoutes.product}?id=${product.id}'),
        borderRadius: radius,
        child: SizedBox(
          width: _imageSize,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: _imageSize,
                height: _imageSize,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: radius,
                    boxShadow: AppShadows.sm(),
                  ),
                  child: ClipRRect(
                    borderRadius: radius,
                    child: AppCachedNetworkImage(
                      url: product.imageUrl,
                      fit: BoxFit.cover,
                      backgroundColor: cs.surfaceContainerHigh,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpace.xs),
              Text(
                product.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
