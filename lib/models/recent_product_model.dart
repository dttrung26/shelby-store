import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import 'entities/product.dart';

class RecentModel with ChangeNotifier {
  List<Product> products = [];
  final LocalStorage storage = LocalStorage('fstore');

  void addRecentProduct(Product product) {
    var data = [];
    products.removeWhere((index) => index.id == product.id);
    if (products.length == 20) products.removeLast();
    products.insert(0, product);
    for (var item in products) {
      data.add(item.toJson());
    }
    storage.setItem('recent', data);
    notifyListeners();
  }

  Future<List<Product>> getRecentProduct() {
    var data = storage.getItem('recent') ?? [];
    if (data.length > 0) {
      for (var item in data) {
        products.add(Product.fromLocalJson(item));
      }
      notifyListeners();
    }
    return Future.delayed(const Duration(milliseconds: 1), () => products);
  }
}
