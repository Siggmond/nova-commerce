import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

import 'package:nova_commerce/app/di/app_providers.dart';
import 'package:nova_commerce/features/wishlist/wishlist.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/domain/entities/product.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/product_card.dart';

final trendingNowProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final page = await repo.getFeaturedProducts(limit: 40);
  return page.items;
});

class TrendingNowScreen extends StatelessWidget {
  const TrendingNowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.homeTrendingNowTitle)),
      body: const _TrendingNowBody(),
    );
  }
}

class _TrendingNowBody extends ConsumerWidget {
  const _TrendingNowBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    const gridChildAspectRatio = 0.56;

    final productsAsync = ref.watch(trendingNowProductsProvider);

    void toggleSaved(String id) {
      ref.read(wishlistViewModelProvider.notifier).toggle(id);
    }

    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => AppErrorState(
        title: t.homeTrendingNowLoadErrorTitle,
        subtitle: e.toString(),
        actionText: t.commonRetry,
        onAction: () => ref.invalidate(trendingNowProductsProvider),
      ),
      data: (products) {
        if (products.isEmpty) {
          return AppEmptyState(
            title: t.homeNoTrendingPicksTitle,
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
                return Consumer(
                  builder: (context, ref, _) {
                    final isSaved = ref.watch(
                      wishlistIdsProvider.select((ids) => ids.contains(p.id)),
                    );
                    return ProductCard(
                      key: ValueKey(p.id),
                      product: p,
                      isSaved: isSaved,
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
        );
      },
    );
  }
}
