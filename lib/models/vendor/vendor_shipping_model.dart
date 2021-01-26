import 'package:flutter/material.dart';

import '../../services/index.dart';
import '../cart/cart_model.dart';
import '../entities/shipping_method.dart';
import 'store_model.dart';

class VendorShippingMethodModel extends ChangeNotifier {
  final Services _service = Services();
  List<VendorShippingMethod> list = [];
  bool isLoading = true;
  String message;

  Future<void> getShippingMethods(
      {CartModel cartModel, List<Store> stores}) async {
    try {
      isLoading = true;
      list = [];
      notifyListeners();
      for (var i = 0; i < stores.length; i++) {
        final store = stores[i];
        var items =
            await _service.api.getShippingMethods(cartModel: cartModel);
        if (items.isNotEmpty) {
          list.add(VendorShippingMethod(store, items));
        }
      }
      isLoading = false;
      message = null;
      notifyListeners();
    } catch (err) {
      isLoading = false;
      message = '⚠️ ' + err.toString();
      notifyListeners();
    }
  }
}

class VendorShippingMethod {
  Store store;
  List<ShippingMethod> shippingMethods = [];

  VendorShippingMethod(this.store, this.shippingMethods);
}
