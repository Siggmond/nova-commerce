import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_routes.dart';
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
    final listImageWidth = 1.sw - 32.w;

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

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
            itemCount: products.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final p = products[index];
              return ProductCard(
                key: ValueKey(p.id),
                product: p,
                isSaved: true,
                imageWidth: listImageWidth,
                onToggleSaved: () =>
                    ref.read(wishlistViewModelProvider.notifier).toggle(p.id),
                onTap: () => context.push('${AppRoutes.product}?id=${p.id}'),
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
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
      children: List.generate(4, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: const Shimmer(child: SkeletonBox(height: 220, radius: 16)),
        );
      }),
    );
  }
}
