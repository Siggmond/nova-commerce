import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_routes.dart';
import '../../../core/config/providers.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/product_card.dart';
import '../../../domain/entities/product.dart';
import '../../wishlist/presentation/wishlist_viewmodel.dart';

final trendingNowProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final page = await repo.getFeaturedProducts(limit: 40);
  return page.items;
});

class TrendingNowScreen extends ConsumerWidget {
  const TrendingNowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const gridChildAspectRatio = 0.56;

    final ids = ref.watch(wishlistIdsProvider);
    final productsAsync = ref.watch(trendingNowProductsProvider);

    void toggleSaved(String id) {
      ref.read(wishlistViewModelProvider.notifier).toggle(id);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Trending now')),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorState(
          title: 'Could not load trending now',
          subtitle: e.toString(),
          actionText: 'Retry',
          onAction: () => ref.invalidate(trendingNowProductsProvider),
        ),
        data: (products) {
          if (products.isEmpty) {
            return const AppEmptyState(
              title: 'No trending picks yet',
              subtitle: '',
              icon: Icons.trending_up_outlined,
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
                  childAspectRatio: gridChildAspectRatio,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final p = products[index];
                  return ProductCard(
                    key: ValueKey(p.id),
                    product: p,
                    isSaved: ids.contains(p.id),
                    fillHeight: true,
                    onToggleSaved: () => toggleSaved(p.id),
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
