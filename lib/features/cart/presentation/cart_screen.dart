import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_env.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/widgets/app_cached_network_image.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/nova_button.dart';
import '../../../core/widgets/nova_surface.dart';
import '../../../core/config/auth_providers.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/recommended_item.dart';
import 'cart_viewmodel.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useNovaUi = AppEnv.enableNovaUi && AppEnv.enableNovaUiCart;
    final cartAsync = ref.watch(cartViewModelProvider);
    final items = cartAsync.valueOrNull ?? const <CartItem>[];
    final vm = ref.read(cartViewModelProvider.notifier);
    final selectedIds = ref.watch(selectedCartItemIdsProvider);
    final selectionVm = ref.read(selectedCartItemIdsProvider.notifier);
    final currentUid = ref.watch(currentUidProvider);
    final recommended = ref.watch(recommendedItemsProvider);
    final selectedFilter = ref.watch(recommendedFilterProvider);
    final currency = items.isNotEmpty ? items.first.product.currency : 'USD';
    final dpr = ScreenUtil().pixelRatio ?? 1.0;
    final thumbSize = 44.w;
    final memThumb = (thumbSize * dpr).round();
    final selectedSubtotal = items
        .where((item) => selectedIds.contains(item.product.id))
        .fold<double>(0, (sum, item) => sum + item.total);
    final hasSelection = selectedIds.isNotEmpty;
    final allSelected = items.isNotEmpty && selectedIds.length == items.length;
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
        );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Cart', style: titleStyle),
        actions: [
          TextButton(
            onPressed: items.isEmpty
                ? null
                : () {
                    if (allSelected) {
                      selectionVm.selectAll(const <String>[]);
                    } else {
                      selectionVm
                          .selectAll(items.map((item) => item.product.id));
                    }
                  },
            child: Text(
              allSelected ? 'Deselect all' : 'Select all',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
      body: cartAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorState(
          title: 'Could not load your cart',
          subtitle: e.toString(),
          actionText: 'Retry',
          onAction: () => vm.refresh(),
        ),
        data: (_) {
          if (items.isEmpty) {
            return const _EmptyCart();
          }

          return ListView(
            padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 12.h),
            children: [
              if (currentUid == null)
                _InfoBanner(
                  icon: Icons.sync,
                  message:
                      'Sign in to sync this cart across devices. Until then, it stays on this device.',
                ),
              _SelectionInfoBanner(
                allSelected: allSelected,
                hasSelection: hasSelection,
              ),
              for (int index = 0; index < items.length; index++) ...[
                _CartItemRow(
                  item: items[index],
                  index: index,
                  useNovaUi: useNovaUi,
                  selected: selectedIds.contains(items[index].product.id),
                  thumbSize: thumbSize,
                  memThumb: memThumb,
                  onToggleSelected: () =>
                      selectionVm.toggle(items[index].product.id),
                  onDecrease: () =>
                      vm.updateQuantity(index, items[index].quantity - 1),
                  onIncrease: () =>
                      vm.updateQuantity(index, items[index].quantity + 1),
                  onRemove: () => vm.removeAt(index),
                ),
                if (index != items.length - 1) SizedBox(height: 4.h),
              ],
              SizedBox(height: 12.h),
              Divider(color: Theme.of(context).colorScheme.outlineVariant),
              SizedBox(height: 12.h),
              Text(
                'You might like',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Optional add-ons. Tap to view details.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.72),
                    ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: selectedFilter == RecommendedFilter.all,
                    onTap: () =>
                        ref.read(recommendedFilterProvider.notifier).state =
                            RecommendedFilter.all,
                  ),
                  _FilterChip(
                    label: 'Hot Deals',
                    selected: selectedFilter == RecommendedFilter.hotDeals,
                    onTap: () =>
                        ref.read(recommendedFilterProvider.notifier).state =
                            RecommendedFilter.hotDeals,
                  ),
                  _FilterChip(
                    label: 'Frequent Favorites',
                    selected: selectedFilter ==
                        RecommendedFilter.frequentFavorites,
                    onTap: () =>
                        ref.read(recommendedFilterProvider.notifier).state =
                            RecommendedFilter.frequentFavorites,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              GridView.builder(
                itemCount: recommended.length.clamp(0, 4),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8.h,
                  crossAxisSpacing: 8.w,
                  childAspectRatio: 0.86,
                ),
                itemBuilder: (context, index) {
                  final item = recommended[index];
                  return GestureDetector(
                    onTap: () =>
                        context.push('${AppRoutes.product}?id=${item.id}'),
                    child: _RecommendedCard(item: item),
                  );
                },
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: cartAsync.when(
        loading: () => null,
        error: (_, __) => null,
        data: (_) => items.isEmpty
            ? null
            : SafeArea(
                top: false,
                child: _CheckoutBar(
                  currency: currency,
                  subtotal: selectedSubtotal,
                  hasSelection: hasSelection,
                  allSelected: allSelected,
                  onCheckout: hasSelection
                      ? () => context.push(AppRoutes.checkout)
                      : null,
                  useNovaUi: useNovaUi,
                ),
              ),
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
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.onSurface.withValues(alpha: 0.75), size: 20.r),
          SizedBox(width: 10.w),
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

class _SelectionInfoBanner extends StatelessWidget {
  const _SelectionInfoBanner({
    required this.allSelected,
    required this.hasSelection,
  });

  final bool allSelected;
  final bool hasSelection;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final message = allSelected
        ? 'All items are selected for checkout. Uncheck items to keep them in your bag.'
        : hasSelection
            ? 'Checkout will include selected items only. Unselected items stay in your bag.'
            : 'Select items to continue to checkout.';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.checklist,
            color: cs.onSurface.withValues(alpha: 0.75),
            size: 20.r,
          ),
          SizedBox(width: 10.w),
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

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({
    required this.item,
    required this.index,
    required this.useNovaUi,
    required this.selected,
    required this.thumbSize,
    required this.memThumb,
    required this.onToggleSelected,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  final CartItem item;
  final int index;
  final bool useNovaUi;
  final bool selected;
  final double thumbSize;
  final int memThumb;
  final VoidCallback onToggleSelected;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final row = Padding(
      padding: EdgeInsets.all(6.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onToggleSelected,
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
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
      return NovaSurface(
        key: ValueKey(item.product.id),
        padding: EdgeInsets.zero,
        child: row,
      );
    }

    return Card(key: ValueKey(item.product.id), child: row);
  }
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
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected
                ? cs.primary
                : cs.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? Colors.white : cs.onSurface,
                fontWeight: FontWeight.w700,
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
    final cs = Theme.of(context).colorScheme;
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final radius = BorderRadius.circular(14.r);
    final memWidth = (160.w * dpr).round();
    final memHeight = (200.h * dpr).round();
    final parts = item.price.toStringAsFixed(2).split('.');
    final dollars = parts.first;
    final cents = parts.length > 1 ? '.${parts[1]}' : '.00';

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
        color: cs.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
            child: AppCachedNetworkImage(
              url: item.imageUrl,
              height: 102.h,
              width: double.infinity,
              fit: BoxFit.cover,
              memCacheWidth: memWidth,
              memCacheHeight: memHeight,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 6.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '\$$dollars',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          TextSpan(
                            text: cents,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      child: (useNovaUi
          ? NovaSurface(
              padding: EdgeInsets.all(8.r),
              child: _checkoutRow(context),
            )
          : Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: _checkoutRow(context),
            )),
    );
  }

  Widget _checkoutRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                allSelected ? 'Subtotal' : 'Selected subtotal',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
              ),
              SizedBox(height: 2.h),
              Text(
                '${currency.toUpperCase()} ${subtotal.toStringAsFixed(0)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              Text(
                'Taxes and shipping are calculated at checkout.',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
              if (!hasSelection) ...[
                SizedBox(height: 4.h),
                Text(
                  'Select items to continue',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              ],
            ],
          ),
        ),
        if (useNovaUi)
          SizedBox(
            height: 34.h,
            child: NovaButton.primary(
              onPressed: onCheckout,
              label: 'Proceed to checkout',
            ),
          )
        else
          SizedBox(
            height: 40.h,
            child: FilledButton(
              onPressed: onCheckout,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                textStyle: Theme.of(context).textTheme.labelLarge,
                minimumSize: Size(64.w, 40.h),
              ),
              child: const Text('Proceed to checkout'),
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
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 48.r,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            SizedBox(height: 10.h),
            Text(
              'Your cart is empty',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              'Add items you want to buy, then review them here before checkout.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              'Add items from any product page, then come back here to review and checkout.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.75),
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            FilledButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Continue shopping'),
            ),
          ],
        ),
      ),
    );
  }
}
