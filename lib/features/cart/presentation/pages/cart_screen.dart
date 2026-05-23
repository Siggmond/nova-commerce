import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:nova_commerce/app/di/app_providers.dart';
import 'package:nova_commerce/app/config/app_env.dart';
import 'package:nova_commerce/app/router/app_routes.dart';
import 'package:nova_commerce/app/theme/app_shadows.dart';
import 'package:nova_commerce/app/theme/app_tokens.dart';
import 'package:nova_commerce/core/perf/perf_markers.dart';
import 'package:nova_commerce/core/widgets/app_cached_network_image.dart';
import 'package:nova_commerce/core/widgets/error_state.dart';
import 'package:nova_commerce/core/widgets/nova_button.dart';
import 'package:nova_commerce/core/widgets/nova_surface.dart';
import 'package:nova_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:nova_commerce/features/cart/domain/entities/cart_state_model.dart';
import 'package:nova_commerce/features/cart/domain/entities/recommended_item.dart';
import 'package:nova_commerce/features/cart/presentation/state/cart_viewmodel.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    PerfMarkers.cartOpen();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final useNovaUi = AppEnv.enableNovaUi && AppEnv.enableNovaUiCart;
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(l10n.cartTitle, style: titleStyle),
        actions: [_SelectAllAction(l10n: l10n)],
      ),
      body: _CartBody(useNovaUi: useNovaUi),
      bottomNavigationBar: _CartBottomBar(useNovaUi: useNovaUi),
    );
  }
}

class _SelectAllAction extends ConsumerWidget {
  const _SelectAllAction({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderKeys = ref.watch(cartOrderProvider);
    final summary = ref.watch(cartSelectionSummaryProvider);
    final selectionVm = ref.read(selectedCartItemIdsProvider.notifier);
    final hasItems = orderKeys.isNotEmpty;

    return TextButton(
      onPressed: !hasItems
          ? null
          : () {
              if (summary.allSelected) {
                selectionVm.selectAll(const <String>[]);
                return;
              }
              selectionVm.selectAll(orderKeys.map((key) => key.productId));
            },
      child: Text(
        summary.allSelected ? l10n.cartDeselectAll : l10n.cartSelectAll,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _CartBody extends ConsumerWidget {
  const _CartBody({required this.useNovaUi});

  final bool useNovaUi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final loadStatus = ref.watch(cartLoadStatusProvider);

    switch (loadStatus) {
      case CartLoadStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case CartLoadStatus.error:
        final error = ref.watch(cartLoadErrorProvider);
        return AppErrorState(
          title: l10n.cartLoadErrorTitle,
          subtitle: error?.toString() ?? '',
          actionText: l10n.commonRetry,
          onAction: () => ref.read(cartViewModelProvider.notifier).refresh(),
        );
      case CartLoadStatus.ready:
        final hasItems = ref.watch(
          cartOrderProvider.select((keys) => keys.isNotEmpty),
        );
        if (!hasItems) return const _EmptyCart();
        return _CartReadyContent(useNovaUi: useNovaUi);
    }
  }
}

class _CartReadyContent extends ConsumerWidget {
  const _CartReadyContent({required this.useNovaUi});

  final bool useNovaUi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final currentUid = ref.watch(currentUidProvider);
    final orderKeys = ref.watch(cartOrderProvider);
    final recommended = ref.watch(recommendedItemsProvider);
    final selectedFilter = ref.watch(recommendedFilterProvider);
    final recommendedCount = recommended.length.clamp(0, 4);
    final dpr = ScreenUtil().pixelRatio ?? 1.0;
    final thumbSize = 72.w;
    final memThumb = (thumbSize * dpr).round();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpace.xl,
            AppSpace.sm,
            AppSpace.xl,
            AppSpace.md,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (currentUid == null)
                _InfoBanner(icon: Icons.sync, message: l10n.cartSyncNotice),
              const _SelectionInfoBanner(),
            ]),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppSpace.xl),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final cartKey = orderKeys[index];
              return Column(
                children: [
                  _PremiumCartItemRow(
                    cartKey: cartKey,
                    useNovaUi: useNovaUi,
                    thumbSize: thumbSize,
                    memThumb: memThumb,
                  ),
                  if (index != orderKeys.length - 1)
                    SizedBox(height: AppSpace.md),
                ],
              );
            }, childCount: orderKeys.length),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpace.xl,
            0,
            AppSpace.xl,
            AppSpace.md,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: AppSpace.lg),
              Divider(color: cs.outlineVariant.withValues(alpha: 0.6)),
              SizedBox(height: AppSpace.md),
              Text(
                l10n.cartYouMightLikeTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              SizedBox(height: AppSpace.xxs),
              Text(
                l10n.cartYouMightLikeSubtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.72),
                ),
              ),
              SizedBox(height: AppSpace.sm),
              Wrap(
                spacing: AppSpace.sm,
                runSpacing: AppSpace.sm,
                children: [
                  _FilterChip(
                    label: l10n.cartFilterAll,
                    selected: selectedFilter == RecommendedFilter.all,
                    onTap: () =>
                        ref.read(recommendedFilterProvider.notifier).state =
                            RecommendedFilter.all,
                  ),
                  _FilterChip(
                    label: l10n.cartFilterHotDeals,
                    selected: selectedFilter == RecommendedFilter.hotDeals,
                    onTap: () =>
                        ref.read(recommendedFilterProvider.notifier).state =
                            RecommendedFilter.hotDeals,
                  ),
                  _FilterChip(
                    label: l10n.cartFilterFrequentFavorites,
                    selected:
                        selectedFilter == RecommendedFilter.frequentFavorites,
                    onTap: () =>
                        ref.read(recommendedFilterProvider.notifier).state =
                            RecommendedFilter.frequentFavorites,
                  ),
                ],
              ),
              SizedBox(height: AppSpace.md),
            ]),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpace.xl,
            0,
            AppSpace.xl,
            AppSpace.md,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpace.sm,
              crossAxisSpacing: AppSpace.sm,
              childAspectRatio: 0.86,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = recommended[index];
              return GestureDetector(
                onTap: () => context.push('${AppRoutes.product}?id=${item.id}'),
                child: _RecommendedCard(item: item),
              );
            }, childCount: recommendedCount),
          ),
        ),
      ],
    );
  }
}

class _CartBottomBar extends ConsumerWidget {
  const _CartBottomBar({required this.useNovaUi});

  final bool useNovaUi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadStatus = ref.watch(cartLoadStatusProvider);
    if (loadStatus != CartLoadStatus.ready) return const SizedBox.shrink();

    final hasItems = ref.watch(
      cartOrderProvider.select((keys) => keys.isNotEmpty),
    );
    if (!hasItems) return const SizedBox.shrink();

    final summary = ref.watch(cartSelectionSummaryProvider);
    final selectedSubtotal = ref.watch(selectedCartSubtotalProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final currency = ref.watch(cartCurrencyProvider);

    return SafeArea(
      top: false,
      child: _CheckoutBar(
        currency: currency,
        subtotal: summary.hasSelection ? selectedSubtotal : subtotal,
        hasSelection: summary.hasSelection,
        allSelected: summary.allSelected,
        useNovaUi: useNovaUi,
        onCheckout: !summary.hasSelection
            ? null
            : () => context.push(AppRoutes.checkout),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: AppSpace.md),
      padding: AppInsets.cardTight,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.36)),
        boxShadow: AppShadows.sm(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: AppHitTargets.min,
            height: AppHitTargets.min,
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.28),
              ),
            ),
            child: Icon(
              icon,
              color: cs.onSurface.withValues(alpha: 0.75),
              size: 20.r,
            ),
          ),
          SizedBox(width: AppSpace.md),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.82),
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionInfoBanner extends ConsumerWidget {
  const _SelectionInfoBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final summary = ref.watch(cartSelectionSummaryProvider);

    final allSelected = summary.allSelected;
    final hasSelection = summary.hasSelection;
    final message = allSelected
        ? l10n.cartSelectionAllSelectedMessage
        : hasSelection
        ? l10n.cartSelectionSomeSelectedMessage
        : l10n.cartSelectionNoneSelectedMessage;
    final surfaceColor = hasSelection
        ? cs.primaryContainer.withValues(alpha: 0.18)
        : cs.surface;
    final iconColor = hasSelection
        ? cs.primary
        : cs.onSurface.withValues(alpha: 0.75);

    return Container(
      margin: EdgeInsets.only(bottom: AppSpace.md),
      padding: AppInsets.cardTight,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: hasSelection
              ? cs.primary.withValues(alpha: 0.30)
              : cs.outlineVariant.withValues(alpha: 0.36),
        ),
        boxShadow: AppShadows.sm(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: AppHitTargets.min,
            height: AppHitTargets.min,
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.74),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: hasSelection
                    ? cs.primary.withValues(alpha: 0.22)
                    : cs.outlineVariant.withValues(alpha: 0.28),
              ),
            ),
            child: Icon(Icons.checklist, color: iconColor, size: 20.r),
          ),
          SizedBox(width: AppSpace.md),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _CartItemRow extends ConsumerWidget {
  const _CartItemRow({
    required this.item,
    required this.useNovaUi,
    required this.thumbSize,
    required this.memThumb,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  final CartItem item;
  final bool useNovaUi;
  final double thumbSize;
  final int memThumb;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final selected = ref.watch(
      selectedCartItemIdsProvider.select(
        (ids) => ids.contains(item.product.id),
      ),
    );
    final selectionVm = ref.read(selectedCartItemIdsProvider.notifier);

    final row = Padding(
      padding: EdgeInsets.all(6.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => selectionVm.toggle(item.product.id),
            child: SizedBox(
              width: 36.r,
              height: 36.r,
              child: Center(
                child: Container(
                  width: 16.r,
                  height: 16.r,
                  decoration: BoxDecoration(
                    color: selected ? cs.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: selected
                          ? cs.primary
                          : cs.outlineVariant.withValues(alpha: 0.7),
                    ),
                  ),
                  child: selected
                      ? Icon(Icons.check, size: 10.r, color: Colors.white)
                      : null,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          AppCachedNetworkImage(
            url: item.product.imageUrl,
            width: thumbSize,
            height: thumbSize,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(10.r),
            memCacheWidth: memThumb,
            memCacheHeight: memThumb,
            backgroundColor: cs.surfaceContainerHigh,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${item.selectedColor} • ${item.selectedSize}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    IconButton(
                      onPressed: onDecrease,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints.tightFor(
                        width: 34.r,
                        height: 34.r,
                      ),
                      icon: Icon(Icons.remove_circle, size: 16.r),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      item.quantity.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    IconButton(
                      onPressed: onIncrease,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints.tightFor(
                        width: 34.r,
                        height: 34.r,
                      ),
                      icon: Icon(Icons.add_circle, size: 16.r),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onRemove,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints.tightFor(
                        width: 34.r,
                        height: 34.r,
                      ),
                      icon: Icon(Icons.close, size: 16.r),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (useNovaUi) {
      return RepaintBoundary(
        child: NovaSurface(
          key: ValueKey(item.product.id),
          padding: EdgeInsets.zero,
          child: row,
        ),
      );
    }

    return RepaintBoundary(
      child: Card(key: ValueKey(item.product.id), child: row),
    );
  }
}

class _PremiumCartItemRow extends ConsumerWidget {
  const _PremiumCartItemRow({
    required this.cartKey,
    required this.useNovaUi,
    required this.thumbSize,
    required this.memThumb,
  });

  final CartKey cartKey;
  final bool useNovaUi;
  final double thumbSize;
  final int memThumb;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(cartItemByKeyProvider(cartKey));
    if (item == null) {
      return const SizedBox.shrink();
    }

    final vm = ref.read(cartViewModelProvider.notifier);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final selected = ref.watch(
      selectedCartItemIdsProvider.select(
        (ids) => ids.contains(item.product.id),
      ),
    );
    final selectionVm = ref.read(selectedCartItemIdsProvider.notifier);
    final borderColor = selected
        ? cs.primary.withValues(alpha: 0.48)
        : cs.outlineVariant.withValues(alpha: 0.48);
    final cardRadius = BorderRadius.circular(AppRadii.lg);
    final cardColor = selected
        ? cs.primaryContainer.withValues(alpha: 0.10)
        : cs.surface;
    final unitPrice = _formatMoney(item.product.currency, item.product.price);
    final totalPrice = _formatMoney(item.product.currency, item.total);
    final itemKey = _premiumCartItemKey(item);

    final row = InkWell(
      borderRadius: cardRadius,
      onTap: () => context.push('${AppRoutes.product}?id=${item.product.id}'),
      child: Padding(
        padding: AppInsets.cardTight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => selectionVm.toggle(item.product.id),
                  child: SizedBox(
                    width: AppHitTargets.min,
                    height: AppHitTargets.min,
                    child: Center(
                      child: Container(
                        width: 20.r,
                        height: 20.r,
                        decoration: BoxDecoration(
                          color: selected ? cs.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                          border: Border.all(
                            color: selected
                                ? cs.primary
                                : cs.outlineVariant.withValues(alpha: 0.72),
                          ),
                        ),
                        child: selected
                            ? Icon(
                                Icons.check_rounded,
                                size: 12.r,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSpace.sm),
                AppCachedNetworkImage(
                  url: item.product.imageUrl,
                  width: thumbSize,
                  height: thumbSize,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  memCacheWidth: memThumb,
                  memCacheHeight: memThumb,
                  backgroundColor: cs.surfaceContainerHigh,
                ),
                SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.product.brand.trim().isNotEmpty)
                                  Text(
                                    item.product.brand,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: tt.labelSmall?.copyWith(
                                      color: cs.onSurface.withValues(
                                        alpha: 0.66,
                                      ),
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                Text(
                                  item.product.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: tt.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    height: 1.15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: AppSpace.sm),
                          Container(
                            width: AppHitTargets.min,
                            height: AppHitTargets.min,
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHigh.withValues(
                                alpha: 0.75,
                              ),
                              borderRadius: BorderRadius.circular(AppRadii.md),
                              border: Border.all(
                                color: cs.outlineVariant.withValues(
                                  alpha: 0.24,
                                ),
                              ),
                            ),
                            child: IconButton(
                              onPressed: () => vm.removeByKey(cartKey),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints.tightFor(
                                width: AppHitTargets.min,
                                height: AppHitTargets.min,
                              ),
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                size: 17.r,
                                color: cs.onSurface.withValues(alpha: 0.78),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpace.sm),
                      Wrap(
                        spacing: AppSpace.sm,
                        runSpacing: AppSpace.xs,
                        children: [
                          _PremiumCartMetaPill(
                            icon: Icons.palette_outlined,
                            label: item.selectedColor,
                          ),
                          _PremiumCartMetaPill(
                            icon: Icons.straighten_rounded,
                            label: item.selectedSize,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpace.md),
            Row(
              children: [
                _PremiumCartQuantityStepper(
                  quantity: item.quantity,
                  canDecrease: item.quantity > 1,
                  onDecrease: () =>
                      vm.updateQuantityByKey(cartKey, item.quantity - 1),
                  onIncrease: () =>
                      vm.updateQuantityByKey(cartKey, item.quantity + 1),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      totalPrice,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: AppSpace.xxs),
                    Text(
                      unitPrice,
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.64),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (useNovaUi) {
      return RepaintBoundary(
        child: NovaSurface(
          key: ValueKey(itemKey),
          padding: EdgeInsets.zero,
          color: cardColor,
          borderRadius: AppRadii.lg,
          elevation: selected ? 2 : 1,
          borderSide: BorderSide(color: borderColor),
          child: row,
        ),
      );
    }

    return RepaintBoundary(
      child: Container(
        key: ValueKey(itemKey),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: cardRadius,
          border: Border.all(color: borderColor),
          boxShadow: AppShadows.sm(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: row,
      ),
    );
  }
}

class _PremiumCartMetaPill extends StatelessWidget {
  const _PremiumCartMetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpace.sm,
        vertical: AppSpace.xxs,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.38)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: cs.onSurface.withValues(alpha: 0.72)),
          SizedBox(width: AppSpace.xxs),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.82),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumCartQuantityStepper extends StatelessWidget {
  const _PremiumCartQuantityStepper({
    required this.quantity,
    required this.canDecrease,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final bool canDecrease;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpace.xs,
        vertical: AppSpace.xs,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PremiumCartStepperButton(
            icon: Icons.remove_rounded,
            onPressed: canDecrease ? onDecrease : null,
          ),
          SizedBox(width: AppSpace.sm),
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: 20.w),
            child: Text(
              quantity.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          SizedBox(width: AppSpace.sm),
          _PremiumCartStepperButton(
            icon: Icons.add_rounded,
            onPressed: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _PremiumCartStepperButton extends StatelessWidget {
  const _PremiumCartStepperButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 32.r,
      height: 32.r,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: IconButton(
        onPressed: onPressed,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(width: 32.r, height: 32.r),
        icon: Icon(icon, size: 15.r),
      ),
    );
  }
}

String _premiumCartItemKey(CartItem item) {
  return '${item.product.id}_${item.selectedColor}_${item.selectedSize}';
}

String _formatMoney(String currency, double value) {
  final symbol = currency.trim().toUpperCase();
  final hasCents = (value - value.truncateToDouble()).abs() > 0.00001;
  final amount = hasCents ? value.toStringAsFixed(2) : value.toStringAsFixed(0);
  return '$symbol $amount';
}

String _compactCount(int value) {
  if (value >= 1000000) {
    final shown = (value / 1000000).toStringAsFixed(1);
    return '${shown}M';
  }
  if (value >= 1000) {
    final shown = (value / 1000).toStringAsFixed(1);
    return '${shown}K';
  }
  return value.toString();
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        constraints: BoxConstraints(minHeight: AppHitTargets.min),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpace.md,
          vertical: AppSpace.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: selected
                ? cs.primary
                : cs.outlineVariant.withValues(alpha: 0.6),
          ),
          boxShadow: selected
              ? AppShadows.sm(color: cs.primary.withValues(alpha: 0.18))
              : null,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? cs.onPrimary : cs.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  const _RecommendedCard({required this.item});

  final RecommendedItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final radius = BorderRadius.circular(AppRadii.lg);
    final priceText = _formatMoney('USD', item.price);

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.42)),
          color: cs.surface,
          boxShadow: AppShadows.sm(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final dpr = MediaQuery.devicePixelRatioOf(context);
                final memWidth = (constraints.maxWidth * dpr).round();
                final memHeight = (104.h * dpr).round();
                return Stack(
                  children: [
                    AppCachedNetworkImage(
                      url: item.imageUrl,
                      height: 104.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppRadii.lg),
                      ),
                      memCacheWidth: memWidth,
                      memCacheHeight: memHeight,
                    ),
                    if (item.tags.contains('hot'))
                      Positioned(
                        left: AppSpace.sm,
                        top: AppSpace.sm,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpace.sm,
                            vertical: AppSpace.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                          child: Text(
                            'HOT',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      right: AppSpace.sm,
                      top: AppSpace.sm,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpace.sm,
                          vertical: AppSpace.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.48),
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 12.r,
                              color: Colors.amber.shade300,
                            ),
                            SizedBox(width: AppSpace.xxs),
                            Text(
                              item.rating.toStringAsFixed(1),
                              style: tt.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            Padding(
              padding: AppInsets.cardTight.copyWith(top: AppSpace.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: AppSpace.xs),
                  Row(
                    children: [
                      Text(
                        priceText,
                        style: tt.labelLarge?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _compactCount(item.soldCount),
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.68),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.currency,
    required this.subtotal,
    required this.hasSelection,
    required this.allSelected,
    required this.onCheckout,
    required this.useNovaUi,
  });

  final String currency;
  final double subtotal;
  final bool hasSelection;
  final bool allSelected;
  final VoidCallback? onCheckout;
  final bool useNovaUi;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xl, AppSpace.md),
      child: (useNovaUi
          ? NovaSurface(
              padding: AppInsets.cardTight,
              borderRadius: AppRadii.lg,
              child: _checkoutRow(context),
            )
          : Container(
              padding: AppInsets.cardTight,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.42),
                ),
              ),
              child: _checkoutRow(context),
            )),
    );
  }

  Widget _checkoutRow(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hasSelection && !allSelected
                    ? l10n.cartSelectedSubtotalLabel
                    : l10n.cartSubtotalLabel,
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
              SizedBox(height: AppSpace.xxs),
              Text(
                _formatMoney(currency, subtotal),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              Text(
                l10n.cartTaxesAndShippingNote,
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.6),
                  height: 1.15,
                ),
              ),
              if (!hasSelection) ...[
                SizedBox(height: AppSpace.xxs),
                Text(
                  l10n.cartSelectItemsToContinue,
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                    height: 1.15,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (useNovaUi)
          SizedBox(
            height: AppHitTargets.comfortable,
            child: NovaButton.primary(
              key: const Key('cartProceedToCheckoutCta'),
              onPressed: onCheckout,
              label: l10n.cartProceedToCheckout,
            ),
          )
        else
          SizedBox(
            height: AppHitTargets.comfortable,
            child: FilledButton(
              key: const Key('cartProceedToCheckoutCta'),
              onPressed: onCheckout,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                textStyle: tt.labelLarge,
                minimumSize: Size(64.w, AppHitTargets.comfortable),
              ),
              child: Text(l10n.cartProceedToCheckout),
            ),
          ),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    return Center(
      child: Padding(
        padding: AppInsets.state,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.32),
                ),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 34.r,
                color: cs.onSurface.withValues(alpha: 0.66),
              ),
            ),
            SizedBox(height: AppSpace.md),
            Text(
              l10n.cartEmptyTitle,
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpace.xs),
            Text(
              l10n.cartEmptySubtitle1,
              style: tt.bodyMedium?.copyWith(height: 1.3),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpace.xs),
            Text(
              l10n.cartEmptySubtitle2,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.75),
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpace.lg),
            SizedBox(
              height: AppHitTargets.comfortable,
              child: FilledButton(
                onPressed: () => context.go(AppRoutes.home),
                child: Text(l10n.cartContinueShopping),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
