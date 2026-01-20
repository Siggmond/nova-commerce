import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_routes.dart';
import '../../../core/widgets/app_cached_network_image.dart';
import 'cart_viewmodel.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartViewModelProvider);
    final vm = ref.read(cartViewModelProvider.notifier);
    final currency = items.isNotEmpty ? items.first.product.currency : 'USD';
    final dpr = ScreenUtil().pixelRatio ?? 1.0;
    final thumbSize = 80.w;
    final memThumb = (thumbSize * dpr).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: items.isEmpty
          ? const _EmptyCart()
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 120.h),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  key: ValueKey(item.product.id),
                  child: Padding(
                    padding: EdgeInsets.all(12.r),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppCachedNetworkImage(
                          url: item.product.imageUrl,
                          width: thumbSize,
                          height: thumbSize,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(12.r),
                          memCacheWidth: memThumb,
                          memCacheHeight: memThumb,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHigh,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                '${item.selectedColor} • ${item.selectedSize}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => vm.updateQuantity(
                                      index,
                                      item.quantity - 1,
                                    ),
                                    icon: Icon(Icons.remove_circle, size: 22.r),
                                  ),
                                  Text(
                                    item.quantity.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  IconButton(
                                    onPressed: () => vm.updateQuantity(
                                      index,
                                      item.quantity + 1,
                                    ),
                                    icon: Icon(Icons.add_circle, size: 22.r),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () => vm.removeAt(index),
                                    icon: Icon(Icons.close, size: 20.r),
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
              },
            ),
      bottomSheet: items.isEmpty
          ? null
          : _CheckoutBar(
              currency: currency,
              subtotal: vm.subtotal,
              onCheckout: () => context.push(AppRoutes.checkout),
            ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.currency,
    required this.subtotal,
    required this.onCheckout,
  });

  final String currency;
  final double subtotal;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Subtotal',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${currency.toUpperCase()} ${subtotal.toStringAsFixed(0)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Total',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${currency.toUpperCase()} ${subtotal.toStringAsFixed(0)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton(onPressed: onCheckout, child: const Text('Checkout')),
          ],
        ),
      ),
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
              'Add items you love. We will keep them saved here.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
