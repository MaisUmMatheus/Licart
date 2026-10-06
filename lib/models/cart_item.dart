import 'product.dart';

class CartItem {
  final Product product;
  final String size;
  int quantity;

  CartItem({
    required this.product,
    this.size = 'M',
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
}
