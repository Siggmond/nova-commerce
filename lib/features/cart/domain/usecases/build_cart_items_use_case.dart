import 'package:nova_commerce/core/domain/entities/product.dart';
import 'package:nova_commerce/core/domain/entities/variant.dart';
import 'package:nova_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:nova_commerce/features/cart/domain/entities/cart_line.dart';

class BuildCartItemsUseCase {
  const BuildCartItemsUseCase();

  List<CartItem> call({
    required List<CartLine> lines,
    required List<Product> products,
  }) {
    if (lines.isEmpty) return const <CartItem>[];

    final byId = <String, Product>{
      for (final product in products) product.id: product,
    };
    return lines
        .map((line) {
          final product =
              byId[line.productId] ??
              Product(
                id: line.productId,
                title: 'Unknown product',
                brand: '',
                price: 0,
                currency: 'USD',
                imageUrls: const <String>[],
                description: '',
                variants: const <Variant>[],
              );
          return CartItem(
            product: product,
            quantity: line.quantity,
            selectedColor: line.selectedColor,
            selectedSize: line.selectedSize,
          );
        })
        .toList(growable: false);
  }
}
