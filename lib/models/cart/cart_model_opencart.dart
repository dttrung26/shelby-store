import 'package:flutter/material.dart';

import '../../common/config.dart';
import '../entities/product.dart';
import '../entities/product_variation.dart';
import 'cart_base.dart';
import 'mixin/address_mixin.dart';
import 'mixin/cart_mixin.dart';
import 'mixin/coupon_mixin.dart';
import 'mixin/currency_mixin.dart';
import 'mixin/local_mixin.dart';
import 'mixin/magento_mixin.dart';
import 'mixin/opencart_mixin.dart';
import 'mixin/shopify_mixin.dart';
import 'mixin/vendor_mixin.dart';

class CartModelOpencart
    with
        ChangeNotifier,
        CartMixin,
        MagentoMixin,
        AddressMixin,
        LocalMixin,
        CurrencyMixin,
        CouponMixin,
        ShopifyMixin,
        VendorMixin,
        OpencartMixin
    implements CartModel {
  static final CartModelOpencart _instance = CartModelOpencart._internal();

  factory CartModelOpencart() => _instance;

  CartModelOpencart._internal();
  @override
  Future<void> initData() async {
    await getShippingAddress();
    await getCartInLocal();
    await getCurrency();
  }

  @override
  double getSubTotal() {
    return productsInCart.keys.fold(0.0, (sum, key) {
      return sum + double.parse(item[key].price) * productsInCart[key];
    });
  }

  @override
  double getTotal() {
    var subtotal = getSubTotal();

    if (couponObj != null) {
      if (couponObj.discountType == 'percent') {
        subtotal -= subtotal * couponObj.amount / 100;
      } else {
        subtotal -= (couponObj.amount * totalCartQuantity);
      }
    }

    if (kPaymentConfig['EnableShipping']) {
      subtotal += getShippingCost();
    }
    return subtotal;
  }

  @override
  double getItemTotal(
      {ProductVariation productVariation, Product product, int quantity = 1}) {
    var subtotal = double.parse(product.price) * quantity;

    if (couponObj != null) {
      if (couponObj.discountType == 'percent') {
        return subtotal - subtotal * couponObj.amount / 100;
      } else {
        return subtotal - (couponObj.amount * quantity);
      }
    } else {
      return subtotal;
    }
  }

  @override
  String updateQuantity(Product product, String key, int quantity, {context}) {
    var message = '';
    var total = quantity;
    ProductVariation variation;

    if (key.contains('-')) {
      variation = getProductVariationById(key);
    }
    var stockQuantity =
        variation == null ? product.stockQuantity : variation.stockQuantity;

    if (product.manageStock == null || !product.manageStock) {
      productsInCart[key] = total;
    } else if (total <= stockQuantity) {
      if (product.minQuantity == null && product.maxQuantity == null) {
        productsInCart[key] = total;
      } else if (product.minQuantity != null && product.maxQuantity == null) {
        total < product.minQuantity
            ? message = 'Minimum quantity is ${product.minQuantity}'
            : productsInCart[key] = total;
      } else if (product.minQuantity == null && product.maxQuantity != null) {
        total > product.maxQuantity
            ? message =
                'You can only purchase ${product.maxQuantity} for this product'
            : productsInCart[key] = total;
      } else if (product.minQuantity != null && product.maxQuantity != null) {
        if (total >= product.minQuantity && total <= product.maxQuantity) {
          productsInCart[key] = total;
        } else {
          if (total < product.minQuantity) {
            message = 'Minimum quantity is ${product.minQuantity}';
          }
          if (total > product.maxQuantity) {
            message =
                'You can only purchase ${product.maxQuantity} for this product';
          }
        }
      }
    } else {
      message = 'Currently we only have $stockQuantity of this product';
    }
    if (message.isEmpty) {
      updateQuantityCartLocal(key: key, quantity: quantity);
      notifyListeners();
    }
    return message;
  }

  @override
  // Removes an item from the cart.
  void removeItemFromCart(String key) {
    if (productsInCart.containsKey(key)) {
      productsInCart.remove(key);
      productVariationInCart.remove(key);
      removeProductLocal(key);
    }
    notifyListeners();
  }

  @override
  // Removes everything from the cart.
  void clearCart() {
    clearCartLocal();
    productsInCart.clear();
    item.clear();
    productVariationInCart.clear();
    productOptionInCart.clear();
    shippingMethod = null;
    paymentMethod = null;
    resetCoupon();
    notes = null;
    notifyListeners();
  }

  @override
  void setOrderNotes(String note) {
    notes = note;
    notifyListeners();
  }

  @override
  String addProductToCart({
    context,
    Product product,
    int quantity = 1,
    ProductVariation variation,
    Function notify,
    isSaveLocal = true,
    Map<String, dynamic> options,
  }) {
    var message = super.addProductToCart(
        product: product,
        quantity: quantity,
        variation: variation,
        isSaveLocal: isSaveLocal,
        notify: notifyListeners);

    var key = '${product.id}';
    productOptionInCart[key] = options;
    return message;
  }

  @override
  void setRewardTotal(double total) {
    rewardTotal = total;
    notifyListeners();
  }
}
