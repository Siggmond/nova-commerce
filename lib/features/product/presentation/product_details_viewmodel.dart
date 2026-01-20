import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../domain/entities/product.dart';

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
    required T Function(
      Product product,
      String? selectedColor,
      String? selectedSize,
    )
    data,
  }) {
    final s = this;
    if (s is ProductDetailsLoading) return loading();
    if (s is ProductDetailsNotFound) return notFound();
    if (s is ProductDetailsError) return error(s.error);
    final d = s as ProductDetailsData;
    return data(d.product, d.selectedColor, d.selectedSize);
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
    } catch (e) {
      state = ProductDetailsState.error(e);
    }
  }

  void selectColor(String value) {
    final s = state;
    if (s is! ProductDetailsData) return;
    final currentSize = s.selectedSize;
    final hasInStock = currentSize == null
        ? true
        : s.product.variants.any(
            (v) =>
                v.stock > 0 &&
                v.color.trim() == value.trim() &&
                v.size.trim() == currentSize.trim(),
          );

    state = s.copyWith(
      selectedColor: value,
      selectedSize: hasInStock ? currentSize : null,
    );
  }

  void selectSize(String value) {
    final s = state;
    if (s is! ProductDetailsData) return;
    final currentColor = s.selectedColor;
    final hasInStock = currentColor == null
        ? true
        : s.product.variants.any(
            (v) =>
                v.stock > 0 &&
                v.color.trim() == currentColor.trim() &&
                v.size.trim() == value.trim(),
          );

    state = s.copyWith(
      selectedSize: value,
      selectedColor: hasInStock ? currentColor : null,
    );
  }
}
