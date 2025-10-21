import 'package:flutter/foundation.dart';
import 'package:karigar_woodwork/models/models.dart';

class CartItemModel {
  final String productId;
  final String name;
  final double price;
  int quantity;

  CartItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItemModel> _itemsByProductId = {};

  List<CartItemModel> get items => _itemsByProductId.values.toList();
  bool get isEmpty => _itemsByProductId.isEmpty;
  int get totalItems => _itemsByProductId.values.fold(0, (a, b) => a + b.quantity);
  double get totalPrice => _itemsByProductId.values
      .fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  void addProduct(Product p, {int quantity = 1}) {
    final existing = _itemsByProductId[p.id];
    if (existing != null) {
      existing.quantity += quantity;
    } else {
      _itemsByProductId[p.id] = CartItemModel(
        productId: p.id,
        name: p.name,
        price: p.price,
        quantity: quantity,
      );
    }
    notifyListeners();
  }

  void removeProduct(String productId) {
    _itemsByProductId.remove(productId);
    notifyListeners();
  }

  void changeQuantity(String productId, int quantity) {
    final item = _itemsByProductId[productId];
    if (item == null) return;
    if (quantity <= 0) {
      _itemsByProductId.remove(productId);
    } else {
      item.quantity = quantity;
    }
    notifyListeners();
  }

  void clear() {
    _itemsByProductId.clear();
    notifyListeners();
  }
}
