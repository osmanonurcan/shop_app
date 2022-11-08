import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exceptions.dart';
import 'auth.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  // void toggleFavorite() {
  //   isFavorite = !isFavorite;
  //   notifyListeners();
  // }

  Future<void> toggleFavorite(String token, String userId) async {
    final url = Uri.parse(
        'https://flutter-app-6ae92-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId/$id.json?auth=$token');
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final response = await http.put(url,
          body: json.encode(
            isFavorite,
          ));
      if (response.statusCode >= 400) {
        isFavorite = !isFavorite;
        notifyListeners();
        throw HttpExceptions('Could not delete product.');
      }
    } catch (error) {
      isFavorite = !isFavorite;
      notifyListeners();
    }
  }
}
