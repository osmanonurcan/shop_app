import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'auth.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class Cart with ChangeNotifier {
  Auth _auth;
  String _token;

  set auth(Auth value) {
    _auth = value;
    _token = _auth.token;
  }

  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmounth {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  Future<void> fetchAndSetCart() async {
    final url = Uri.parse(
        'https://flutter-app-6ae92-default-rtdb.europe-west1.firebasedatabase.app/cart.json?auth=$_token');
    final response = await http.get(url);

    final Map<String, CartItem> loadedCart = {};
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null) {
      return;
    }
    extractedData.forEach((cartId, cartData) {
      loadedCart[cartData['productId']] = CartItem(
          id: cartId,
          title: cartData['cartItem']['title'],
          quantity: int.parse(cartData['cartItem']['quantity']),
          price: double.parse(cartData['cartItem']['price']));
    });
    _items = loadedCart;
    notifyListeners();
  }

  Future<void> addItem(String productId, double price, String title) async {
    if (_items.containsKey(productId)) {
      final String cartId = _items[productId].id;
      final url = Uri.parse(
          'https://flutter-app-6ae92-default-rtdb.europe-west1.firebasedatabase.app/cart/$cartId.json?auth=$_token');
      final response = await http.patch(url,
          body: json.encode({
            'cartItem': {
              'quantity': _items[productId].quantity + 1,
            },
          }));
      _items.update(
          productId,
          (existingCard) => CartItem(
                id: existingCard.id,
                title: existingCard.title,
                quantity: existingCard.quantity + 1,
                price: existingCard.price,
              ));
    } else {
      final url = Uri.parse(
          'https://flutter-app-6ae92-default-rtdb.europe-west1.firebasedatabase.app/cart.json?auth=$_token');
      final response = await http.post(url,
          body: json.encode({
            'productId': productId,
            'cartItem': {
              'title': title,
              'quantity': 1,
              'price': price,
            },
          }));

      _items.putIfAbsent(
          productId,
          () => CartItem(
              id: json.decode(response.body)['name'],
              title: title,
              quantity: 1,
              price: price));
    }
    notifyListeners();
  }

  Future<void> removeSingleItem(String productId) async {
    final String cartId = _items[productId].id;
    final url = Uri.parse(
        'https://flutter-app-6ae92-default-rtdb.europe-west1.firebasedatabase.app/cart/$cartId.json?auth=$_token');
    if (!_items.containsKey(productId)) {
      return;
    } else if (_items[productId].quantity > 1) {
      final response = await http.patch(url,
          body: json.encode({
            'cartItem': {
              'quantity': _items[productId].quantity - 1,
            },
          }));
      _items.update(
          productId,
          (existingItem) => CartItem(
                id: existingItem.id,
                title: existingItem.title,
                quantity: existingItem.quantity - 1,
                price: existingItem.price,
              ));
    } else {
      await http.delete(url);
      removeItem(productId);
    }
    notifyListeners();
  }

  Future<void> removeItem(String productId) async {
    final String cartId = _items[productId].id;
    final url = Uri.parse(
        'https://flutter-app-6ae92-default-rtdb.europe-west1.firebasedatabase.app/cart/$cartId.json?auth=$_token');
    if (!_items.containsKey(productId)) {
      return;
    }
    await http.delete(url);
    _items.remove(productId);
    notifyListeners();
  }

  Future<void> remove() async {
    final url = Uri.parse(
        'https://flutter-app-6ae92-default-rtdb.europe-west1.firebasedatabase.app/cart.json?auth=$_token');
    await http.delete(url);
    _items = {};
    notifyListeners();
  }
}
