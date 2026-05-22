import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nova_commerce/app/di/app_providers.dart';
import '../../../core/domain/entities/product.dart';
import '../../../core/domain/entities/variant.dart';
import '../domain/usecases/get_product_details_use_case.dart';
import '../domain/usecases/select_product_variant_use_case.dart';
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
  ProductDetailsViewModel(
    Ref ref,
    this._productId, {
    GetProductDetailsUseCase? getProductDetailsUseCase,
    SelectProductVariantUseCase? selectProductVariantUseCase,
  }) : _ref = ref,
       _getProductDetailsUseCase =
           getProductDetailsUseCase ??
           GetProductDetailsUseCase(ref.read(productRepositoryProvider)),
       _selectProductVariantUseCase =
           selectProductVariantUseCase ?? const SelectProductVariantUseCase(),
       super(const ProductDetailsState.loading()) {
    _load();
  }

  final Ref _ref;
  final String? _productId;
  final GetProductDetailsUseCase _getProductDetailsUseCase;
  final SelectProductVariantUseCase _selectProductVariantUseCase;

  Future<void> _load() async {
    try {
      final payload = await _getProductDetailsUseCase(_productId);
      if (payload == null) {
        state = const ProductDetailsState.notFound();
        return;
      }

      state = ProductDetailsState.data(
        product: payload.product,
        selectedColor: payload.autoSelectedColor,
        selectedSize: payload.autoSelectedSize,
      );
      await _ref
          .read(recentlyViewedViewModelProvider.notifier)
          .add(payload.product.id);
    } catch (e) {
      state = ProductDetailsState.error(e);
    }
  }

  void selectColor(String value) {
    final s = state;
    if (s is! ProductDetailsData) return;
    final selection = _selectProductVariantUseCase.selectColor(
      inStockVariants: s.inStockVariants,
      nextColor: value,
      currentSize: s.selectedSize,
    );
    state = s.copyWith(
      selectedColor: selection.selectedColor,
      selectedSize: selection.selectedSize,
    );
  }

  void selectSize(String value) {
    final s = state;
    if (s is! ProductDetailsData) return;
    final selection = _selectProductVariantUseCase.selectSize(
      inStockVariants: s.inStockVariants,
      nextSize: value,
      currentColor: s.selectedColor,
    );
    state = s.copyWith(
      selectedSize: selection.selectedSize,
      selectedColor: selection.selectedColor,
    );
  }

  void clearSelection() {
    final s = state;
    if (s is! ProductDetailsData) return;
    state = s.copyWith(selectedColor: null, selectedSize: null);
  }
}
