import 'dart:async';

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
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
        OrderModel,
        PaymentMethod,
        Product,
        ProductVariation,
        ShippingMethodModel,
        User,
        UserModel;
import '../../screens/index.dart' show Checkout, MyCart;
import '../../services/index.dart';
import '../frameworks.dart';
import '../product_variant_mixin.dart';
import 'strapi_variant_mixin.dart';

class StrapiWidget extends BaseFrameworks
    with ProductVariantMixin, StrapiVariantMixin {
  static final StrapiWidget _instance = StrapiWidget._internal();

  factory StrapiWidget() => _instance;

  StrapiWidget._internal();

  Map<String, dynamic> configCache;

  @override
  bool get enableProductReview => true;

  bool checkValidCoupon(context, Coupon coupon, String couponCode) {
    final totalCart =
        Provider.of<CartModel>(context, listen: false).getSubTotal();

    if ((coupon.minimumAmount > totalCart && coupon.minimumAmount != 0.0) ||
        (coupon.maximumAmount < totalCart && coupon.maximumAmount != 0.0)) {
      return false;
    }

    if (coupon.dateExpires != null &&
        coupon.dateExpires.isBefore(DateTime.now())) {
      return false;
    }

    return coupon.code == couponCode;
  }

  @override
  Future<void> applyCoupon(context,
      {Coupons coupons, String code, Function success, Function error}) async {
    var isExisted = false;
    for (var _coupon in coupons.coupons) {
      if (checkValidCoupon(context, _coupon, code.toLowerCase())) {
        success(_coupon);
        isExisted = true;
        break;
      }
    }
    if (!isExisted) {
      error(S.of(context).couponInvalid);
    }
  }

  @override
  Future<void> doCheckout(context,
      {Function success, Function error, Function loading}) async {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);

    if (kPaymentConfig['EnableOnePageCheckout']) {
      var params = Order().toJson(
          cartModel, userModel.user != null ? userModel.user.id : null, true);
      params['token'] = userModel.user != null ? userModel.user.cookie : null;
      // String url = await Services().getCheckoutUrl(params);
      //
      // /// Navigate to Webview payment
      // String orderNum;
      // await Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => PaymentWebview(
      //             url: url,
      //             onFinish: (number) async {
      //               orderNum = number;
      //               cartModel.clearCart();
      //             },
      //           )),
      // );
      // if (orderNum != null) {
      //   await Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => WebviewCheckoutSuccess(
      //               order: Order(number: orderNum),
      //             )),
      //   );
      // }
      return;
    }

    /// return success to navigate to Native payment
    success();
  }

  @override
  Future<void> createOrder(context,
      {Function onLoading,
      Function success,
      Function error,
      paid = false,
      cod = false,
      transactionId = ''}) async {
    var listOrder = [];
    var isLoggedIn = Provider.of<UserModel>(context, listen: false).loggedIn;
    final storage = LocalStorage('data_order');
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);

    try {
      final order = await Services()
          .api
          .createOrder(cartModel: cartModel, user: userModel, paid: paid);

      if (!isLoggedIn) {
        var items = storage.getItem('orders');
        if (items != null) {
          listOrder = items;
        }
        listOrder.add(order.toOrderJson(cartModel, null));
        await storage.setItem('orders', listOrder);
      }
      success(order);
    } catch (e) {
      error(e.toString());
    }
  }

  @override
  void placeOrder(context,
      {CartModel cartModel,
      PaymentMethod paymentMethod,
      Function onLoading,
      Function success,
      Function error}) {
    createOrder(context, onLoading: onLoading, success: success, error: error);
  }

  @override
  Map<String, dynamic> getPaymentUrl(context) {
    return null;
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
    var params = {
      'user_id': loggedInUser.id,
      'display_name': userDisplayName,
      'user_email': userEmail,
      'user_nicename': userNiceName,
      'user_url': userUrl,
    };
    if (!loggedInUser.isSocial && userPassword.isNotEmpty) {
      params['user_pass'] = userPassword;
    }
    if (!loggedInUser.isSocial && currentPassword.isNotEmpty) {
      params['current_pass'] = currentPassword;
    }
    Services().api.updateUserInfo(params, loggedInUser.cookie).then((value) {
      var param = value['data'] ?? value;
      param['password'] = userPassword;
      onSuccess(param);
    }).catchError((e) {
      onError(e.toString());
    });
  }

  @override
  Future<void> onLoadedAppConfig(String lang, Function callback) async {
    if (kAdvanceConfig['isCaching']) {
      final configCache = await Services().api.getHomeCache(lang);
      if (configCache != null) {
        callback(configCache);
      }
    }
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
//    final cartModel = Provider.of<CartModel>(context, listen: false);
    Future.delayed(Duration.zero, () {
      final token = Provider.of<UserModel>(context, listen: false).user != null
          ? Provider.of<UserModel>(context, listen: false).user.cookie
          : null;
      Provider.of<ShippingMethodModel>(context, listen: false)
          .getShippingMethods(cartModel: cartModel, token: token);
    });
  }

  @override
  Future<Order> cancelOrder(BuildContext context, Order order) async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (order.status == 'cancelled' || order.status == 'canceled') return order;
    final newOrder = await Services().api.updateOrder(order.id,
        status: 'cancelled', token: userModel.user.cookie);
    await Provider.of<OrderModel>(context, listen: false)
        .getMyOrder(userModel: userModel);
    return newOrder;
  }

  @override
  Widget renderButtons(
      BuildContext context, Order order, cancelOrder, createRefund) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: cancelOrder,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: (order.status == 'cancelled' ||
                            order.status == 'canceled')
                        ? Colors.blueGrey
                        : Colors.red),
                child: Text(
                  'Cancel'.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: createRefund,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: order.status == 'refunded'
                        ? Colors.blueGrey
                        : Colors.lightBlue),
                child: Text(
                  'Refunds'.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  String getPriceItemInCart(Product product, ProductVariation variation,
      Map<String, dynamic> currencyRate, String currency,
      {List<AddonsOption> selectedOptions}) {
    return variation != null && variation.id != null
        ? Tools.getVariantPriceProductValue(variation, currencyRate, currency,
            onSale: true)
        : Tools.getPriceProduct(product, currencyRate, currency, onSale: true);
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

  @override
  Future<void> resetPassword(BuildContext context, String username) async {
    final forgotPasswordUrl = Config().forgetPassword ??
        '${Config().url}/wp-login.php?action=lostpassword';

    var data = <String, dynamic>{'user_login': username};
    try {
      final val = await Provider.of<UserModel>(context, listen: false)
          .submitForgotPassword(forgotPwLink: forgotPasswordUrl, data: data);

      Tools.showSnackBar(Scaffold.of(context), val);

      if (val == 'Check your email for confirmation link') {
        Future.delayed(
            const Duration(seconds: 1), () => Navigator.of(context).pop());
      }
      return;
    } catch (e) {
      rethrow;
    }
  }
}
