import 'package:flutter/material.dart';

import '../../common/config.dart';
import '../../common/tools.dart';
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

class CartModelShopify
    with
        ChangeNotifier,
        CartMixin,
        MagentoMixin,
        AddressMixin,
        LocalMixin,
        CurrencyMixin,
        CouponMixin,
        OpencartMixin,
        VendorMixin,
        ShopifyMixin
    implements CartModel {
  static final CartModelShopify _instance = CartModelShopify._internal();

  factory CartModelShopify() => _instance;

  CartModelShopify._internal();

  @override
  Future<void> initData() async {
    await getShippingAddress();
    await getCartInLocal();
    await getCurrency();
  }

  @override
  double getSubTotal() {
    if (checkout != null && checkout.subtotalPrice != null) {
      return checkout.subtotalPrice;
    }

    return productsInCart.keys.fold(0.0, (sum, key) {
      if (productVariationInCart[key] != null &&
          productVariationInCart[key].price != null &&
          productVariationInCart[key].price.isNotEmpty) {
        return sum +
            double.parse(productVariationInCart[key].price) *
                productsInCart[key];
      } else {
        var price =
            Tools.getPriceProductValue(item[key], currency, onSale: true);
        if (price.isNotEmpty) {
          return sum + double.parse(price) * productsInCart[key];
        }
        return sum;
      }
    });
  }

  @override
  double getTax() {
    return checkout.totalTax;
  }

  @override
  String getCoupon() {
    if (couponObj != null) {
      if (couponObj.discountType == 'percent') {
        return '-${couponObj.amount}%';
      } else {
        return '-' +
            Tools.getCurrencyFormatted(
                couponObj.amount * totalCartQuantity, currencyRates,
                currency: currency);
      }
    } else {
      return '';
    }
  }

  @override
  double getTotal() {
    if (checkout != null && checkout.totalPrice != null) {
      return checkout.totalPrice;
    }

    var subtotal = getSubTotal();
    if (kPaymentConfig['EnableShipping']) {
      subtotal += getShippingCost();
    }
    if (couponObj != null) {
      if (couponObj.discountType == 'percent') {
        return subtotal - subtotal * couponObj.amount / 100;
      } else {
        return subtotal - (couponObj.amount * totalCartQuantity);
      }
    } else {
      return subtotal;
    }
  }

  @override
  double getCouponCost() {
    var subtotal = getSubTotal();
    if (couponObj != null) {
      if (couponObj.discountType == 'percent') {
        return subtotal * couponObj.amount / 100;
      } else {
        return couponObj.amount * totalCartQuantity;
      }
    } else {
      return 0.0;
    }
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
    if (isSaveLocal) {
      saveCartToLocal(
        product: product,
        quantity: quantity,
        variation: variation,
      );
    }
    var key = '${product.id}';

    item[key] = product;

    if (variation?.id != null) {
      key += '-${variation.id}';

      productVariationInCart[key] = variation;
    } else {
      var defaultVariation = product.variations[0];

      productVariationInCart[key] = defaultVariation;
    }

    if (!productsInCart.containsKey(key)) {
      productsInCart[key] = quantity;
    } else {
      productsInCart[key] += quantity;
    }
    // item[key] = product;

    productSkuInCart[key] = product.sku;

    notifyListeners();

    return '';
  }

  @override
  String updateQuantity(Product product, String key, int quantity, {context}) {
    if (productsInCart.containsKey(key)) {
      productsInCart[key] = quantity;
      updateQuantityCartLocal(key: key, quantity: quantity);
      notifyListeners();
    }
    return '';
  }

  // Removes an item from the cart.
  @override
  void removeItemFromCart(String key) {
    if (productsInCart.containsKey(key)) {
      removeProductLocal(key);
      if (productsInCart[key] == 1) {
        productsInCart.remove(key);
        productVariationInCart.remove(key);
        productSkuInCart.remove(key);
      } else {
        productsInCart[key]--;
      }
    }
    notifyListeners();
  }

  @override
  double getItemTotal(
      {ProductVariation productVariation, Product product, int quantity = 1}) {
    return 0;
  }

  @override
  void setOrderNotes(String note) {
    notes = note;
    notifyListeners();
  }

  // Removes everything from the cart.
  @override
  void clearCart() {
    clearCartLocal();
    productsInCart.clear();
    item.clear();
    productVariationInCart.clear();
    productSkuInCart.clear();
    shippingMethod = null;
    paymentMethod = null;
    couponObj = null;
    notes = null;
    notifyListeners();
  }

  @override
  void setRewardTotal(double total) {
    rewardTotal = total;
    notifyListeners();
  }
}
