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
        AppModel,
        CartModel,
        Country,
        CountryState,
        Coupons,
        Discount,
        ListCountry,
        Order,
        OrderModel,
        PaymentMethod,
        Product,
        ProductVariation,
        ShippingMethodModel,
        TaxModel,
        User,
        UserModel;
import '../../screens/index.dart'
    show Checkout, MyCart, PaymentWebview, WebviewCheckoutSuccess;
import '../../services/index.dart';
import '../frameworks.dart';
import '../product_variant_mixin.dart';
import 'product_addons_mixin.dart';
import 'woo_variant_mixin.dart';

class WooWidget extends BaseFrameworks
    with ProductVariantMixin, WooVariantMixin, ProductAddonsMixin {
  @override
  bool get enableProductReview => true;

  Future<Discount> checkValidCoupon(
      BuildContext context, String couponCode) async {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final discount = await Coupons.getDiscount(
      cartModel: cartModel,
      couponCode: couponCode,
    );

    if (discount?.discount != null) {
      await cartModel.updateDiscount(discount: discount);
      return discount;
    }

    return null;
  }

  @override
  Future<void> applyCoupon(context,
      {Coupons coupons, String code, Function success, Function error}) async {
    try {
      final discount = await checkValidCoupon(context, code.toLowerCase());
      if (discount != null) {
        success(discount);
        return;
      }
    } catch (err) {
      error(err.toString());
      return;
    }
    error(S.of(context).couponInvalid);
  }

  @override
  Future<void> doCheckout(BuildContext context,
      {Function success, Function error, Function loading}) async {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);

    if (kPaymentConfig['EnableOnePageCheckout']) {
      loading(true);
      var params = Order().toJson(
          cartModel, userModel.user != null ? userModel.user.id : null, true);
      params['token'] = userModel.user != null ? userModel.user.cookie : null;
      var url = await Services().api.getCheckoutUrl(
          params, Provider.of<AppModel>(context, listen: false).langCode);
      loading(false);

      /// Navigate to Webview payment
      String orderNum;
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PaymentWebview(
                  url: url,
                  onFinish: (number) async {
                    orderNum = number;
                  },
                )),
      );
      if (orderNum != null) {
        cartModel.clearCart();
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebviewCheckoutSuccess(
                    order: Order(number: orderNum),
                  )),
        );
      }
      return;
    }

    /// return success to navigate to Native payment
    success();
  }

  @override
  Future<void> createOrder(BuildContext context,
      {Function onLoading,
      Function success,
      Function error,
      bool paid = false,
      bool cod = false,
      String transactionId = ''}) async {
    var listOrder = [];
    var isLoggedIn = Provider.of<UserModel>(context, listen: false).loggedIn;
    final storage = LocalStorage('data_order');
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);

    try {
      final order = await Services().api.createOrder(
          cartModel: cartModel,
          user: userModel,
          paid: paid,
          transactionId: transactionId);

      if (cod && kPaymentConfig['UpdateOrderStatus']) {
        await Services().api.updateOrder(order.id, status: 'processing');
      }
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
      printLog(e.toString());
      printLog(trace.toString());
      if (error != null) {
        error(e.toString());
      }
    }
  }

  @override
  void placeOrder(context,
      {CartModel cartModel,
      PaymentMethod paymentMethod,
      Function onLoading,
      Function success,
      Function error}) {
    Provider.of<CartModel>(context, listen: false)
        .setPaymentMethod(paymentMethod);

    if (paymentMethod.id == 'cod') {
      createOrder(context,
          cod: true, onLoading: onLoading, success: success, error: error);
    } else {
      final user = Provider.of<UserModel>(context, listen: false).user;
      var params =
          Order().toJson(cartModel, user != null ? user.id : null, true);
      params['token'] = user != null ? user.cookie : null;
      makePaymentWebview(context, params, onLoading, success, error);
    }
  }

  Future<void> makePaymentWebview(context, Map<String, dynamic> params,
      Function onLoading, Function success, Function error) async {
    try {
      if (params['token'] == null &&
          !kPaymentConfig['NativeOnePageCheckout'] &&
          !kPaymentConfig['EnableOnePageCheckout']) {
        Tools.showSnackBar(Scaffold.of(context),
            "Payment Webview doesn't support Guest Checkout");
        return;
      }
      onLoading(true);

      var url = await Services().api.getCheckoutUrl(
          params, Provider.of<AppModel>(context, listen: false).langCode);
      onLoading(false);
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PaymentWebview(
                url: url,
                onFinish: (number) {
                  success(number != null ? Order(number: number) : null);
                })),
      );
    } catch (e, trace) {
      error(e.toString());
      printLog(trace.toString());
    }
  }

  @override
  Map<String, dynamic> getPaymentUrl(context) {
    return null;
  }

  @override
  Widget renderCartPageView(
      {BuildContext context,
      bool isModal,
      bool isBuyNow,
      PageController pageController}) {
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
    final countries = await Services().api.getCountries();
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

    if (kAdvanceConfig['isCaching']) {
      final configCache = await Services().api.getHomeCache(lang);
      if (configCache != null) {
        callback(configCache);
      }
    }
  }

  Widget renderVariantItem(String name, String option) {
    return Row(
      children: <Widget>[
        ConstrainedBox(
          child: Text(
            // ignore: prefer_single_quotes
            "${name[0].toUpperCase()}${name.substring(1)} ",
          ),
          constraints: const BoxConstraints(minWidth: 50.0, maxWidth: 200),
        ),
        name == 'color'
            ? Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: HexColor(
                        kNameToHex[option.toLowerCase()],
                      ),
                    ),
                  ),
                ),
              )
            : Expanded(
                child: Text(
                  option,
                  textAlign: TextAlign.end,
                ),
              ),
      ],
    );
  }

  @override
  Widget renderVariantCartItem(variation, Map<String, dynamic> options) {
    var list = <Widget>[];
    if (options != null && options.isNotEmpty) {
      for (var key in options.keys) {
        list.add(renderVariantItem(key, '${options[key]}'));
        list.add(const SizedBox(
          height: 5.0,
        ));
      }
    } else if (variation != null) {
      for (var att in variation.attributes) {
        list.add(renderVariantItem(att.name, att.option));
        list.add(const SizedBox(
          height: 5.0,
        ));
      }
    }

    return Column(children: list);
  }

  @override
  Widget renderAddonsOptionsCartItem(
      context, List<AddonsOption> selectedOptions) {
    if (selectedOptions?.isEmpty ?? true) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Text(
        selectedOptions.map((e) => e.label).join(', '),
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
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
                  S.of(context).cancel.toString().toUpperCase(),
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
                  S.of(context).refunds.toString().toUpperCase(),
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
    if ((selectedOptions?.isNotEmpty ?? false)) {
      return Tools.getAddsOnPriceProductValue(
          product, selectedOptions, currencyRate, currency,
          onSale: true);
    }
    return variation != null && variation.id != null
        ? Tools.getVariantPriceProductValue(variation, currencyRate, currency,
            onSale: true)
        : Tools.getPriceProduct(product, currencyRate, currency, onSale: true);
  }

  @override
  Future<List<Country>> loadCountries(BuildContext context) async {
    final storage = LocalStorage('fstore');
    var countries = <Country>[];
    if (DefaultCountry != null && DefaultCountry.isNotEmpty) {
      for (var item in DefaultCountry) {
        countries.add(Country.fromConfig(
            item['iosCode'], item['name'], item['icon'], []));
      }
    } else {
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
    } else {
      try {
        final items = await Services().api.getStatesByCountryId(country.id);
        if (items != null && items.isNotEmpty) {
          for (var item in items) {
            states.add(CountryState.fromWooJson(item));
          }
        }
      } catch (e) {
        printLog(e.toString());
      }
    }
    return states;
  }

  @override
  Future<void> resetPassword(BuildContext context, String username) async {
    try {
      final val = await Provider.of<UserModel>(context, listen: false)
          .submitForgotPassword(
              forgotPwLink: '', data: {'user_login': username});
      if (val.isEmpty) {
        Tools.showSnackBar(
            Scaffold.of(context), S.of(context).checkConfirmLink);
        Future.delayed(
            const Duration(seconds: 1), () => Navigator.of(context).pop());
      } else {
        Tools.showSnackBar(Scaffold.of(context), val);
      }
      return;
    } catch (e) {
      printLog(e);
      return 'Unknown Error: $e';
    }
  }

  @override
  Future<void> syncCartFromWebsite(String token, BuildContext context) async {
    try {
      List items = await Services().api.getCartInfo(token);
      if (items != null && items.isNotEmpty) {
        final cartModel = Provider.of<CartModel>(context, listen: false);
        cartModel.clearCart();
        List<Map<String, dynamic>>.from(items).forEach((item) {
          cartModel.addProductToCart(
              context: context,
              product: Product.fromJson(item['product']),
              quantity: item['quantity'],
              variation: item['variation'] != null
                  ? ProductVariation.fromJson(item['variation'])
                  : null);
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> syncCartToWebsite(CartModel cartModel) {
    if (kAdvanceConfig['EnableSyncCartToWebsite'] == true) {
      return Services().api.syncCartToWebsite(cartModel, cartModel.user);
    }
    return null;
  }

  @override
  Widget renderTaxes(TaxModel taxModel, BuildContext context) {
    final currencyRate =
        Provider.of<AppModel>(context, listen: false).currencyRate;
    final currency = Provider.of<CartModel>(context, listen: false).currency;

    if (taxModel.taxes != null && taxModel.taxes.isNotEmpty) {
      var list = <Widget>[];
      taxModel.taxes.forEach((element) {
        list.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              element.title,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).accentColor,
              ),
            ),
            Text(
              Tools.getCurrencyFormatted(element.amount, currencyRate,
                  currency: currency),
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                    fontSize: 14,
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.w600,
                  ),
            )
          ],
        ));
      });

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Column(
          children: list,
        ),
      );
    } else if (taxModel.taxesTotal > 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              S.of(context).tax,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).accentColor,
              ),
            ),
            Text(
              Tools.getCurrencyFormatted(taxModel.taxesTotal, currencyRate,
                  currency: currency),
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                    fontSize: 14,
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.w600,
                  ),
            )
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
