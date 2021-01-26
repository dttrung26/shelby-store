import 'package:flutter/material.dart';

import '../models/cart/cart_model.dart';
import '../services/index.dart';
import 'entities/shipping_method.dart';

class ShippingMethodModel extends ChangeNotifier {
  final Services _service = Services();
  List<ShippingMethod> shippingMethods;
  bool isLoading = true;
  String message;

  Future<void> getShippingMethods(
      {CartModel cartModel, String token, String checkoutId}) async {
    try {
      isLoading = true;
      notifyListeners();
      shippingMethods = await _service.api.getShippingMethods(
          cartModel: cartModel, token: token, checkoutId: checkoutId);
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
