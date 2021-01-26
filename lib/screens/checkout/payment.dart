import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show
        AppModel,
        CartModel,
        Order,
        BookingInfo,
        PaymentMethodModel,
        Product,
        TaxModel,
        UserModel;
import '../../services/index.dart';
import '../../widgets/payment/credit/index.dart';
import '../../widgets/payment/mercado_pago/index.dart';
import '../../widgets/payment/paypal/index.dart';
import '../../widgets/payment/stripe/index.dart';
import '../../widgets/payment/tap/index.dart';

class PaymentMethods extends StatefulWidget {
  final Function onBack;
  final Function onFinish;
  final Function(bool) onLoading;

  PaymentMethods({this.onBack, this.onFinish, this.onLoading});

  @override
  _PaymentMethodsState createState() => _PaymentMethodsState();
}

class _PaymentMethodsState extends State<PaymentMethods> {
  String selectedId;
  bool isPaying = false;
  final _razorpay = Razorpay();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      final cartModel = Provider.of<CartModel>(context, listen: false);
      final userModel = Provider.of<UserModel>(context, listen: false);
      Provider.of<PaymentMethodModel>(context, listen: false).getPaymentMethods(
          cartModel: cartModel,
          shippingMethod: cartModel.shippingMethod,
          token: userModel.user != null ? userModel.user.cookie : null);

      if (kPaymentConfig['EnableReview'] != true) {
        Provider.of<TaxModel>(context, listen: false).getTaxes(
            Provider.of<CartModel>(context, listen: false), (taxesTotal) {
          Provider.of<CartModel>(context, listen: false).taxesTotal =
              taxesTotal;
          setState(() {});
        });
      }
    });

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    createOrder(paid: true, transactionId: response.paymentId).then((value) {
      widget.onLoading(false);
      isPaying = false;
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    widget.onLoading(false);
    isPaying = false;
    Tools.showSnackBar(Scaffold.of(context), response.message);
    printLog(response.message);
  }

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    final paymentMethodModel = Provider.of<PaymentMethodModel>(context);
    final taxModel = Provider.of<TaxModel>(context);

    return ListenableProvider.value(
        value: paymentMethodModel,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(S.of(context).paymentMethods,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 5),
            Text(
              S.of(context).chooseYourPaymentMethod,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).accentColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            Consumer<PaymentMethodModel>(builder: (context, model, child) {
              if (model.isLoading) {
                return Container(height: 100, child: kLoadingWidget(context));
              }

              if (model.message != null) {
                return Container(
                  height: 100,
                  child: Center(
                      child: Text(model.message,
                          style: const TextStyle(color: kErrorRed))),
                );
              }

              if (selectedId == null && model.paymentMethods.isNotEmpty) {
                selectedId =
                    model.paymentMethods.firstWhere((item) => item.enabled).id;
              }

              return Column(
                children: <Widget>[
                  for (int i = 0; i < model.paymentMethods.length; i++)
                    model.paymentMethods[i].enabled
                        ? Column(
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedId = model.paymentMethods[i].id;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: model.paymentMethods[i].id ==
                                              selectedId
                                          ? Theme.of(context).primaryColorLight
                                          : Colors.transparent),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 10),
                                    child: Row(
                                      children: <Widget>[
                                        Radio(
                                            value: model.paymentMethods[i].id,
                                            groupValue: selectedId,
                                            onChanged: (i) {
                                              setState(() {
                                                selectedId = i;
                                              });
                                            }),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              if (Payments[model
                                                      .paymentMethods[i].id] !=
                                                  null)
                                                Image.asset(
                                                  Payments[model
                                                      .paymentMethods[i].id],
                                                  width: 120,
                                                  height: 30,
                                                ),
                                              if (Payments[model
                                                      .paymentMethods[i].id] ==
                                                  null)
                                                Services()
                                                    .widget
                                                    .renderShippingPaymentTitle(
                                                        context,
                                                        model.paymentMethods[i]
                                                            .title),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(height: 1)
                            ],
                          )
                        : Container()
                ],
              );
            }),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    S.of(context).subtotal,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor.withOpacity(0.8),
                    ),
                  ),
                  Text(
                      Tools.getCurrencyFormatted(
                          cartModel.getSubTotal(), currencyRate,
                          currency: cartModel.currency),
                      style: const TextStyle(fontSize: 14, color: kGrey400))
                ],
              ),
            ),
            Services().widget.renderShippingMethodInfo(context),
            if (cartModel.getCoupon() != '')
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      S.of(context).discount,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).accentColor.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      cartModel.getCoupon(),
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            fontSize: 14,
                            color:
                                Theme.of(context).accentColor.withOpacity(0.8),
                          ),
                    )
                  ],
                ),
              ),
            Services().widget.renderTaxes(taxModel, context),
            Services().widget.renderRewardInfo(context),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    S.of(context).total,
                    style: TextStyle(
                        fontSize: 16, color: Theme.of(context).accentColor),
                  ),
                  Text(
                    Tools.getCurrencyFormatted(
                        cartModel.getTotal(), currencyRate,
                        currency: cartModel.currency),
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: ButtonTheme(
                  height: 45,
                  child: RaisedButton(
                    elevation: 0,
                    onPressed: () => isPaying || selectedId == null
                        ? showSnackbar
                        : placeOrder(paymentMethodModel, cartModel),
                    textColor: Colors.white,
                    color: Theme.of(context).primaryColor,
                    child: Text(S.of(context).placeMyOrder.toUpperCase()),
                  ),
                ),
              ),
            ]),
            if (kPaymentConfig['EnableShipping'] ||
                kPaymentConfig['EnableAddress'] ||
                (kPaymentConfig['EnableReview'] ?? true))
              Center(
                child: FlatButton(
                  onPressed: () {
                    isPaying ? showSnackbar : widget.onBack();
                  },
                  child: Text(
                    (kPaymentConfig['EnableReview'] ?? true)
                        ? S.of(context).goBackToReview
                        : kPaymentConfig['EnableShipping']
                            ? S.of(context).goBackToShipping
                            : S.of(context).goBackToAddress,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 15,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
              )
          ],
        ));
  }

  void showSnackbar() {
    Tools.showSnackBar(
        Scaffold.of(context), S.of(context).orderStatusProcessing);
  }

  void placeOrder(paymentMethodModel, cartModel) {
    widget.onLoading(true);
    isPaying = true;
    if (paymentMethodModel.paymentMethods?.isNotEmpty ?? false) {
      final paymentMethod = paymentMethodModel.paymentMethods
          .firstWhere((item) => item.id == selectedId);

      Provider.of<CartModel>(context, listen: false)
          .setPaymentMethod(paymentMethod);

      /// Use Credit card
      if (kPaymentConfig['EnableCreditCard'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreditCardPayment(
              onFinish: (number) {
                if (number == null) {
                  widget.onLoading(false);
                  isPaying = false;
                  return;
                } else {
                  createOrder(paid: true).then((value) {
                    widget.onLoading(false);
                    isPaying = false;
                  });
                }
              },
            ),
          ),
        );

        return;
      }

      /// Use Native payment
      if (isNotBlank(PaypalConfig['paymentMethodId']) &&
          paymentMethod.id.contains(PaypalConfig['paymentMethodId']) &&
          PaypalConfig['enabled'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaypalPayment(
              onFinish: (number) {
                if (number == null) {
                  widget.onLoading(false);
                  isPaying = false;
                  return;
                } else {
                  createOrder(paid: true).then((value) {
                    widget.onLoading(false);
                    isPaying = false;
                  });
                }
              },
            ),
          ),
        );
      } else if (isNotBlank(MercadoPagoConfig['paymentMethodId']) &&
          paymentMethod.id.contains(MercadoPagoConfig['paymentMethodId']) &&
          MercadoPagoConfig['enabled'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MercadoPagoPayment(
              onFinish: (number) {
                if (number == null) {
                  widget.onLoading(false);
                  isPaying = false;
                  return;
                } else {
                  createOrder(paid: true).then((value) {
                    widget.onLoading(false);
                    isPaying = false;
                  });
                }
              },
            ),
          ),
        );
      } else if (isNotBlank(TapConfig['paymentMethodId']) &&
          paymentMethod.id.contains(TapConfig['paymentMethodId']) &&
          TapConfig['enabled'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TapPayment(onFinish: (number) {
                    if (number != null) {
                      createOrder(paid: true);
                    }
                    isPaying = false;
                    widget.onLoading(false);
                  })),
        );
      } else if (isNotBlank(kStripeConfig['paymentMethodId']) &&
          paymentMethod.id.contains(kStripeConfig['paymentMethodId']) &&
          kStripeConfig['enabled'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StripePayment(
              onFinish: (success) {
                if (success == true) {
                  createOrder(paid: true).then((value) {
                    widget.onLoading(false);
                    isPaying = false;
                  });
                } else {
                  widget.onLoading(false);
                  isPaying = false;
                  return;
                }
              },
            ),
          ),
        );
      } else if (paymentMethod.id.contains(RazorpayConfig['paymentMethodId']) &&
          RazorpayConfig['enabled'] == true) {
        Services().api.createRazorpayOrder({
          'amount': (cartModel.getTotal() * 100).toInt().toString(),
          'currency': 'INR'
        }).then((value) {
          var options = {
            'key': RazorpayConfig['keyId'],
            'amount': (cartModel.getTotal() * 100).toInt(),
            'name':
                cartModel.address.firstName + ' ' + cartModel.address.lastName,
            'currency': 'INR',
            'prefill': {
              'contact': cartModel.address.phoneNumber,
              'email': cartModel.address.email
            }
          };
          if (value != null) {
            options['order_id'] = value;
          }
          _razorpay.open(options);
        }).catchError((e) {
          widget.onLoading(false);
          Tools.showSnackBar(Scaffold.of(context), e);
          isPaying = false;
        });
      } else if (isNotBlank(MercadoPagoConfig['paymentMethodId']) &&
          paymentMethod.id.contains(MercadoPagoConfig['paymentMethodId']) &&
          MercadoPagoConfig['enabled'] == true) {
      } else {
        /// Use WebView Payment per frameworks

        Services().widget.placeOrder(
          context,
          cartModel: cartModel,
          onLoading: widget.onLoading,
          paymentMethod: paymentMethod,
          success: (Order order) async {
            if (order != null) {
              for (var item in order.lineItems) {
                Product product = cartModel.getProductById(item.productId);
                if (product?.bookingInfo != null) {
                  product.bookingInfo.idOrder = order.id;
                  var booking = await createBooking(product.bookingInfo);

                  Tools.showSnackBar(Scaffold.of(context),
                      booking ? 'Booking success!' : 'Booking error!');
                }
              }
              widget.onFinish(order);
            }
            widget.onLoading(false);
            isPaying = false;
          },
          error: (message) {
            widget.onLoading(false);
            if (message != null) {
              Tools.showSnackBar(Scaffold.of(context), message);
            }

            isPaying = false;
          },
        );
      }
    }
  }

  Future<bool> createBooking(BookingInfo bookingInfo) async {
    return Services().api.createBooking(bookingInfo);
  }

  Future<void> createOrder(
      {paid = false, cod = false, transactionId = ''}) async {
    widget.onLoading(true);
    await Services().widget.createOrder(
      context,
      paid: paid,
      cod: cod,
      transactionId: transactionId,
      onLoading: widget.onLoading,
      success: (Order order) async {
        await Services()
            .api
            .updateOrderIdForRazorpay(transactionId, order.number);
        widget.onFinish(order);
      },
      error: (message) {
        Tools.showSnackBar(Scaffold.of(context), message);
      },
    );
    widget.onLoading(false);
  }
}
