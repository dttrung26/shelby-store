import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart';
import '../../screens/index.dart' show Checkout, MyCart;
import '../../services/index.dart' show Services;
import '../frameworks.dart';
import '../product_variant_mixin.dart';
import 'prestashop_variant_mixin.dart';
import 'services/prestashop.dart';

class PrestashopWidget extends BaseFrameworks
    with ProductVariantMixin, PrestashopVariantMixin {
  static final PrestashopWidget _instance = PrestashopWidget._internal();

  factory PrestashopWidget() => _instance;

  PrestashopWidget._internal();

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
    try {
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
    {
      createOrder(context,
          onLoading: onLoading, success: success, error: error);
    }
  }

  @override
  Map<String, dynamic> getPaymentUrl(context) {
    printLog('----here');
    printLog(Provider.of<CartModel>(context, listen: false).checkout.webUrl);
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
    onError('Coming soon!!!');
    return;
  }

  @override
  Widget renderVariantCartItem(variation, Map<String, dynamic> options) {
    var list = <Widget>[];
    for (var att in variation.attributes) {
      list.add(Row(
        children: <Widget>[
          ConstrainedBox(
            child: Text(
              // ignore: prefer_single_quotes
              "${att.name[0].toUpperCase()}${att.name.substring(1)} ",
            ),
            constraints: const BoxConstraints(minWidth: 50.0, maxWidth: 200),
          ),
          Expanded(
            child: Text(
              att.option,
              textAlign: TextAlign.end,
            ),
          ),
          const SizedBox(
            width: 20,
          )
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
      final products = cartModel.item;
      final productVariationInCart =
          cartModel.productVariationInCart.keys.toList();
      var productsId = <String>[];
      var attribute = <String>[];
      var productsQuantity = [];
      for (var key in products.keys.toList()) {
        if (productVariationInCart.toString().contains('$key-')) {
          for (var item in productVariationInCart) {
            if (item.contains('$key-') &&
                cartModel.productsInCart[item] != null) {
              productsId.add(key);
              attribute.add(item.replaceAll('$key-', ''));
              productsQuantity.add(cartModel.productsInCart[item]);
            }
          }
        } else {
          if (cartModel.productsInCart[key] == null) continue;
          productsId.add(key);
          attribute.add('-1');
          productsQuantity.add(cartModel.productsInCart[key]);
        }
      }
      Provider.of<ShippingMethodModel>(context, listen: false).getShippingMethods(
          cartModel: cartModel,
          token: token,
          checkoutId:
              'products=$productsId&quantity=${productsQuantity.toString()}&attribute=${attribute.toString()}');
    });
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
    } else {
      var _countries = await Prestashop().getCountries();
      for (var item in _countries) {
        countries.add(Country.fromPrestashop(Map<String, dynamic>.from(item)));
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
      var _states = await Prestashop().getStates(country.id_country);
      for (var item in _states) {
        states.add(CountryState.fromPrestashop(item));
      }
    }
    return states;
  }

  @override
  Widget renderOrderTimelineTracking(BuildContext context, Order order) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            S.of(context).status,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 15),
        FutureBuilder(
          future: Prestashop().getOrderStatus(order.id),
          builder: (context, snapshots) {
            if (!snapshots.hasData) return Container();
            return Column(
              children: List.generate(
                snapshots.data.length,
                (index) => Row(
                  children: [
                    const Icon(Icons.check_outlined, size: 14),
                    const SizedBox(width: 5),
                    Expanded(child: Text((snapshots.data)[index]['status'])),
                    Text(DateFormat('yyyy-MM-dd hh:mm').format(
                        DateTime.parse((snapshots.data)[index]['date_add'])))
                  ],
                ),
              ),
            );
          },
        )
      ],
    );
  }
}
