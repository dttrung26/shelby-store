import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import '../common/constants.dart';
import 'entities/product.dart';

class WishListModel extends ChangeNotifier {
  WishListModel() {
    getLocalWishlist();
  }

  List<Product> products = [];

  List<Product> getWishList() => products;

  void addToWishlist(Product product) {
    final isExist = products.firstWhere((item) => item.id == product.id,
        orElse: () => null);
    if (isExist == null) {
      products.add(product);
      saveWishlist(products);
      notifyListeners();
    }
  }

  void removeToWishlist(Product product) {
    final isExist = products.firstWhere((item) => item.id == product.id,
        orElse: () => null);
    if (isExist != null) {
      products = products.where((item) => item.id != product.id).toList();
      saveWishlist(products);
      notifyListeners();
    }
  }

  Future<void> saveWishlist(List<Product> products) async {
    final storage = LocalStorage('fstore');
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem(kLocalKey['wishlist'], products);
      }
    } catch (_) {}
  }

  Future<void> getLocalWishlist() async {
    final storage = LocalStorage('fstore');
    try {
      final ready = await storage.ready;
      if (ready) {
        final json = await storage.getItem(kLocalKey['wishlist']);
        if (json != null) {
          var list = <Product>[];
          for (var item in json) {
            list.add(Product.fromLocalJson(item));
          }
          products = list;
        }
      }
    } catch (_) {}
  }

  Future<void> clearWishList() async {
    products = [];
    await saveWishlist(products);
    notifyListeners();
  }
}
