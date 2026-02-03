import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/product_card.dart';
import '../../wishlist/presentation/wishlist_viewmodel.dart';
import '../../home/presentation/home_viewmodel.dart';

class PickedForYouScreen extends ConsumerWidget {
  const PickedForYouScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const gridChildAspectRatio = 0.56;

    final ids = ref.watch(wishlistIdsProvider);
    final state = ref.watch(homeViewModelProvider);

    void toggleSaved(String id) {
      ref.read(wishlistViewModelProvider.notifier).toggle(id);
    }

    Future<void> refresh() async {
      await ref.read(homeViewModelProvider.notifier).refresh(showLoading: true);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Picked for you')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e) => AppErrorState(
          title: 'Could not load picks',
          subtitle: e.toString(),
          actionText: 'Retry',
          onAction: () => refresh(),
        ),
        data: (items, isRefreshing, _, __) {
          final picks = items.reversed.toList(growable: false);
          if (picks.isEmpty) {
            return const AppEmptyState(
              title: 'No picks yet',
              subtitle: '',
              icon: Icons.auto_awesome_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: refresh,
            child: LayoutBuilder(
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
                  itemCount: picks.length,
                  itemBuilder: (context, index) {
                    final p = picks[index];
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
            ),
          );
        },
      ),
    );
  }
}
