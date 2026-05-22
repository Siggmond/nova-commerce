import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/product_card.dart';
import 'package:nova_commerce/features/wishlist/wishlist.dart';
import '../../home/presentation/home_viewmodel.dart';

class PickedForYouScreen extends StatelessWidget {
  const PickedForYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.homePickedForYouTitle)),
      body: const _PickedForYouBody(),
    );
  }
}

class _PickedForYouBody extends ConsumerWidget {
  const _PickedForYouBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    const gridChildAspectRatio = 0.56;

    final state = ref.watch(homeViewModelProvider);

    void toggleSaved(String id) {
      ref.read(wishlistViewModelProvider.notifier).toggle(id);
    }

    Future<void> refresh() async {
      await ref.read(homeViewModelProvider.notifier).refresh(showLoading: true);
    }

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e) => AppErrorState(
        title: t.homePicksLoadErrorTitle,
        subtitle: e.toString(),
        actionText: t.commonRetry,
        onAction: () => refresh(),
      ),
      data: (items, isRefreshing, _, __) {
        final picks = items.reversed.toList(growable: false);
        if (picks.isEmpty) {
          return AppEmptyState(
            title: t.homeNoPicksTitle,
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
          ),
        );
      },
    );
  }
}
