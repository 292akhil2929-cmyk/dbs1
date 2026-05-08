import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  static const _key = 'ss_flutter_cart';

  List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (s, e) => s + e.quantity);

  double get subtotal => _items.fold(0.0, (s, e) => s + e.lineTotal);

  double get shipping => _items.isEmpty ? 0.0 : 10.0;

  double get vat => (subtotal + shipping) * 0.05;

  double get total => subtotal + shipping + vat;

  CartProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        _items = list
            .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (_) {
      _items = [];
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(_items.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  void addItem(Product p, {int qty = 1}) {
    final idx = _items.indexWhere((e) => e.product.productId == p.productId);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(quantity: _items[idx].quantity + qty);
    } else {
      _items = [..._items, CartItem(product: p, quantity: qty)];
    }
    notifyListeners();
    _save();
  }

  void removeItem(int productId) {
    _items = _items.where((e) => e.product.productId != productId).toList();
    notifyListeners();
    _save();
  }

  void updateQty(int productId, int qty) {
    if (qty <= 0) {
      removeItem(productId);
      return;
    }
    final idx = _items.indexWhere((e) => e.product.productId == productId);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(quantity: qty);
      notifyListeners();
      _save();
    }
  }

  void clear() {
    _items = [];
    notifyListeners();
    _save();
  }
}
