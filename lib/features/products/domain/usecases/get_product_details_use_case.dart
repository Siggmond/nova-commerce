import 'package:nova_commerce/core/domain/entities/product.dart';
import 'package:nova_commerce/core/domain/entities/variant.dart';
import 'package:nova_commerce/core/domain/repositories/product_repository.dart';

class ProductDetailsPayload {
  const ProductDetailsPayload({
    required this.product,
    required this.autoSelectedColor,
    required this.autoSelectedSize,
  });

  final Product product;
  final String? autoSelectedColor;
  final String? autoSelectedSize;
}

class GetProductDetailsUseCase {
  const GetProductDetailsUseCase(this._repository);

  final ProductRepository _repository;

  Future<ProductDetailsPayload?> call(String? productId) async {
    final id = productId?.trim() ?? '';
    if (id.isEmpty) return null;

    final product = await _repository.getProductById(id);
    if (product == null) return null;

    final inStock = product.variants
        .where((variant) => variant.stock > 0)
        .toList(growable: false);
    final Variant? auto = inStock.length == 1 ? inStock.first : null;

    return ProductDetailsPayload(
      product: product,
      autoSelectedColor: auto?.color,
      autoSelectedSize: auto?.size,
    );
  }
}
