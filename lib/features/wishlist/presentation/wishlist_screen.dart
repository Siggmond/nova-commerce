import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/shimmer.dart';
import 'wishlist_viewmodel.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wishlistViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: state.when(
        loading: () => const _WishlistSkeleton(),
        error: (e) => AppErrorState(
          title: 'Could not load wishlist',
          subtitle: e.toString(),
          actionText: 'Retry',
          onAction: () =>
              ref.read(wishlistViewModelProvider.notifier).refresh(),
        ),
        data: (ids, products) {
          if (ids.isEmpty || products.isEmpty) {
            return const AppEmptyState(
              title: 'No saved items yet',
              subtitle: 'Tap the heart on a product to save it here.',
              icon: Icons.favorite_border,
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width < 420
                  ? 2
                  : (width < 620 ? 3 : (width < 900 ? 4 : 5));

              return GridView.builder(
                padding: AppInsets.screen,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: AppSpace.sm,
                  crossAxisSpacing: AppSpace.sm,
                  childAspectRatio: 0.62,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final p = products[index];
                  return ProductCard(
                    key: ValueKey(p.id),
                    product: p,
                    isSaved: true,
                    fillHeight: true,
                    onToggleSaved: () => ref
                        .read(wishlistViewModelProvider.notifier)
                        .toggle(p.id),
                    onTap: () =>
                        context.push('${AppRoutes.product}?id=${p.id}'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _WishlistSkeleton extends StatelessWidget {
  const _WishlistSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: AppInsets.screen,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.62,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer(child: SkeletonBox(height: 184, radius: AppRadii.md));
      },
    );
  }
}
