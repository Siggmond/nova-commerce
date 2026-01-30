import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_env.dart';
import '../../../core/config/app_routes.dart';
import '../../../core/errors/app_error_mapper.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/app_cached_network_image.dart';
import '../../../core/widgets/nova_app_bar.dart';
import '../../../core/widgets/nova_button.dart';
import '../../../core/widgets/nova_chip.dart';
import '../../../core/widgets/nova_section_header.dart';
import '../../../core/widgets/nova_surface.dart';
import '../../cart/presentation/cart_viewmodel.dart';
import '../../wishlist/presentation/wishlist_viewmodel.dart';
import 'product_details_viewmodel.dart';

class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final String? productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useNovaUi = AppEnv.enableNovaUi && AppEnv.enableNovaUiProductDetails;
    final state = ref.watch(productDetailsViewModelProvider(productId));
    final isSavedForProduct = productId == null
        ? false
        : ref.watch(
            wishlistIdsProvider.select((ids) => ids.contains(productId!)),
          );

    return Scaffold(
      appBar: useNovaUi
          ? NovaAppBar(
              titleText: state.when(
                loading: () => 'Item',
                notFound: () => 'Item',
                error: (_) => 'Item',
                data: (data) {
                  final title = data.product.brand.trim();
                  return title.isEmpty ? 'Item' : title;
                },
              ),
              actions: [
                state.when(
                  loading: () => const SizedBox.shrink(),
                  notFound: () => const SizedBox.shrink(),
                  error: (_) => const SizedBox.shrink(),
                  data: (data) {
                    final canClear =
                        (data.selectedColor != null &&
                            data.selectedColor!.trim().isNotEmpty) ||
                        (data.selectedSize != null &&
                            data.selectedSize!.trim().isNotEmpty);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Clear selection',
                          onPressed: canClear
                              ? () => ref
                                    .read(
                                      productDetailsViewModelProvider(
                                        productId,
                                      ).notifier,
                                    )
                                    .clearSelection()
                              : null,
                          icon: const Icon(Icons.clear),
                        ),
                        IconButton(
                          tooltip: isSavedForProduct
                              ? 'Remove from wishlist'
                              : 'Save to wishlist',
                          onPressed: () => ref
                              .read(wishlistViewModelProvider.notifier)
                              .toggle(data.product.id),
                          icon: Icon(
                            isSavedForProduct
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isSavedForProduct
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            )
          : AppBar(
              title: Text(
                state.when(
                  loading: () => 'Item',
                  notFound: () => 'Item',
                  error: (_) => 'Item',
                  data: (data) {
                    final title = data.product.brand.trim();
                    return title.isEmpty ? 'Item' : title;
                  },
                ),
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                state.when(
                  loading: () => const SizedBox.shrink(),
                  notFound: () => const SizedBox.shrink(),
                  error: (_) => const SizedBox.shrink(),
                  data: (data) {
                    final canClear =
                        (data.selectedColor != null &&
                            data.selectedColor!.trim().isNotEmpty) ||
                        (data.selectedSize != null &&
                            data.selectedSize!.trim().isNotEmpty);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Clear selection',
                          onPressed: canClear
                              ? () => ref
                                    .read(
                                      productDetailsViewModelProvider(
                                        productId,
                                      ).notifier,
                                    )
                                    .clearSelection()
                              : null,
                          icon: const Icon(Icons.clear),
                        ),
                        IconButton(
                          tooltip: isSavedForProduct
                              ? 'Remove from wishlist'
                              : 'Save to wishlist',
                          onPressed: () => ref
                              .read(wishlistViewModelProvider.notifier)
                              .toggle(data.product.id),
                          icon: Icon(
                            isSavedForProduct
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isSavedForProduct
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 8),
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
        data: (data) {
          final product = data.product;
          final selectedColor = data.selectedColor;
          final selectedSize = data.selectedSize;
          final inStock = data.inStockVariants;
          final dpr = ScreenUtil().pixelRatio ?? 1.0;
          final imageWidth = 1.sw - 32.w;
          final memCacheWidth = (imageWidth * dpr).round();
          final memCacheHeight = ((imageWidth * (12 / 16)) * dpr).round();

          final images = _normalizeImageUrls(product.imageUrls);
          final priceText = _formatPrice(product.currency, product.price);

          final availableColors = data.availableColors;
          final availableSizes = data.availableSizes;

          final listBottomPadding = 128.h;

          if (useNovaUi) {
            return ListView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, listBottomPadding),
              children: [
                _ProductImagePager(
                  imageUrls: images,
                  borderRadius: BorderRadius.circular(20.r),
                  memCacheWidth: memCacheWidth,
                  memCacheHeight: memCacheHeight,
                ),
                SizedBox(height: 16.h),
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
                SizedBox(height: 12.h),
                Text(
                  priceText,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 16.h),
                NovaSurface(
                  padding: EdgeInsets.all(16.r),
                  child: Text(
                    product.description.trim().isEmpty
                        ? 'No description available.'
                        : product.description,
                  ),
                ),
                SizedBox(height: 16.h),
                if (inStock.isEmpty)
                  NovaSurface(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Out of stock',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'This item is currently unavailable in any variant.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.72),
                              ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  NovaSurface(
                    padding: EdgeInsets.all(16.r),
                    child: _NovaVariantPicker(
                      title: 'Color',
                      options: availableColors,
                      disabled: data.disabledColors,
                      value: selectedColor,
                      onSelected: (v) => ref
                          .read(
                            productDetailsViewModelProvider(productId).notifier,
                          )
                          .selectColor(v),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  NovaSurface(
                    padding: EdgeInsets.all(16.r),
                    child: _NovaVariantPicker(
                      title: 'Size',
                      options: availableSizes,
                      disabled: data.disabledSizes,
                      value: selectedSize,
                      onSelected: (v) => ref
                          .read(
                            productDetailsViewModelProvider(productId).notifier,
                          )
                          .selectSize(v),
                    ),
                  ),
                ],
              ],
            );
          }

          return ListView(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, listBottomPadding),
            children: [
              _ProductImagePager(
                imageUrls: images,
                borderRadius: BorderRadius.circular(20.r),
                memCacheWidth: memCacheWidth,
                memCacheHeight: memCacheHeight,
              ),
              SizedBox(height: 16.h),
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
              SizedBox(height: 12.h),
              Text(
                priceText,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 16.h),
              Text(
                product.description.trim().isEmpty
                    ? 'No description available.'
                    : product.description,
              ),
              SizedBox(height: 16.h),
              if (inStock.isEmpty)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Out of stock',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'This item is currently unavailable in any variant.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.72),
                              ),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                _VariantPicker(
                  title: 'Color',
                  options: availableColors,
                  disabled: data.disabledColors,
                  value: selectedColor,
                  onSelected: (v) => ref
                      .read(productDetailsViewModelProvider(productId).notifier)
                      .selectColor(v),
                ),
                SizedBox(height: 16.h),
                _VariantPicker(
                  title: 'Size',
                  options: availableSizes,
                  disabled: data.disabledSizes,
                  value: selectedSize,
                  onSelected: (v) => ref
                      .read(productDetailsViewModelProvider(productId).notifier)
                      .selectSize(v),
                ),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: state.when(
        loading: () => null,
        notFound: () => null,
        error: (_) => null,
        data: (data) {
          final product = data.product;
          final inStock = data.inStockVariants;
          final selectedColor = data.selectedColor;
          final selectedSize = data.selectedSize;
          final canAdd = data.canAdd;
          bool cartNavInFlight = false;
          return SafeArea(
            top: false,
            child: _AddToCartBar(
              useNovaUi: useNovaUi,
              enabled: canAdd,
              inStock: inStock.isNotEmpty,
              selectedColor: selectedColor,
              selectedSize: selectedSize,
              onAdd: canAdd
                  ? () {
                      ref
                          .read(cartViewModelProvider.notifier)
                          .add(
                            product: product,
                            selectedColor: selectedColor!,
                            selectedSize: selectedSize!,
                          );
                      final messenger = ScaffoldMessenger.of(context);
                      messenger.hideCurrentSnackBar();
                      late final ScaffoldFeatureController<
                        SnackBar,
                        SnackBarClosedReason
                      >
                      controller;
                      controller = messenger.showSnackBar(
                        SnackBar(
                          content: const Text('Added to cart'),
                          action: SnackBarAction(
                            label: 'View cart',
                            onPressed: () async {
                              if (cartNavInFlight) return;
                              cartNavInFlight = true;
                              if (!context.mounted) {
                                cartNavInFlight = false;
                                return;
                              }

                              controller.close();
                              await controller.closed;

                              if (!context.mounted) {
                                cartNavInFlight = false;
                                return;
                              }
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!context.mounted) {
                                  cartNavInFlight = false;
                                  return;
                                }
                                context.go(AppRoutes.cart);
                                cartNavInFlight = false;
                              });
                            },
                          ),
                        ),
                      );
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }
}

class _ProductImagePager extends StatefulWidget {
  const _ProductImagePager({
    required this.imageUrls,
    required this.borderRadius,
    required this.memCacheWidth,
    required this.memCacheHeight,
  });

  final List<String> imageUrls;
  final BorderRadius borderRadius;
  final int memCacheWidth;
  final int memCacheHeight;

  @override
  State<_ProductImagePager> createState() => _ProductImagePagerState();
}

class _ProductImagePagerState extends State<_ProductImagePager> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls.isEmpty
        ? const <String>['']
        : widget.imageUrls;
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 12,
            child: PageView.builder(
              controller: _controller,
              itemCount: urls.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                return AppCachedNetworkImage(
                  url: urls[i],
                  fit: BoxFit.cover,
                  memCacheWidth: widget.memCacheWidth,
                  memCacheHeight: widget.memCacheHeight,
                  backgroundColor: cs.surfaceContainerHighest,
                );
              },
            ),
          ),
          if (urls.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(urls.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 14 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({
    required this.useNovaUi,
    required this.enabled,
    required this.inStock,
    required this.selectedColor,
    required this.selectedSize,
    required this.onAdd,
  });

  final bool useNovaUi;
  final bool enabled;
  final bool inStock;
  final String? selectedColor;
  final String? selectedSize;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final summary = inStock
        ? 'Color: ${selectedColor?.trim().isNotEmpty == true ? selectedColor : '—'} • Size: ${selectedSize?.trim().isNotEmpty == true ? selectedSize : '—'}'
        : 'Out of stock';

    final helper = !inStock
        ? 'This item is currently unavailable.'
        : (enabled ? null : 'Select a color and size to add to cart.');

    final label = !inStock ? 'Out of stock' : 'Add to cart';

    final content = Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                summary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (helper != null) ...[
                SizedBox(height: 4.h),
                Text(
                  helper,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: 12.w),
        if (useNovaUi)
          SizedBox(
            height: 40.h,
            child: NovaButton.primary(
              onPressed: inStock ? onAdd : null,
              label: label,
            ),
          )
        else
          SizedBox(
            height: 44.h,
            child: FilledButton(
              onPressed: inStock ? onAdd : null,
              child: Text(label),
            ),
          ),
      ],
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: useNovaUi
          ? NovaSurface(padding: EdgeInsets.all(12.r), child: content)
          : Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: content,
            ),
    );
  }
}

class _NovaVariantPicker extends StatelessWidget {
  const _NovaVariantPicker({
    required this.title,
    required this.options,
    required this.disabled,
    required this.value,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final Set<String> disabled;
  final String? value;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NovaSectionHeader(title: title),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: options
              .map((o) {
                final selected = o == value;
                final isDisabled = disabled.contains(o) && !selected;
                return Opacity(
                  opacity: isDisabled ? 0.45 : 1.0,
                  child: NovaChip(
                    label: o,
                    selected: selected,
                    enabled: !isDisabled,
                    onSelected: (_) => onSelected(o),
                  ),
                );
              })
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _VariantPicker extends StatelessWidget {
  const _VariantPicker({
    required this.title,
    required this.options,
    required this.disabled,
    required this.value,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final Set<String> disabled;
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
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: options
              .map((o) {
                final selected = o == value;
                final isDisabled = disabled.contains(o) && !selected;
                return Opacity(
                  opacity: isDisabled ? 0.45 : 1.0,
                  child: ChoiceChip(
                    label: Text(o),
                    selected: selected,
                    onSelected: isDisabled ? null : (_) => onSelected(o),
                  ),
                );
              })
              .toList(growable: false),
        ),
      ],
    );
  }
}

String _formatPrice(String currency, double price) {
  final symbol = currency.trim();
  final hasCents = (price - price.truncateToDouble()).abs() > 0.00001;
  final formatted = hasCents
      ? price.toStringAsFixed(2)
      : price.toStringAsFixed(0);
  return '$symbol $formatted';
}

List<String> _normalizeImageUrls(List<String> urls) {
  final out = <String>[];
  for (final raw in urls) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) continue;
    if (trimmed.startsWith('//')) {
      out.add('https:$trimmed');
      continue;
    }
    out.add(trimmed);
  }
  if (out.isEmpty) return const <String>[];
  return out;
}

class _DetailsSkeleton extends StatelessWidget {
  const _DetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      children: [
        Container(
          height: 260.h,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          height: 20.h,
          width: 120.w,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        SizedBox(height: 12.h),
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
