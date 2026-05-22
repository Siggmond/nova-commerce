import 'package:nova_commerce/core/domain/entities/product.dart';
import 'package:nova_commerce/core/domain/entities/variant.dart';
import 'package:nova_commerce/features/cart/domain/entities/cart_item.dart';
import 'package:nova_commerce/features/cart/domain/entities/cart_line.dart';
import 'package:nova_commerce/features/cart/domain/entities/cart_state_model.dart';

sealed class CartAction {
  const CartAction();

  CartKey get key;
}

class AddCartAction extends CartAction {
  const AddCartAction({
    required this.line,
    required this.product,
    this.quantityDelta = 1,
  }) : assert(quantityDelta > 0);

  final CartLine line;
  final Product product;
  final int quantityDelta;

  @override
  CartKey get key => CartKey.fromLine(line);
}

class RemoveCartAction extends CartAction {
  const RemoveCartAction({required this.key});

  @override
  final CartKey key;
}

class UpdateCartQuantityAction extends CartAction {
  const UpdateCartQuantityAction({required this.key, required this.quantity});

  @override
  final CartKey key;
  final int quantity;
}

class RecalculateCartTotalsUseCase {
  const RecalculateCartTotalsUseCase({this.discountRate = 0, this.taxRate = 0});

  final double discountRate;
  final double taxRate;

  CartState call({required CartState previous, required CartAction action}) {
    return switch (action) {
      AddCartAction() => _add(previous, action),
      RemoveCartAction() => _remove(previous, action.key),
      UpdateCartQuantityAction() => _updateQty(previous, action),
    };
  }

  CartState _add(CartState previous, AddCartAction action) {
    final key = action.key;
    final existingLine = previous.lineForKey(key);
    final existingItem = previous.itemForKey(key);
    final deltaQty = action.quantityDelta > 0 ? action.quantityDelta : 1;
    final nextQty = (existingLine?.quantity ?? 0) + deltaQty;
    if (nextQty <= 0) return previous;

    final nextLine = (existingLine ?? action.line).copyWith(quantity: nextQty);
    final nextItem = _buildCartItem(
      product: action.product,
      line: nextLine,
      quantity: nextQty,
    );

    final prevLineTotal = existingItem?.total ?? 0;
    final deltaSubtotal = nextItem.total - prevLineTotal;
    final nextSubtotal = _money(previous.totals.subtotal + deltaSubtotal);

    final nextLines = Map<CartKey, CartLine>.of(previous.linesByKey)
      ..[key] = nextLine;
    final nextItems = Map<CartKey, CartItem>.of(previous.itemsByKey)
      ..[key] = nextItem;
    final nextProducts = Map<String, Product>.of(previous.productsById)
      ..[action.product.id] = action.product;
    final nextOrder = existingLine == null
        ? <CartKey>[...previous.orderedKeys, key]
        : previous.orderedKeys;

    return CartState(
      linesByKey: nextLines,
      orderedKeys: nextOrder,
      productsById: nextProducts,
      itemsByKey: nextItems,
      totals: _totalsFromSubtotal(nextSubtotal),
      totalQuantity: previous.totalQuantity + deltaQty,
    );
  }

  CartState _remove(CartState previous, CartKey key) {
    final existingLine = previous.lineForKey(key);
    if (existingLine == null) return previous;

    final existingItem =
        previous.itemForKey(key) ??
        _buildCartItem(
          product:
              previous.productsById[existingLine.productId] ??
              _unknownProduct(existingLine.productId),
          line: existingLine,
          quantity: existingLine.quantity,
        );

    final nextSubtotal = _money(previous.totals.subtotal - existingItem.total);

    final nextLines = Map<CartKey, CartLine>.of(previous.linesByKey)
      ..remove(key);
    final nextItems = Map<CartKey, CartItem>.of(previous.itemsByKey)
      ..remove(key);
    final nextOrder = <CartKey>[
      for (final candidate in previous.orderedKeys)
        if (candidate != key) candidate,
    ];

    final nextQuantity = previous.totalQuantity - existingLine.quantity;
    return CartState(
      linesByKey: nextLines,
      orderedKeys: nextOrder,
      productsById: previous.productsById,
      itemsByKey: nextItems,
      totals: _totalsFromSubtotal(nextSubtotal),
      totalQuantity: nextQuantity > 0 ? nextQuantity : 0,
    );
  }

  CartState _updateQty(CartState previous, UpdateCartQuantityAction action) {
    final existingLine = previous.lineForKey(action.key);
    if (existingLine == null) return previous;

    if (action.quantity <= 0) {
      return _remove(previous, action.key);
    }
    if (action.quantity == existingLine.quantity) {
      return previous;
    }

    final existingItem =
        previous.itemForKey(action.key) ??
        _buildCartItem(
          product:
              previous.productsById[existingLine.productId] ??
              _unknownProduct(existingLine.productId),
          line: existingLine,
          quantity: existingLine.quantity,
        );
    final product =
        previous.productsById[existingLine.productId] ?? existingItem.product;
    final nextLine = existingLine.copyWith(quantity: action.quantity);
    final nextItem = _buildCartItem(
      product: product,
      line: nextLine,
      quantity: action.quantity,
    );

    final deltaSubtotal = nextItem.total - existingItem.total;
    final nextSubtotal = _money(previous.totals.subtotal + deltaSubtotal);

    final nextLines = Map<CartKey, CartLine>.of(previous.linesByKey)
      ..[action.key] = nextLine;
    final nextItems = Map<CartKey, CartItem>.of(previous.itemsByKey)
      ..[action.key] = nextItem;

    return CartState(
      linesByKey: nextLines,
      orderedKeys: previous.orderedKeys,
      productsById: previous.productsById,
      itemsByKey: nextItems,
      totals: _totalsFromSubtotal(nextSubtotal),
      totalQuantity:
          previous.totalQuantity - existingLine.quantity + action.quantity,
    );
  }

  CartItem _buildCartItem({
    required Product product,
    required CartLine line,
    required int quantity,
  }) {
    return CartItem(
      product: product,
      quantity: quantity,
      selectedColor: line.selectedColor,
      selectedSize: line.selectedSize,
    );
  }

  CartTotals _totalsFromSubtotal(double subtotal) {
    final normalizedSubtotal = _money(subtotal);
    final discount = discountRate <= 0
        ? 0.0
        : _money(normalizedSubtotal * discountRate);
    final taxable = _money(normalizedSubtotal - discount);
    final tax = taxRate <= 0 ? 0.0 : _money(taxable * taxRate);
    final total = _money(taxable + tax);
    return CartTotals(
      subtotal: normalizedSubtotal,
      discount: discount,
      tax: tax,
      total: total,
    );
  }

  double _money(double value) {
    if (value <= 0) return 0.0;
    return double.parse(value.toStringAsFixed(2));
  }

  Product _unknownProduct(String productId) {
    return Product(
      id: productId,
      title: 'Unknown product',
      brand: '',
      price: 0,
      currency: 'USD',
      imageUrls: const <String>[],
      description: '',
      variants: const <Variant>[],
    );
  }
}
