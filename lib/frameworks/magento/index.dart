import 'package:flutter/material.dart';
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
        ListCountry,
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
import 'magento_payment.dart';
import 'magento_variant_mixin.dart';
import 'services/magento.dart';

class MagentoWidget extends BaseFrameworks
    with ProductVariantMixin, MagentoVariantMixin {
  static final MagentoWidget _instance = MagentoWidget._internal();

  factory MagentoWidget() => _instance;

  MagentoWidget._internal();

  @override
  bool get enableProductReview => false;

  @override
  Future<void> applyCoupon(context,
      {Coupons coupons, String code, Function success, Function error}) async {
    try {
      final cartModel = Provider.of<CartModel>(context, listen: false);
      final userModel = Provider.of<UserModel>(context, listen: false);
      await MagentoApi().addItemsToCart(
          cartModel, userModel.user != null ? userModel.user.cookie : null);
      final discountAmount = await MagentoApi().applyCoupon(
          userModel.user != null ? userModel.user.cookie : null, code);
      cartModel.discountAmount = discountAmount;
      success(Coupon.fromJson({
        'amount': discountAmount,
        'code': code,
        'discount_type': 'fixed_cart'
      }));
    } catch (err) {
      error(err.toString());
    }
  }

  @override
  Future<void> doCheckout(context,
      {Function success, Function error, Function loading}) async {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);
    try {
      await MagentoApi().addItemsToCart(
          cartModel, userModel.user != null ? userModel.user.cookie : null);
      if (cartModel.couponObj != null) {
        final discountAmount = await MagentoApi().applyCoupon(
            userModel.user != null ? userModel.user.cookie : null,
            cartModel.couponObj.code);
        cartModel.discountAmount = discountAmount;
      }
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
    final storage = LocalStorage('data_order');
    var listOrder = [];
    var isLoggedIn = Provider.of<UserModel>(context, listen: false).loggedIn;
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
      if (kMagentoPayments.contains(cartModel.paymentMethod.id)) {
        onLoading(false);
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MagentoPayment(
                    onFinish: (order) => success(order),
                    order: order,
                  )),
        );
      } else {
        success(order);
      }
    } catch (e, trace) {
      error(e.toString());
      printLog(trace.toString());
    }
  }

  @override
  void placeOrder(
    context, {
    CartModel cartModel,
    PaymentMethod paymentMethod,
    Function onLoading,
    Function success,
    Function error,
  }) {
    Provider.of<CartModel>(context, listen: false)
        .setPaymentMethod(paymentMethod);
    printLog(paymentMethod.id);

    createOrder(context,
        cod: true, onLoading: onLoading, success: success, error: error);
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
    if (currentPassword.isEmpty && !loggedInUser.isSocial) {
      onError('Please enter current password');
      return;
    }

    var params = {
      'user_id': loggedInUser.id,
      'display_name': userDisplayName,
      'user_email': userEmail,
      'user_nicename': userNiceName,
      'user_url': userUrl,
    };
    if (userEmail == loggedInUser.email && !loggedInUser.isSocial) {
      params['user_email'] = '';
    }
    if (!loggedInUser.isSocial && userPassword.isNotEmpty) {
      params['user_pass'] = userPassword;
    }
    if (!loggedInUser.isSocial && currentPassword.isNotEmpty) {
      params['current_pass'] = currentPassword;
    }
    Services().api.updateUserInfo(params, loggedInUser.cookie).then((value) {
      var param = value['data'] ?? value;
      param['password'] = userPassword;
      if (param['user_email'] == '') {
        param['user_email'] = loggedInUser.email;
      }
      onSuccess(param);
    }).catchError((e) {
      onError(e.toString());
    });
  }

  @override
  Widget renderCurrentPassInputforEditProfile(
      {BuildContext context, TextEditingController currentPasswordController}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(S.of(context).currentPassword,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            )),
        const SizedBox(
          height: 5,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                  color: Theme.of(context).primaryColorLight, width: 1.5)),
          child: TextField(
            obscureText: true,
            decoration: const InputDecoration(border: InputBorder.none),
            controller: currentPasswordController,
          ),
        ),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }

  @override
  Future<void> onLoadedAppConfig(String lang, Function callback) async {
    await MagentoApi().getAllAttributes();
    final countries = await MagentoApi().getCountries();
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
    final storage = LocalStorage('fstore');
    var countries = <Country>[];
    try {
      // save the user Info as local storage
      final ready = await storage.ready;
      if (ready) {
        final items = await storage.getItem(kLocalKey['countries']);
        countries = ListCountry.fromMagentoJson(items).list;
      }
    } catch (err) {
      printLog(err);
    }
    return countries;
  }

  @override
  Future<List<CountryState>> loadStates(Country country) async {
    return country.states ?? [];
  }

  @override
  Future<void> resetPassword(BuildContext context, String username) async {
    try {
      var isSuccess = await MagentoApi().resetPassword(username);
      if (isSuccess == true) {
        Tools.showSnackBar(
            Scaffold.of(context), 'Success Please Check Your Email');
        Future.delayed(
            const Duration(seconds: 2), () => Navigator.of(context).pop());
      } else {
        Tools.showSnackBar(Scaffold.of(context), 'Please Enter Correct Email');
      }
      return;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Product> getProductDetail(context, Product product) async {
    try {
      product.inStock = await MagentoApi().getStockStatus(product.sku);
      return product;
    } catch (e) {
      rethrow;
    }
  }

  @override
  void OnFinishOrder(
      BuildContext context, Function onSuccess, Order order) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MagentoPayment(
                onFinish: (order) {
                  onSuccess(order);
                },
                order: order,
              )),
    );
  }
}
