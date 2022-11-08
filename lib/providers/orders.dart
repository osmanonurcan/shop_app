import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../providers/cart.dart';
import 'package:http/http.dart' as http;

import 'auth.dart';

class OrderItem {
  final String id;
  final DateTime dateTime;
  final double amount;
  final List<CartItem> cartItems;

  OrderItem({
    this.id,
    this.dateTime,
    this.amount,
    this.cartItems,
  });
}

class Orders with ChangeNotifier {
  Auth _auth;
  String _token;
  String _userId;

  set userId(String value) {
    _userId = value;
  }

  set auth(Auth value) {
    _auth = value;
    _token = _auth.token;
  }

  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://flutter-app-6ae92-default-rtdb.europe-west1.firebasedatabase.app/orders/$_userId.json?auth=$_token');
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
        id: orderId,
        amount: orderData['amount'],
        cartItems: (orderData['cartItems'] as List<dynamic>)
            .map((cartItem) => CartItem(
                  id: cartItem['id'],
                  title: cartItem['title'],
                  quantity: cartItem['quantity'],
                  price: cartItem['price'],
                ))
            .toList(),
        dateTime: DateTime.parse(orderData['dateTime']),
      ));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartItems, double total) async {
    final url = Uri.parse(
        'https://flutter-app-6ae92-default-rtdb.europe-west1.firebasedatabase.app/orders/$_userId.json?auth=$_token');
    final timestamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timestamp.toIso8601String(),
          'cartItems': cartItems
              .map((cartItem) => {
                    'id': cartItem.id,
                    'title': cartItem.title,
                    'quantity': cartItem.quantity,
                    'price': cartItem.price,
                  })
              .toList()
        }));
    _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          cartItems: cartItems,
          dateTime: timestamp,
        ));
    notifyListeners();
  }
}
