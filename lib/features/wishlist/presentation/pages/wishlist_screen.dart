import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nova_commerce/app/router/app_routes.dart';
import 'package:nova_commerce/app/theme/app_tokens.dart';
import 'package:nova_commerce/core/widgets/empty_state.dart';
import 'package:nova_commerce/core/widgets/error_state.dart';
import 'package:nova_commerce/core/widgets/product_card.dart';
import 'package:nova_commerce/core/widgets/shimmer.dart';
import 'package:nova_commerce/features/wishlist/presentation/state/wishlist_viewmodel.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(wishlistViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.wishlistTitle)),
      body: state.when(
        loading: () => const _WishlistSkeleton(),
        error: (e) => AppErrorState(
          title: l10n.wishlistLoadErrorTitle,
          subtitle: e.toString(),
          actionText: l10n.commonRetry,
          onAction: () =>
              ref.read(wishlistViewModelProvider.notifier).refresh(),
        ),
        data: (ids, products) {
          if (ids.isEmpty || products.isEmpty) {
            return AppEmptyState(
              title: l10n.wishlistEmptyTitle,
              subtitle: l10n.wishlistEmptySubtitle,
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8.h,
        crossAxisSpacing: 8.w,
        childAspectRatio: 0.62,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer(
          child: SkeletonBox(height: 184.h, radius: AppRadii.md),
        );
      },
    );
  }
}
