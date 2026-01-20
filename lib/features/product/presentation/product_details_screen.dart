import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/errors/app_error_mapper.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/app_cached_network_image.dart';
import '../../cart/presentation/cart_viewmodel.dart';
import '../../wishlist/presentation/wishlist_viewmodel.dart';
import 'product_details_viewmodel.dart';

class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final String? productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productDetailsViewModelProvider(productId));
    final isSavedForProduct = productId == null
        ? false
        : ref.watch(
            wishlistIdsProvider.select((ids) => ids.contains(productId!)),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          state.when(
            loading: () => const SizedBox.shrink(),
            notFound: () => const SizedBox.shrink(),
            error: (_) => const SizedBox.shrink(),
            data: (product, _, __) {
              return IconButton(
                tooltip: isSavedForProduct
                    ? 'Remove from wishlist'
                    : 'Save to wishlist',
                onPressed: () => ref
                    .read(wishlistViewModelProvider.notifier)
                    .toggle(product.id),
                icon: Icon(
                  isSavedForProduct ? Icons.favorite : Icons.favorite_border,
                  color: isSavedForProduct
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: state.when(
        loading: () => const _DetailsSkeleton(),
        notFound: () => const _NotFoundState(),
        error: (e) {
          final msg = mapAppError(e);
          return AppErrorState(
            title: msg.title,
            subtitle: msg.subtitle,
            actionText: 'Retry',
            onAction: () =>
                ref.invalidate(productDetailsViewModelProvider(productId)),
          );
        },
        data: (product, selectedColor, selectedSize) {
          final canAdd = selectedColor != null && selectedSize != null;
          final inStock = product.variants.where((v) => v.stock > 0).toList();
          final dpr = ScreenUtil().pixelRatio ?? 1.0;
          final imageWidth = 1.sw - 32.w;
          final memCacheWidth = (imageWidth * dpr).round();
          final memCacheHeight = ((imageWidth * (12 / 16)) * dpr).round();

          final availableColors =
              (inStock
                      .where(
                        (v) =>
                            selectedSize == null ||
                            v.size.trim() == selectedSize.trim(),
                      )
                      .map((v) => v.color)
                      .where((c) => c.trim().isNotEmpty)
                      .toSet()
                    ..remove(''))
                  .toList(growable: true)
                ..sort();

          final availableSizes =
              (inStock
                      .where(
                        (v) =>
                            selectedColor == null ||
                            v.color.trim() == selectedColor.trim(),
                      )
                      .map((v) => v.size)
                      .where((s) => s.trim().isNotEmpty)
                      .toSet()
                    ..remove(''))
                  .toList(growable: true)
                ..sort();
          return ListView(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: AspectRatio(
                  aspectRatio: 16 / 12,
                  child: AppCachedNetworkImage(
                    url: product.imageUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: memCacheWidth,
                    memCacheHeight: memCacheHeight,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                product.brand,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                product.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                '${product.currency} ${product.price.toStringAsFixed(0)}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 14.h),
              Text(
                product.description.trim().isEmpty
                    ? 'No description available.'
                    : product.description,
              ),
              SizedBox(height: 18.h),
              if (inStock.isEmpty) ...[
                Text(
                  'Out of stock',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 10.h),
              ],
              _VariantPicker(
                title: 'Color',
                options: availableColors,
                value: selectedColor,
                onSelected: (v) => ref
                    .read(productDetailsViewModelProvider(productId).notifier)
                    .selectColor(v),
              ),
              SizedBox(height: 14.h),
              _VariantPicker(
                title: 'Size',
                options: availableSizes,
                value: selectedSize,
                onSelected: (v) => ref
                    .read(productDetailsViewModelProvider(productId).notifier)
                    .selectSize(v),
              ),
              if (!canAdd && inStock.isNotEmpty) ...[
                SizedBox(height: 10.h),
                Text(
                  'Select a color and size to add to cart.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              SizedBox(height: 18.h),
              FilledButton(
                onPressed: canAdd
                    ? () {
                        ref
                            .read(cartViewModelProvider.notifier)
                            .add(
                              product: product,
                              selectedColor: selectedColor,
                              selectedSize: selectedSize,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to cart')),
                        );
                      }
                    : null,
                child: const Text('Add to cart'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _VariantPicker extends StatelessWidget {
  const _VariantPicker({
    required this.title,
    required this.options,
    required this.value,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final String? value;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: options
              .map((o) {
                final selected = o == value;
                return ChoiceChip(
                  label: Text(o),
                  selected: selected,
                  onSelected: (_) => onSelected(o),
                );
              })
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _DetailsSkeleton extends StatelessWidget {
  const _DetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
      children: [
        Container(
          height: 260.h,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
        SizedBox(height: 14.h),
        Container(
          height: 20.h,
          width: 120.w,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          height: 26.h,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ],
    );
  }
}

class _NotFoundState extends StatelessWidget {
  const _NotFoundState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Text(
          'Product not found',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
