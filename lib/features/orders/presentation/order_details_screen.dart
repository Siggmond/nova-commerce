import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_env.dart';
import '../../../core/config/providers.dart';
import '../../../core/errors/app_error_mapper.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/nova_app_bar.dart';
import '../../../core/widgets/nova_button.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/shimmer.dart';
import '../../cart/presentation/cart_viewmodel.dart';
import 'order_status_ui.dart';
import 'orders_controller.dart';

class OrderDetailsScreen extends ConsumerWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final useNovaUi = AppEnv.enableNovaUi;
    final state = ref.watch(orderDetailsControllerProvider(orderId));

    return Scaffold(
      appBar: useNovaUi
          ? NovaAppBar(titleText: 'Order details')
          : AppBar(title: const Text('Order details')),
      body: state.when(
        loading: () => const _OrderDetailsSkeleton(),
        error: (e, _) {
          final msg = mapAppError(e);
          final isNotFound = e is StateError && e.message.contains('not found');
          return AppErrorState(
            title: msg.title,
            subtitle: msg.subtitle,
            actionText: isNotFound ? 'Back' : 'Retry',
            onAction: () {
              if (isNotFound) {
                Navigator.of(context).maybePop();
                return;
              }
              ref.read(orderDetailsControllerProvider(orderId).notifier)
                  .refresh();
            },
          );
        },
        data: (order) {
          final shortId = order.id.isNotEmpty
              ? order.id.substring(0, order.id.length.clamp(0, 8))
              : '--';
          final statusLabel = orderStatusLabel(order.status, order.statusRaw);
          final statusIcon = orderStatusIcon(order.status);
          return ListView(
            padding: AppInsets.screen,
            children: [
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Summary',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: AppSpace.sm),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Order ID #$shortId',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: order.id),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Order ID copied'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.copy_rounded),
                          tooltip: 'Copy order ID',
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpace.xs),
                    _Row(
                      left: 'Status',
                      right: statusLabel,
                      icon: statusIcon,
                    ),
                    SizedBox(height: AppSpace.xs),
                    _Row(
                      left: 'Total',
                      right:
                          '${order.currency.toUpperCase()} ${order.total.toStringAsFixed(0)}',
                    ),
                    if (order.createdAt != null) ...[
                      SizedBox(height: AppSpace.xs),
                      _Row(
                        left: 'Placed',
                        right: order.createdAt!.toLocal().toString(),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: AppSpace.sm),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shipping',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: AppSpace.sm),
                    Text(
                      '${order.shipping['fullName'] ?? ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: AppSpace.xxs),
                    Text(
                      '${order.shipping['address'] ?? ''}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                    SizedBox(height: AppSpace.xxs),
                    Text(
                      '${order.shipping['city'] ?? ''} ${order.shipping['country'] ?? ''}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpace.sm),
              SizedBox(
                width: double.infinity,
                child: useNovaUi
                    ? NovaButton.primary(
                        onPressed: () async {
                          final productRepo =
                              ref.read(productRepositoryProvider);
                          final cartVm =
                              ref.read(cartViewModelProvider.notifier);
                          final ids =
                              order.items.map((i) => i.productId).toSet();
                          if (ids.isEmpty) return;

                          final products =
                              await productRepo.getProductsByIds(ids);
                          final byId = {for (final p in products) p.id: p};
                          int added = 0;
                          for (final item in order.items) {
                            final product = byId[item.productId];
                            if (product == null) continue;
                            cartVm.add(
                              product: product,
                              selectedColor: item.selectedColor,
                              selectedSize: item.selectedSize,
                            );
                            added += 1;
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  added == 0
                                      ? 'Items are no longer available.'
                                      : 'Added $added item${added == 1 ? '' : 's'} to cart',
                                ),
                              ),
                            );
                          }
                        },
                        label: 'Reorder',
                      )
                    : FilledButton(
                        onPressed: () async {
                          final productRepo =
                              ref.read(productRepositoryProvider);
                          final cartVm =
                              ref.read(cartViewModelProvider.notifier);
                          final ids =
                              order.items.map((i) => i.productId).toSet();
                          if (ids.isEmpty) return;

                          final products =
                              await productRepo.getProductsByIds(ids);
                          final byId = {for (final p in products) p.id: p};
                          int added = 0;
                          for (final item in order.items) {
                            final product = byId[item.productId];
                            if (product == null) continue;
                            cartVm.add(
                              product: product,
                              selectedColor: item.selectedColor,
                              selectedSize: item.selectedSize,
                            );
                            added += 1;
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  added == 0
                                      ? 'Items are no longer available.'
                                      : 'Added $added item${added == 1 ? '' : 's'} to cart',
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('Reorder'),
                      ),
              ),
              SizedBox(height: AppSpace.sm),
              Text(
                'Items',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              SizedBox(height: AppSpace.sm),
              ...order.items.map(
                (i) => Padding(
                  padding: EdgeInsets.only(bottom: AppSpace.sm),
                  child: SectionCard(
                    padding: AppInsets.cardTight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          i.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        SizedBox(height: AppSpace.xs),
                        Text(
                          '${i.selectedColor} • ${i.selectedSize} • Qty ${i.quantity}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.75),
                              ),
                        ),
                        SizedBox(height: AppSpace.sm),
                        Text(
                          '${order.currency.toUpperCase()} ${i.total.toStringAsFixed(0)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.left, required this.right, this.icon});

  final String left;
  final String right;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(width: AppSpace.sm),
        if (icon != null) ...[
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: AppSpace.xs),
        ],
        Flexible(
          child: Text(
            right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _OrderDetailsSkeleton extends StatelessWidget {
  const _OrderDetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppInsets.screen,
      children: [
        Shimmer(child: SkeletonBox(height: 128, radius: AppRadii.lg)),
        SizedBox(height: AppSpace.sm),
        Shimmer(child: SkeletonBox(height: 120, radius: AppRadii.lg)),
        SizedBox(height: AppSpace.sm),
        Shimmer(child: SkeletonBox(height: 22, radius: AppRadii.sm)),
        SizedBox(height: AppSpace.sm),
        Shimmer(child: SkeletonBox(height: 96, radius: AppRadii.lg)),
        SizedBox(height: AppSpace.sm),
        Shimmer(child: SkeletonBox(height: 96, radius: AppRadii.lg)),
      ],
    );
  }
}
