import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_routes.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_cached_network_image.dart';

class CollectionsSection extends ConsumerWidget {
  const CollectionsSection({super.key});

  static const double _cardHeight = 92;

  @override
  Widget build(BuildContext context, WidgetRef _) {
    final cs = Theme.of(context).colorScheme;

    final collections = _collections;

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 18.h),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.crossAxisExtent;
          final crossAxisCount = width < 480 ? 1 : (width < 900 ? 2 : 3);
          const spacing = 12.0;

          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              mainAxisExtent: _cardHeight,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final c = collections[index];
              return _CollectionCard(
                key: ValueKey('collection_${c.id}'),
                title: c.title,
                subtitle: c.subtitle,
                imageUrl: c.imageUrl,
                categoryLabel: c.category,
                onTap: () {
                  context.push('${AppRoutes.searchCollection}/${c.id}');
                },
                surface: cs.surface,
                outline: cs.outlineVariant.withValues(alpha: 0.28),
              );
            }, childCount: collections.length),
          );
        },
      ),
    );
  }
}

class _Collection {
  const _Collection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.category,
  });

  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String category;
}

const _collections = <_Collection>[
  _Collection(
    id: 'editorial_1',
    title: 'Editor’s selection',
    subtitle: 'Curated finds with premium finishes',
    imageUrl:
        'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=1200&q=70',
    category: 'Groceries',
  ),
  _Collection(
    id: 'editorial_2',
    title: 'Weekend essentials',
    subtitle: 'Low effort, high impact staples',
    imageUrl:
        'https://images.unsplash.com/photo-1520975693416-35a0d50c1bb9?auto=format&fit=crop&w=1200&q=70',
    category: 'Restaurants',
  ),
  _Collection(
    id: 'editorial_3',
    title: 'Clean tech',
    subtitle: 'Minimal + modern picks',
    imageUrl:
        'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=1200&q=70',
    category: 'Electronics',
  ),
  _Collection(
    id: 'editorial_4',
    title: 'Coffee corner',
    subtitle: 'Small upgrades that feel expensive',
    imageUrl:
        'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=1200&q=70',
    category: 'Coffee',
  ),
  _Collection(
    id: 'editorial_5',
    title: 'Everyday treats',
    subtitle: 'Snackable favorites',
    imageUrl:
        'https://images.unsplash.com/photo-1584270354949-1d52f0d8c2d0?auto=format&fit=crop&w=1200&q=70',
    category: 'Snacks',
  ),
  _Collection(
    id: 'editorial_6',
    title: 'Baby & family',
    subtitle: 'Soft picks, gentle choices',
    imageUrl:
        'https://images.unsplash.com/photo-1588072432836-10c7f2d9c1f2?auto=format&fit=crop&w=1200&q=70',
    category: 'Baby',
  ),
];

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.categoryLabel,
    required this.onTap,
    required this.surface,
    required this.outline,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final String categoryLabel;
  final VoidCallback onTap;
  final Color surface;
  final Color outline;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final radius = BorderRadius.circular(AppRadii.xl);

    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: radius,
              border: Border.all(color: outline),
              boxShadow: AppShadows.md(),
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AppCachedNetworkImage(
                      url: imageUrl,
                      fit: BoxFit.cover,
                      backgroundColor: cs.surfaceContainerHigh,
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.05),
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12.w,
                    right: 12.w,
                    bottom: 10.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontWeight: FontWeight.w700,
                                height: 1.0,
                              ),
                        ),
                        SizedBox(height: 6.h),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            child: Text(
                              categoryLabel.trim().isEmpty
                                  ? 'Explore'
                                  : categoryLabel.trim(),
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
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
      ),
    );
  }
}
