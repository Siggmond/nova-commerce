import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/variant.dart';
import '../../recently_viewed/presentation/recently_viewed_viewmodel.dart';

sealed class ProductDetailsState {
  const ProductDetailsState();

  const factory ProductDetailsState.loading() = ProductDetailsLoading;
  const factory ProductDetailsState.notFound() = ProductDetailsNotFound;
  const factory ProductDetailsState.data({
    required Product product,
    required String? selectedColor,
    required String? selectedSize,
  }) = ProductDetailsData;
  const factory ProductDetailsState.error(Object error) = ProductDetailsError;

  T when<T>({
    required T Function() loading,
    required T Function() notFound,
    required T Function(Object error) error,
    required T Function(ProductDetailsData data) data,
  }) {
    final s = this;
    if (s is ProductDetailsLoading) return loading();
    if (s is ProductDetailsNotFound) return notFound();
    if (s is ProductDetailsError) return error(s.error);
    return data(s as ProductDetailsData);
  }
}

class ProductDetailsLoading extends ProductDetailsState {
  const ProductDetailsLoading();
}

class ProductDetailsNotFound extends ProductDetailsState {
  const ProductDetailsNotFound();
}

class ProductDetailsData extends ProductDetailsState {
  const ProductDetailsData({
    required this.product,
    required this.selectedColor,
    required this.selectedSize,
  });

  final Product product;
  final String? selectedColor;
  final String? selectedSize;

  static const Object _unset = Object();

  ProductDetailsData copyWith({
    Object? selectedColor = _unset,
    Object? selectedSize = _unset,
  }) {
    return ProductDetailsData(
      product: product,
      selectedColor: selectedColor == _unset
          ? this.selectedColor
          : selectedColor as String?,
      selectedSize: selectedSize == _unset
          ? this.selectedSize
          : selectedSize as String?,
    );
  }

  List<Variant> get inStockVariants =>
      product.variants.where((v) => v.stock > 0).toList(growable: false);

  bool get canAdd => selectedVariant != null;

  Variant? get selectedVariant {
    final c = selectedColor?.trim();
    final s = selectedSize?.trim();
    if (c == null || c.isEmpty || s == null || s.isEmpty) return null;
    for (final v in inStockVariants) {
      if (v.color.trim() == c && v.size.trim() == s) return v;
    }
    return null;
  }

  List<String> get availableColors {
    final set = <String>{};
    for (final v in inStockVariants) {
      final c = v.color.trim();
      if (c.isNotEmpty) set.add(c);
    }
    final list = set.toList(growable: false);
    list.sort();
    return list;
  }

  Set<String> get disabledColors {
    final size = selectedSize?.trim();
    if (size == null || size.isEmpty) return const <String>{};

    final enabled = <String>{};
    for (final v in inStockVariants) {
      if (v.size.trim() != size) continue;
      final c = v.color.trim();
      if (c.isNotEmpty) enabled.add(c);
    }

    final disabled = <String>{};
    for (final c in availableColors) {
      if (!enabled.contains(c)) disabled.add(c);
    }
    return disabled;
  }

  List<String> get availableSizes {
    final set = <String>{};
    for (final v in inStockVariants) {
      final s = v.size.trim();
      if (s.isNotEmpty) set.add(s);
    }
    final list = set.toList(growable: false);
    list.sort();
    return list;
  }

  Set<String> get disabledSizes {
    final color = selectedColor?.trim();
    if (color == null || color.isEmpty) return const <String>{};

    final enabled = <String>{};
    for (final v in inStockVariants) {
      if (v.color.trim() != color) continue;
      final s = v.size.trim();
      if (s.isNotEmpty) enabled.add(s);
    }

    final disabled = <String>{};
    for (final s in availableSizes) {
      if (!enabled.contains(s)) disabled.add(s);
    }
    return disabled;
  }
}

class ProductDetailsError extends ProductDetailsState {
  const ProductDetailsError(this.error);

  final Object error;
}

final productDetailsViewModelProvider =
    StateNotifierProvider.family<
      ProductDetailsViewModel,
      ProductDetailsState,
      String?
    >((ref, productId) {
      return ProductDetailsViewModel(ref, productId);
    });

class ProductDetailsViewModel extends StateNotifier<ProductDetailsState> {
  ProductDetailsViewModel(this._ref, this._productId)
    : super(const ProductDetailsState.loading()) {
    _load();
  }

  final Ref _ref;
  final String? _productId;

  Future<void> _load() async {
    final id = _productId;
    if (id == null || id.isEmpty) {
      state = const ProductDetailsState.notFound();
      return;
    }

    try {
      final repo = _ref.read(productRepositoryProvider);
      final product = await repo.getProductById(id);
      if (product == null) {
        state = const ProductDetailsState.notFound();
        return;
      }

      final inStock = product.variants.where((v) => v.stock > 0).toList();
      final auto = inStock.length == 1 ? inStock.first : null;
      state = ProductDetailsState.data(
        product: product,
        selectedColor: auto?.color,
        selectedSize: auto?.size,
      );
      await _ref
          .read(recentlyViewedViewModelProvider.notifier)
          .add(product.id);
    } catch (e) {
      state = ProductDetailsState.error(e);
    }
  }

  void selectColor(String value) {
    final s = state;
    if (s is! ProductDetailsData) return;
    final color = value.trim();
    final currentSize = s.selectedSize?.trim();

    String? nextSize = currentSize;
    if (currentSize != null && currentSize.isNotEmpty) {
      final hasCombo = s.inStockVariants.any(
        (v) => v.color.trim() == color && v.size.trim() == currentSize,
      );
      if (!hasCombo) {
        final first = s.inStockVariants
            .where((v) => v.color.trim() == color)
            .toList(growable: false);
        nextSize = first.isEmpty ? null : first.first.size;
      }
    }

    state = s.copyWith(selectedColor: value, selectedSize: nextSize);
  }

  void selectSize(String value) {
    final s = state;
    if (s is! ProductDetailsData) return;
    final size = value.trim();
    final currentColor = s.selectedColor?.trim();

    String? nextColor = currentColor;
    if (currentColor != null && currentColor.isNotEmpty) {
      final hasCombo = s.inStockVariants.any(
        (v) => v.color.trim() == currentColor && v.size.trim() == size,
      );
      if (!hasCombo) {
        final first = s.inStockVariants
            .where((v) => v.size.trim() == size)
            .toList(growable: false);
        nextColor = first.isEmpty ? null : first.first.color;
      }
    }

    state = s.copyWith(selectedSize: value, selectedColor: nextColor);
  }

  void clearSelection() {
    final s = state;
    if (s is! ProductDetailsData) return;
    state = s.copyWith(selectedColor: null, selectedSize: null);
  }
}
