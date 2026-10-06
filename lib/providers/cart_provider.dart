import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool get isEmpty => _items.isEmpty;

  // Frete grátis acima de R$ 250
  double get freeShippingThreshold => 250.0;
  bool get hasFreeShipping => totalAmount >= freeShippingThreshold;
  double get amountUntilFreeShipping =>
      (freeShippingThreshold - totalAmount).clamp(0.0, freeShippingThreshold);

  String _generateKey(String productId, String size) => '${productId}_$size';

  void addItem(Product product, {String size = 'M'}) {
    final key = _generateKey(product.id, size);
    if (_items.containsKey(key)) {
      _items[key]!.quantity += 1;
    } else {
      _items[key] = CartItem(product: product, size: size);
    }
    notifyListeners();
  }

  void decrementItem(String itemKey) {
    if (!_items.containsKey(itemKey)) return;
    if (_items[itemKey]!.quantity > 1) {
      _items[itemKey]!.quantity -= 1;
    } else {
      _items.remove(itemKey);
    }
    notifyListeners();
  }

  void removeItem(String itemKey) {
    _items.remove(itemKey);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
