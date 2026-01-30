import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_routes.dart';
import '../../../core/config/providers.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_cached_network_image.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/nova_product_tile.dart';
import '../../../domain/entities/product.dart';
import '../../wishlist/presentation/wishlist_viewmodel.dart';

final trendingProductsProvider = FutureProvider((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final page = await repo.getFeaturedProducts(limit: 20);
  return page.items;
});

class TrendsScreen extends ConsumerWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(wishlistIdsProvider);
    final productsAsync = ref.watch(trendingProductsProvider);

    void toggleSaved(String id) {
      ref.read(wishlistViewModelProvider.notifier).toggle(id);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Trends')),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorState(
          title: 'Could not load trends',
          subtitle: e.toString(),
          actionText: 'Retry',
          onAction: () => ref.invalidate(trendingProductsProvider),
        ),
        data: (products) {
          if (products.isEmpty) {
            return const AppEmptyState(
              title: 'No curated picks yet.',
              subtitle: '',
              icon: Icons.trending_up_outlined,
            );
          }

          final hero = products.first;
          final favorites = products.skip(1).take(8).toList(growable: false);
          final worthALook = products
              .skip(1 + favorites.length)
              .take(6)
              .toList(growable: false);
          final morePicks = products
              .skip(1 + favorites.length + worthALook.length)
              .take(8)
              .toList(growable: false);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _EditorialHero(
                    product: hero,
                    isSaved: ids.contains(hero.id),
                    onToggleSaved: () => toggleSaved(hero.id),
                    onTap: () =>
                        context.push('${AppRoutes.product}?id=${hero.id}'),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _EditorialIntroCard(
                    title: "This week’s edit",
                    subtitle:
                        'A curated selection from our catalog — chosen for style, versatility, and easy pairing. Not a popularity leaderboard.',
                  ),
                ),
              ),
              if (favorites.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: _SectionHeader(
                      title: "Editor’s favorites",
                      subtitle: 'Strong picks to start with.',
                    ),
                  ),
                ),
              if (favorites.isNotEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 228,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      scrollDirection: Axis.horizontal,
                      itemCount: favorites.length,
                      separatorBuilder: (_, __) => SizedBox(width: AppSpace.md),
                      itemBuilder: (context, index) {
                        final product = favorites[index];
                        return SizedBox(
                          width: 160,
                          child: NovaProductTile(
                            product: product,
                            onTap: () => context.push(
                              '${AppRoutes.product}?id=${product.id}',
                            ),
                            isSaved: ids.contains(product.id),
                            onToggleSaved: () => toggleSaved(product.id),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              if (worthALook.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: _SectionHeader(
                      title: 'Worth a look',
                      subtitle: 'A few more curated picks for variety.',
                    ),
                  ),
                ),
              if (worthALook.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gridCrossAxisCount(context),
                      mainAxisSpacing: AppSpace.md,
                      crossAxisSpacing: AppSpace.md,
                      childAspectRatio: 1.9,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = worthALook[index];
                      return ProductCard(
                        product: product,
                        onTap: () => context.push(
                          '${AppRoutes.product}?id=${product.id}',
                        ),
                        isSaved: ids.contains(product.id),
                        onToggleSaved: () => toggleSaved(product.id),
                      );
                    }, childCount: worthALook.length),
                  ),
                ),
              if (morePicks.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: _SectionHeader(
                      title: 'More curated picks',
                      subtitle: 'If you want to explore beyond the edit.',
                    ),
                  ),
                ),
              if (morePicks.isNotEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 228,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: morePicks.length,
                      separatorBuilder: (_, __) => SizedBox(width: AppSpace.md),
                      itemBuilder: (context, index) {
                        final product = morePicks[index];
                        return SizedBox(
                          width: 160,
                          child: NovaProductTile(
                            product: product,
                            onTap: () => context.push(
                              '${AppRoutes.product}?id=${product.id}',
                            ),
                            isSaved: ids.contains(product.id),
                            onToggleSaved: () => toggleSaved(product.id),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
            ],
          );
        },
      ),
    );
  }
}

int _gridCrossAxisCount(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w >= 900) return 3;
  return 2;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        SizedBox(height: AppSpace.xxs),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.72),
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class _EditorialIntroCard extends StatelessWidget {
  const _EditorialIntroCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            SizedBox(height: AppSpace.xs),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.28,
                color: cs.onSurface.withValues(alpha: 0.82),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorialHero extends StatelessWidget {
  const _EditorialHero({
    required this.product,
    required this.isSaved,
    required this.onToggleSaved,
    required this.onTap,
  });

  final Product product;
  final bool isSaved;
  final VoidCallback onToggleSaved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.xl),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              children: [
                Positioned.fill(
                  child: AppCachedNetworkImage(
                    url: product.imageUrl,
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
                          Colors.black.withValues(alpha: 0.18),
                          Colors.black.withValues(alpha: 0.55),
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: cs.surface.withValues(alpha: 0.86),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.55),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Text(
                        'Editor’s pick',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: cs.surface.withValues(alpha: 0.86),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 40,
                        height: 40,
                      ),
                      onPressed: onToggleSaved,
                      icon: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        color: isSaved
                            ? cs.primary
                            : cs.onSurface.withValues(alpha: 0.78),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This week’s hero pick',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: AppSpace.xs),
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                        ),
                      ),
                      SizedBox(height: AppSpace.xs),
                      Text(
                        '${product.currency} ${product.price.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontWeight: FontWeight.w900,
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
