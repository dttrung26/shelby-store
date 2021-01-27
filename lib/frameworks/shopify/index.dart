import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/theme/colors.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show
        AddonsOption,
        CartModel,
        Country,
        CountryState,
        Coupon,
        Coupons,
        Order,
        PaymentMethod,
        Product,
        ProductVariation,
        ShippingMethodModel,
        User,
        UserModel;
import '../../screens/index.dart'
    show Checkout, MyCart, PaymentWebview, WebviewCheckoutSuccess;
import '../../services/index.dart';
import '../frameworks.dart';
import '../product_variant_mixin.dart';
import 'services/shopify.dart';
import 'shopify_variant_mixin.dart';

class ShopifyWidget extends BaseFrameworks
    with ProductVariantMixin, ShopifyVariantMixin {
  static final ShopifyWidget _instance = ShopifyWidget._internal();

  factory ShopifyWidget() => _instance;

  ShopifyWidget._internal();

  @override
  bool get enableProductReview => false; // currently did not support review

  @override
  Future<void> applyCoupon(context,
      {Coupons coupons, String code, Function success, Function error}) async {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);
    try {
      // check exist checkoutId
      var isExisted = false;

      if (cartModel.checkout != null && cartModel.checkout.id != null) {
        isExisted = true;
      }

      var checkout = isExisted
          ? await ShopifyApi().updateItemsToCart(cartModel)
          : await ShopifyApi().addItemsToCart(cartModel, userModel);
      cartModel.setCheckout(checkout);

      if (checkout != null) {
        // apply coupon code
        var checkoutCoupon =
            await ShopifyApi().applyCoupon(cartModel, code.toUpperCase());

        cartModel.setCheckout(checkoutCoupon);

        // response coupon
        var coupon = Coupon.fromShopify(
            {'totalPrice': cartModel.getTotal(), 'code': code});

        success(coupon);

        return;
      }

      error(S.of(context).couponInvalid);
    } catch (e) {
      error(e.toString());
    }
  }

  @override
  Future<void> doCheckout(context,
      {Function success, Function loading, Function error}) async {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);

    try {
      // check exist checkoutId
      var isExisted = false;

      if (cartModel.checkout != null && cartModel.checkout.id != null) {
        isExisted = true;
      }

      var checkout = isExisted
          ? await ShopifyApi().updateItemsToCart(cartModel)
          : await ShopifyApi().addItemsToCart(cartModel, userModel);
      cartModel.setCheckout(checkout);

      if (kPaymentConfig['EnableOnePageCheckout']) {
        if (checkout != null) {
          /// Navigate to Webview payment
          String orderNum;
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PaymentWebview(
                      url: cartModel.checkout.webUrl,
                      onFinish: (number) async {
                        orderNum = number;
                        cartModel.clearCart();
                      },
                    )),
          );
          if (orderNum != null) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WebviewCheckoutSuccess(
                        order: Order(number: orderNum),
                      )),
            );
          }
          loading(false);
          return;
        }
      }
      success();
    } catch (e) {
      error(e.toString());
    }
  }

  @override
  Future<void> createOrder(context,
      {Function onLoading,
      Function success,
      Function error,
      paid = false,
      cod = false,
      transactionId = ''}) async {
    return null;
  }

  @override
  void placeOrder(context,
      {CartModel cartModel,
      PaymentMethod paymentMethod,
      Function onLoading,
      Function success,
      Function error}) {
    {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWebview(onFinish: (number) {
            success(number != null ? Order(number: number) : null);
          }, onClose: () {
            onLoading(false);
          }),
        ),
      );
    }
  }

  @override
  Map<dynamic, dynamic> getPaymentUrl(context) {
    return {
      'headers': {},
      'url': Provider.of<CartModel>(context, listen: false).checkout.webUrl
    };
  }

  @override
  Widget renderCartPageView({context, isModal, isBuyNow, pageController}) {
    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        MyCart(
          controller: pageController,
          isBuyNow: isBuyNow,
          isModal: isModal,
        ),
        Checkout(controller: pageController, isModal: isModal),
      ],
    );
  }

  @override
  void updateUserInfo(
      {User loggedInUser,
      context,
      onError,
      onSuccess,
      currentPassword,
      userDisplayName,
      userEmail,
      userNiceName,
      userUrl,
      userPassword}) {
    final names = userDisplayName.trim().split(' ');
    final firstName = names.first;
    final lastName = names.sublist(1).join(' ');
    final params = {
      'email': userEmail,
      'firstName': firstName,
      'lastName': lastName,
      'password': userPassword,
    };
    // if (!loggedInUser.isSocial && userPassword.isNotEmpty) {
    //   params["user_pass"] = userPassword;
    // }
    // if (!loggedInUser.isSocial && currentPassword.isNotEmpty) {
    //   params["current_pass"] = currentPassword;
    // }
    Services().api.updateUserInfo(params, loggedInUser.cookie).then((value) {
      params['cookie'] = loggedInUser.cookie;
      onSuccess(params ?? loggedInUser.toJson());
    }).catchError((e) {
      onError(e.toString());
    });
  }

  @override
  Widget renderVariantCartItem(variation, Map<String, dynamic> options) {
    var list = <Widget>[];
    for (var att in variation.attributes) {
      list.add(Row(
        children: <Widget>[
          ConstrainedBox(
            child: Text(
              '${att.name[0].toUpperCase()}${att.name.substring(1)} ',
            ),
            constraints: const BoxConstraints(minWidth: 50.0, maxWidth: 200),
          ),
          att.name == 'color'
              ? Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: HexColor(
                          kNameToHex[att.option.toLowerCase()],
                        ),
                      ),
                    ),
                  ),
                )
              : Expanded(
                  child: Text(
                  att.option,
                  textAlign: TextAlign.end,
                )),
        ],
      ));
      list.add(const SizedBox(
        height: 5.0,
      ));
    }

    return Column(children: list);
  }

  @override
  void loadShippingMethods(context, CartModel cartModel, bool beforehand) {
//    if (!beforehand) return;
    final cartModel = Provider.of<CartModel>(context, listen: false);
    Future.delayed(Duration.zero, () {
      final token = Provider.of<UserModel>(context, listen: false).user != null
          ? Provider.of<UserModel>(context, listen: false).user.cookie
          : null;
      Provider.of<ShippingMethodModel>(context, listen: false)
          .getShippingMethods(
              cartModel: cartModel,
              token: token,
              checkoutId: cartModel.getCheckoutId());
    });
  }

  @override
  Future<Order> cancelOrder(BuildContext context, Order order) async {
    return null;
  }

  @override
  String getPriceItemInCart(Product product, ProductVariation variation,
      currencyRate, String currency,
      {List<AddonsOption> selectedOptions}) {
    return
        // variation != null && variation.id != null
        //   ? Tools.getVariantPriceProductValue(variation, currencyRate, currency,
        //       onSale: true)
        //   :
        Tools.getPriceProduct(product, currencyRate, currency, onSale: true);
  }

  @override
  Future<List<Country>> loadCountries(BuildContext context) async {
    var countries = <Country>[];
    if (DefaultCountry != null && DefaultCountry.isNotEmpty) {
      for (var item in DefaultCountry) {
        countries.add(Country.fromConfig(
            item['iosCode'], item['name'], item['icon'], []));
      }
    }
    return countries;
  }

  @override
  Future<List<CountryState>> loadStates(Country country) async {
    final items = await Tools.loadStatesByCountry(country.id);
    var states = <CountryState>[];
    if (items != null && items.isNotEmpty) {
      for (var item in items) {
        states.add(CountryState.fromConfig(item));
      }
    }
    return states;
  }
}
