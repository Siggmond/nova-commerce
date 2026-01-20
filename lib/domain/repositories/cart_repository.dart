import '../entities/cart_line.dart';

abstract class CartRepository {
  Future<List<CartLine>> loadCartLines();
  Future<void> saveCartLines(List<CartLine> items);
}
