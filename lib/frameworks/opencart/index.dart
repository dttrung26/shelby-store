import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

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
        Discount,
        ListCountry,
        Order,
        OrderModel,
        PaymentMethod,
        Product,
        ProductVariation,
        ShippingMethodModel,
        User,
        UserModel;
import '../../screens/index.dart' show Checkout, MyCart, PaymentWebview;
import '../../services/index.dart';
import '../frameworks.dart';
import '../product_variant_mixin.dart';
import 'opencart_variant_mixin.dart';
import 'services/opencart.dart';

class OpencartWidget extends BaseFrameworks
    with ProductVariantMixin, OpencartVariantMixin {
  static final OpencartWidget _instance = OpencartWidget._internal();

  factory OpencartWidget() => _instance;

  OpencartWidget._internal();

  @override
  bool get enableProductReview => true;

  Future<Discount> checkValidCoupon(
      BuildContext context, Coupon coupon, String couponCode) async {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    Discount discount;
    if (coupon.code == couponCode) {
      discount = Discount(coupon: coupon, discount: coupon.amount);
    }
    if (discount?.discount != null) {
      await cartModel.updateDiscount(discount: discount);
    }

    return discount;
  }

  @override
  Future<void> applyCoupon(context,
      {Coupons coupons, String code, Function success, Function error}) async {
    var isExisted = false;
    for (var _coupon in coupons.coupons) {
      var discount =
          await checkValidCoupon(context, _coupon, code.toLowerCase());
      if (discount != null) {
        success(discount);
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
    try {
      await OpencartApi().addItemsToCart(
          cartModel, userModel.user != null ? userModel.user.cookie : null);
      success();
    } catch (e, trace) {
      error(e.toString());
      printLog(trace.toString());
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
    var listOrder = [];
    var isLoggedIn = Provider.of<UserModel>(context, listen: false).loggedIn;
    final storage = LocalStorage('data_order');
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);

    try {
      onLoading(true);
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
    } catch (e, trace) {
      error(e.toString());
      printLog(trace.toString());
    }
  }

  @override
  void placeOrder(context,
      {CartModel cartModel,
      PaymentMethod paymentMethod,
      Function onLoading,
      Function success,
      Function error}) {
    if (paymentMethod.id == 'cod') {
      createOrder(context,
          cod: true, onLoading: onLoading, success: success, error: error);
    } else {
      onLoading(false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWebview(onFinish: (number) {
            success(number != null ? Order(number: number) : null);
          }),
        ),
      );
    }
  }

  @override
  Map<String, dynamic> getPaymentUrl(context) {
    var sessionId =
        OpencartApi().cookie.split(';')[0].replaceAll('OCSESSID=', '');
    return {
      'url': Config().url +
          '/index.php?route=extension/mstore/payment/paymentWebview&session_id=' +
          sessionId
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
      onSuccess(value);
    }).catchError((e) {
      onError(e.toString());
    });
  }

  @override
  Future<void> onLoadedAppConfig(String lang, Function callback) async {
    final countries = await OpencartApi().getCountries();
    final storage = LocalStorage('fstore');
    try {
      // save the user Info as local storage
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem(kLocalKey['countries'], countries);
      }
    } catch (err) {
      printLog(err);
    }
    return;
  }

  @override
  Widget renderVariantCartItem(variation, Map<String, dynamic> options) {
    return Container();
  }

  @override
  void loadShippingMethods(context, CartModel cartModel, bool beforehand) {
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
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (order.status == 'cancelled' || order.status == 'canceled') return order;
    await Services().api.updateOrder(order.id,
        status: 'cancelled', token: userModel.user.cookie);
    order.status = 'canceled';
    await Provider.of<OrderModel>(context, listen: false)
        .getMyOrder(userModel: userModel);
    return order;
  }

  @override
  String getPriceItemInCart(Product product, ProductVariation variation,
      Map<String, dynamic> currencyRate, String currency,
      {List<AddonsOption> selectedOptions}) {
    return Tools.getCurrencyFormatted(product.price, currencyRate,
        currency: currency);
  }

  @override
  Future<List<Country>> loadCountries(BuildContext context) async {
    final storage = LocalStorage('fstore');
    var countries = <Country>[];
    try {
      // save the user Info as local storage
      final ready = await storage.ready;
      if (ready) {
        final items = await storage.getItem(kLocalKey['countries']);
        countries = ListCountry.fromOpencartJson(items).list;
      }
    } catch (err) {
      printLog(err);
    }
    return countries;
  }

  @override
  Future<List<CountryState>> loadStates(Country country) async {
    final items = await OpencartApi().getStatesByCountryId(country.id);
    var states = <CountryState>[];
    if (items != null && items.isNotEmpty) {
      for (var item in items) {
        states.add(CountryState.fromOpencartJson(item));
      }
    }
    return states;
  }

  @override
  Future<void> resetPassword(BuildContext context, String username) {
    throw Exception('No Support');
  }

  @override
  Widget renderShippingPaymentTitle(BuildContext context, String title) {
    return Html(
      data: title,
      style: {
        'img': Style(height: 30),
      },
    );
  }

  @override
  Future<String> getCountryName(context, countryCode) async {
    try {
      var countries = await loadCountries(context);
      var country = countries.firstWhere((element) => element.id == countryCode,
          orElse: () => null);
      return country != null ? country.name : countryCode;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Widget renderOrderTimelineTracking(BuildContext context, Order order) {
    return Container();
  }
}
