import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/config/app_env.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/errors/app_error_mapper.dart';
import '../../../core/images/image_policy.dart';
import '../../../core/images/nova_image.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/nova_app_bar.dart';
import '../../../core/widgets/nova_button.dart';
import '../../../core/widgets/nova_surface.dart';
import 'package:nova_commerce/features/cart/cart.dart';
import 'package:nova_commerce/features/wishlist/wishlist.dart';
import 'package:nova_commerce/gen_l10n/app_localizations.dart';
import 'product_details_viewmodel.dart';

class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final String? productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final useNovaUi = AppEnv.enableNovaUi && AppEnv.enableNovaUiProductDetails;
    final state = ref.watch(productDetailsViewModelProvider(productId));
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: useNovaUi
          ? NovaAppBar(
              titleText: state.when(
                loading: () => t.productItemTitle,
                notFound: () => t.productItemTitle,
                error: (_) => t.productItemTitle,
                data: (data) {
                  final title = data.product.brand.trim();
                  return title.isEmpty ? t.productItemTitle : title;
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
                          tooltip: t.productClearSelectionTooltip,
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
                        Consumer(
                          builder: (context, ref, _) {
                            final id = data.product.id;
                            final isSavedForProduct = ref.watch(
                              wishlistIdsProvider.select(
                                (ids) => ids.contains(id),
                              ),
                            );
                            return IconButton(
                              tooltip: isSavedForProduct
                                  ? t.productRemoveFromWishlistTooltip
                                  : t.productSaveToWishlistTooltip,
                              onPressed: () => ref
                                  .read(wishlistViewModelProvider.notifier)
                                  .toggle(id),
                              icon: Icon(
                                isSavedForProduct
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isSavedForProduct
                                    ? cs.primary
                                    : cs.onSurface.withValues(alpha: 0.8),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(width: 8.w),
              ],
            )
          : AppBar(
              title: Text(
                state.when(
                  loading: () => t.productItemTitle,
                  notFound: () => t.productItemTitle,
                  error: (_) => t.productItemTitle,
                  data: (data) {
                    final title = data.product.brand.trim();
                    return title.isEmpty ? t.productItemTitle : title;
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
                          tooltip: t.productClearSelectionTooltip,
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
                        Consumer(
                          builder: (context, ref, _) {
                            final id = data.product.id;
                            final isSavedForProduct = ref.watch(
                              wishlistIdsProvider.select(
                                (ids) => ids.contains(id),
                              ),
                            );
                            return IconButton(
                              tooltip: isSavedForProduct
                                  ? t.productRemoveFromWishlistTooltip
                                  : t.productSaveToWishlistTooltip,
                              onPressed: () => ref
                                  .read(wishlistViewModelProvider.notifier)
                                  .toggle(id),
                              icon: Icon(
                                isSavedForProduct
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isSavedForProduct
                                    ? cs.primary
                                    : cs.onSurface.withValues(alpha: 0.8),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(width: 8.w),
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
            actionText: t.commonRetry,
            onAction: () =>
                ref.invalidate(productDetailsViewModelProvider(productId)),
          );
        },
        data: (data) {
          final product = data.product;
          final selectedColor = data.selectedColor;
          final selectedSize = data.selectedSize;
          final inStock = data.inStockVariants;
          final hasStock = inStock.isNotEmpty;

          final images = _normalizeImageUrls(product.imageUrls);
          final priceText = _formatPrice(product.currency, product.price);

          final availableColors = data.availableColors;
          final availableSizes = data.availableSizes;

          final listBottomPadding = 148.h;

          return ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpace.xl,
              useNovaUi ? AppSpace.xl : AppSpace.md,
              AppSpace.xl,
              listBottomPadding,
            ),
            children: [
              RepaintBoundary(
                child: _ProductImagePager(
                  imageUrls: images,
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  topLeftLabel: product.brand.trim().isEmpty
                      ? null
                      : product.brand,
                  topRightLabel: hasStock ? 'In stock' : 'Unavailable',
                ),
              ),
              SizedBox(height: AppSpace.lg),
              RepaintBoundary(
                child: _ProductHeadlineCard(
                  useNovaUi: useNovaUi,
                  brand: product.brand,
                  title: product.title,
                  priceText: priceText,
                  hasStock: hasStock,
                ),
              ),
              SizedBox(height: AppSpace.md),
              RepaintBoundary(
                child: _ProductDescriptionCard(
                  useNovaUi: useNovaUi,
                  description: product.description,
                ),
              ),
              SizedBox(height: AppSpace.md),
              if (!hasStock)
                RepaintBoundary(child: _StockNoticeCard(useNovaUi: useNovaUi))
              else ...[
                RepaintBoundary(
                  child: _DetailsSurface(
                    useNovaUi: useNovaUi,
                    padding: AppInsets.card,
                    child: useNovaUi
                        ? _NovaVariantPicker(
                            title: 'Color',
                            options: availableColors,
                            disabled: data.disabledColors,
                            value: selectedColor,
                            onSelected: (v) => ref
                                .read(
                                  productDetailsViewModelProvider(
                                    productId,
                                  ).notifier,
                                )
                                .selectColor(v),
                          )
                        : _VariantPicker(
                            title: 'Color',
                            options: availableColors,
                            disabled: data.disabledColors,
                            value: selectedColor,
                            onSelected: (v) => ref
                                .read(
                                  productDetailsViewModelProvider(
                                    productId,
                                  ).notifier,
                                )
                                .selectColor(v),
                          ),
                  ),
                ),
                SizedBox(height: AppSpace.md),
                RepaintBoundary(
                  child: _DetailsSurface(
                    useNovaUi: useNovaUi,
                    padding: AppInsets.card,
                    child: useNovaUi
                        ? _NovaVariantPicker(
                            title: 'Size',
                            options: availableSizes,
                            disabled: data.disabledSizes,
                            value: selectedSize,
                            onSelected: (v) => ref
                                .read(
                                  productDetailsViewModelProvider(
                                    productId,
                                  ).notifier,
                                )
                                .selectSize(v),
                          )
                        : _VariantPicker(
                            title: 'Size',
                            options: availableSizes,
                            disabled: data.disabledSizes,
                            value: selectedSize,
                            onSelected: (v) => ref
                                .read(
                                  productDetailsViewModelProvider(
                                    productId,
                                  ).notifier,
                                )
                                .selectSize(v),
                          ),
                  ),
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
            child: RepaintBoundary(
              child: _PremiumAddToCartBar(
                useNovaUi: useNovaUi,
                enabled: canAdd,
                inStock: inStock.isNotEmpty,
                priceText: _formatPrice(product.currency, product.price),
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
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.fromLTRB(
                              AppSpace.xl,
                              0,
                              AppSpace.xl,
                              92.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadii.lg),
                            ),
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
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
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
    this.topLeftLabel,
    this.topRightLabel,
  });

  final List<String> imageUrls;
  final BorderRadius borderRadius;
  final String? topLeftLabel;
  final String? topRightLabel;

  @override
  State<_ProductImagePager> createState() => _ProductImagePagerState();
}

class _ProductImagePagerState extends State<_ProductImagePager> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    if (NovaImagePolicy.clearLargeDetailsImagesOnPop) {
      unawaited(
        NovaImagePolicy.maybeEvictDetailsImagesOnPop(urls: widget.imageUrls),
      );
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls.isEmpty
        ? const <String>['']
        : widget.imageUrls;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.38)),
        boxShadow: AppShadows.sm(color: Colors.black.withValues(alpha: 0.10)),
      ),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 12,
            child: PageView.builder(
              controller: _controller,
              itemCount: urls.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                return NovaImage(
                  url: urls[i],
                  route: NovaImageRoute.productDetails,
                  fit: BoxFit.cover,
                  backgroundColor: cs.surfaceContainerHighest,
                );
              },
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.10),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.26),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if ((widget.topLeftLabel ?? '').trim().isNotEmpty ||
              (widget.topRightLabel ?? '').trim().isNotEmpty)
            Positioned(
              left: AppSpace.md,
              right: AppSpace.md,
              top: AppSpace.md,
              child: Row(
                children: [
                  if ((widget.topLeftLabel ?? '').trim().isNotEmpty)
                    Flexible(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: _ProductImageTag(
                          label: widget.topLeftLabel!,
                          alignStart: true,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if ((widget.topRightLabel ?? '').trim().isNotEmpty)
                    Flexible(
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: _ProductImageTag(
                          label: widget.topRightLabel!,
                          alignStart: false,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          if (urls.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpace.md,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpace.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(urls.length, (i) {
                          final active = i == _index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: EdgeInsets.symmetric(
                              horizontal: AppSpace.xxs,
                            ),
                            width: active ? 14.w : 7.w,
                            height: 7.w,
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(99.r),
                            ),
                          );
                        }),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpace.sm,
                        vertical: AppSpace.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.42),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Text(
                        '${_index + 1}/${urls.length}',
                        style: tt.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductImageTag extends StatelessWidget {
  const _ProductImageTag({required this.label, required this.alignStart});

  final String label;
  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 180.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignStart ? TextAlign.start : TextAlign.end,
          style: tt.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
      ),
    );
  }
}

class _DetailsSurface extends StatelessWidget {
  const _DetailsSurface({
    required this.useNovaUi,
    required this.child,
    this.padding,
  });

  final bool useNovaUi;
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final content = Padding(padding: padding ?? AppInsets.card, child: child);

    if (useNovaUi) {
      return NovaSurface(
        padding: EdgeInsets.zero,
        borderRadius: AppRadii.lg,
        child: content,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.36)),
        boxShadow: AppShadows.sm(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: content,
    );
  }
}

class _ProductHeadlineCard extends StatelessWidget {
  const _ProductHeadlineCard({
    required this.useNovaUi,
    required this.brand,
    required this.title,
    required this.priceText,
    required this.hasStock,
  });

  final bool useNovaUi;
  final String brand;
  final String title;
  final String priceText;
  final bool hasStock;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return _DetailsSurface(
      useNovaUi: useNovaUi,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (brand.trim().isNotEmpty)
            Text(
              brand,
              style: tt.labelLarge?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.66),
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
          if (brand.trim().isNotEmpty) SizedBox(height: AppSpace.xxs),
          Text(
            title,
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.14,
            ),
          ),
          SizedBox(height: AppSpace.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  priceText,
                  style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
              ),
              _OptionBadge(
                label: hasStock ? 'In stock' : 'Out of stock',
                emphasized: hasStock,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductDescriptionCard extends StatelessWidget {
  const _ProductDescriptionCard({
    required this.useNovaUi,
    required this.description,
  });

  final bool useNovaUi;
  final String description;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final normalized = description.trim().isEmpty
        ? 'No description available.'
        : description.trim();

    return _DetailsSurface(
      useNovaUi: useNovaUi,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notes_rounded,
                size: 18.r,
                color: cs.onSurface.withValues(alpha: 0.8),
              ),
              SizedBox(width: AppSpace.sm),
              Text(
                'Details',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          SizedBox(height: AppSpace.sm),
          Text(
            normalized,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.82),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _StockNoticeCard extends StatelessWidget {
  const _StockNoticeCard({required this.useNovaUi});

  final bool useNovaUi;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return _DetailsSurface(
      useNovaUi: useNovaUi,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppHitTargets.min,
            height: AppHitTargets.min,
            decoration: BoxDecoration(
              color: cs.errorContainer.withValues(alpha: 0.50),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: cs.error.withValues(alpha: 0.18)),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 20.r,
              color: cs.error,
            ),
          ),
          SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Out of stock',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: AppSpace.xxs),
                Text(
                  'This item is currently unavailable in any variant.',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumAddToCartBar extends StatelessWidget {
  const _PremiumAddToCartBar({
    required this.useNovaUi,
    required this.enabled,
    required this.inStock,
    required this.priceText,
    required this.selectedColor,
    required this.selectedSize,
    required this.onAdd,
  });

  final bool useNovaUi;
  final bool enabled;
  final bool inStock;
  final String priceText;
  final String? selectedColor;
  final String? selectedSize;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final colorText = selectedColor?.trim().isNotEmpty == true
        ? selectedColor!.trim()
        : '-';
    final sizeText = selectedSize?.trim().isNotEmpty == true
        ? selectedSize!.trim()
        : '-';
    final helper = !inStock
        ? 'This item is currently unavailable.'
        : (enabled ? null : 'Select a color and size to add to cart.');
    final label = !inStock ? 'Out of stock' : 'Add to cart';

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpace.xl, 0, AppSpace.xl, AppSpace.md),
      child: _DetailsSurface(
        useNovaUi: useNovaUi,
        padding: EdgeInsets.all(AppSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    priceText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ),
                _OptionBadge(
                  label: inStock ? 'Ready' : 'Unavailable',
                  emphasized: inStock,
                ),
              ],
            ),
            SizedBox(height: AppSpace.sm),
            Row(
              children: [
                Expanded(
                  child: _OptionBadge(
                    label: 'Color: $colorText',
                    emphasized: selectedColor?.trim().isNotEmpty == true,
                  ),
                ),
                SizedBox(width: AppSpace.sm),
                Expanded(
                  child: _OptionBadge(
                    label: 'Size: $sizeText',
                    emphasized: selectedSize?.trim().isNotEmpty == true,
                  ),
                ),
              ],
            ),
            if (helper != null) ...[
              SizedBox(height: AppSpace.xs),
              Text(
                helper,
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.7),
                  height: 1.25,
                ),
              ),
            ],
            SizedBox(height: AppSpace.sm),
            if (useNovaUi)
              SizedBox(
                width: double.infinity,
                height: AppHitTargets.min,
                child: NovaButton.primary(
                  onPressed: inStock ? onAdd : null,
                  label: label,
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: AppHitTargets.min,
                child: FilledButton(
                  onPressed: inStock ? onAdd : null,
                  child: Text(label),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OptionBadge extends StatelessWidget {
  const _OptionBadge({required this.label, required this.emphasized});

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: emphasized
            ? cs.primary.withValues(alpha: 0.12)
            : cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: emphasized
              ? cs.primary.withValues(alpha: 0.42)
              : cs.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tt.labelSmall?.copyWith(
          color: emphasized ? cs.primary : cs.onSurface.withValues(alpha: 0.78),
          fontWeight: FontWeight.w800,
          height: 1.15,
        ),
      ),
    );
  }
}

class _VariantOptionChip extends StatelessWidget {
  const _VariantOptionChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final borderColor = selected
        ? cs.primary
        : enabled
        ? cs.outlineVariant.withValues(alpha: 0.50)
        : cs.outlineVariant.withValues(alpha: 0.34);
    final textColor = selected
        ? cs.onPrimary
        : enabled
        ? cs.onSurface
        : cs.onSurface.withValues(alpha: 0.46);

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          constraints: BoxConstraints(minHeight: AppHitTargets.min),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: selected
                ? cs.primary
                : enabled
                ? cs.surfaceContainerLow
                : cs.surfaceContainerHighest.withValues(alpha: 0.44),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: borderColor, width: selected ? 1.4 : 1),
            boxShadow: selected
                ? AppShadows.sm(color: cs.primary.withValues(alpha: 0.18))
                : null,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.labelLarge?.copyWith(
              color: textColor,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
              decoration: enabled ? null : TextDecoration.lineThrough,
              decorationColor: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({
    required this.useNovaUi,
    required this.enabled,
    required this.inStock,
    required this.priceText,
    required this.selectedColor,
    required this.selectedSize,
    required this.onAdd,
  });

  final bool useNovaUi;
  final bool enabled;
  final bool inStock;
  final String priceText;
  final String? selectedColor;
  final String? selectedSize;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

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
                '$priceText | $summary',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (helper != null) ...[
                SizedBox(height: 4.h),
                Text(
                  helper,
                  style: tt.bodySmall?.copyWith(
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final selectedLabel = value?.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const Spacer(),
            Container(
              constraints: BoxConstraints(maxWidth: 148.w),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpace.sm,
                vertical: AppSpace.xxs,
              ),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.34),
                ),
              ),
              child: Text(
                selectedLabel.isEmpty ? 'Not selected' : selectedLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.70),
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpace.sm),
        Wrap(
          spacing: AppSpace.sm,
          runSpacing: AppSpace.sm,
          children: options
              .map((o) {
                final selected = o == value;
                final isDisabled = disabled.contains(o) && !selected;
                return _VariantOptionChip(
                  label: o,
                  selected: selected,
                  enabled: !isDisabled,
                  onTap: () => onSelected(o),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final selectedLabel = value?.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const Spacer(),
            Container(
              constraints: BoxConstraints(maxWidth: 148.w),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpace.sm,
                vertical: AppSpace.xxs,
              ),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.34),
                ),
              ),
              child: Text(
                selectedLabel.isEmpty ? 'Not selected' : selectedLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.70),
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpace.sm),
        Wrap(
          spacing: AppSpace.sm,
          runSpacing: AppSpace.sm,
          children: options
              .map((o) {
                final selected = o == value;
                final isDisabled = disabled.contains(o) && !selected;
                return _VariantOptionChip(
                  label: o,
                  selected: selected,
                  enabled: !isDisabled,
                  onTap: () => onSelected(o),
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
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpace.xl,
        AppSpace.xl,
        AppSpace.xl,
        AppSpace.section,
      ),
      children: [
        Container(
          height: 260.h,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadii.xl),
          ),
        ),
        SizedBox(height: AppSpace.xl),
        Container(
          height: 20.h,
          width: 120.w,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
        SizedBox(height: AppSpace.md),
        Container(
          height: 26.h,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
        SizedBox(height: AppSpace.md),
        Container(
          height: 96.h,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
        ),
        SizedBox(height: AppSpace.md),
        Container(
          height: 116.h,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadii.lg),
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
    return const AppEmptyState(
      title: 'Product not found',
      subtitle: 'This product may no longer be available.',
      icon: Icons.inventory_2_outlined,
    );
  }
}
