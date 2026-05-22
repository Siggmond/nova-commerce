import 'package:nova_commerce/core/domain/entities/variant.dart';

class ProductVariantSelection {
  const ProductVariantSelection({
    required this.selectedColor,
    required this.selectedSize,
  });

  final String? selectedColor;
  final String? selectedSize;
}

class SelectProductVariantUseCase {
  const SelectProductVariantUseCase();

  ProductVariantSelection selectColor({
    required List<Variant> inStockVariants,
    required String nextColor,
    required String? currentSize,
  }) {
    final color = nextColor.trim();
    final size = currentSize?.trim();
    if (size == null || size.isEmpty) {
      return ProductVariantSelection(
        selectedColor: nextColor,
        selectedSize: currentSize,
      );
    }

    final hasCombo = inStockVariants.any(
      (variant) => variant.color.trim() == color && variant.size.trim() == size,
    );
    if (hasCombo) {
      return ProductVariantSelection(
        selectedColor: nextColor,
        selectedSize: currentSize,
      );
    }

    final fallback = inStockVariants.firstWhere(
      (variant) => variant.color.trim() == color,
      orElse: () => const Variant(color: '', size: '', stock: 0),
    );

    return ProductVariantSelection(
      selectedColor: nextColor,
      selectedSize: fallback.size.trim().isEmpty ? null : fallback.size,
    );
  }

  ProductVariantSelection selectSize({
    required List<Variant> inStockVariants,
    required String nextSize,
    required String? currentColor,
  }) {
    final size = nextSize.trim();
    final color = currentColor?.trim();
    if (color == null || color.isEmpty) {
      return ProductVariantSelection(
        selectedColor: currentColor,
        selectedSize: nextSize,
      );
    }

    final hasCombo = inStockVariants.any(
      (variant) => variant.color.trim() == color && variant.size.trim() == size,
    );
    if (hasCombo) {
      return ProductVariantSelection(
        selectedColor: currentColor,
        selectedSize: nextSize,
      );
    }

    final fallback = inStockVariants.firstWhere(
      (variant) => variant.size.trim() == size,
      orElse: () => const Variant(color: '', size: '', stock: 0),
    );

    return ProductVariantSelection(
      selectedColor: fallback.color.trim().isEmpty ? null : fallback.color,
      selectedSize: nextSize,
    );
  }
}
