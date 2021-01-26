import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import '../../common/config.dart' show kPaymentConfig;
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/cart/cart_model.dart';
import '../../models/shipping_method_model.dart';
import '../../services/index.dart';

class ShippingMethods extends StatefulWidget {
  final Function onBack;
  final Function onNext;

  ShippingMethods({this.onBack, this.onNext});

  @override
  _ShippingMethodsState createState() => _ShippingMethodsState();
}

class _ShippingMethodsState extends State<ShippingMethods> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration.zero,
      () async {
        final shippingMethod =
            Provider.of<CartModel>(context, listen: false).shippingMethod;
        final shippingMethods =
            Provider.of<ShippingMethodModel>(context, listen: false)
                .shippingMethods;
        if (shippingMethods != null &&
            shippingMethods.isNotEmpty &&
            shippingMethod != null) {
          final index = shippingMethods
              .indexWhere((element) => element.id == shippingMethod.id);
          if (index > -1) {
            setState(() {
              selectedIndex = index;
            });
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final shippingMethodModel = Provider.of<ShippingMethodModel>(context);
    final currency = Provider.of<CartModel>(context).currency;
    final currencyRates = Provider.of<CartModel>(context).currencyRates;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          S.of(context).shippingMethod,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        ListenableProvider.value(
          value: shippingMethodModel,
          child: Consumer<ShippingMethodModel>(
            builder: (context, model, child) {
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

              return Column(
                children: <Widget>[
                  for (int i = 0; i < model.shippingMethods.length; i++)
                    Column(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: i == selectedIndex
                                ? Theme.of(context).primaryColorLight
                                : Colors.transparent,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            child: Row(
                              children: <Widget>[
                                Radio(
                                  value: i,
                                  groupValue: selectedIndex,
                                  onChanged: (i) {
                                    setState(() {
                                      selectedIndex = i;
                                    });
                                  },
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Services()
                                          .widget
                                          .renderShippingPaymentTitle(context,
                                              model.shippingMethods[i].title),
                                      const SizedBox(height: 5),
                                      if (model.shippingMethods[i].cost > 0.0 ||
                                          !isNotBlank(model
                                              .shippingMethods[i].classCost))
                                        Text(
                                          Tools.getCurrencyFormatted(
                                              model.shippingMethods[i].cost,
                                              currencyRates,
                                              currency: currency),
                                          style: const TextStyle(
                                              fontSize: 14, color: kGrey400),
                                        ),
                                      if (model.shippingMethods[i].cost ==
                                              0.0 &&
                                          isNotBlank(model
                                              .shippingMethods[i].classCost))
                                        Text(
                                          model.shippingMethods[i].classCost,
                                          style: const TextStyle(
                                              fontSize: 14, color: kGrey400),
                                        )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        i < model.shippingMethods.length - 1
                            ? const Divider(height: 1)
                            : Container()
                      ],
                    )
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ButtonTheme(
                height: 45,
                child: RaisedButton(
                  elevation: 0,
                  onPressed: () {
                    if (shippingMethodModel.shippingMethods?.isNotEmpty ??
                        false) {
                      Provider.of<CartModel>(context, listen: false)
                          .setShippingMethod(shippingMethodModel
                              .shippingMethods[selectedIndex]);
                      widget.onNext();
                    }
                  },
                  textColor: Colors.white,
                  color: Theme.of(context).primaryColor,
                  child: Text(((kPaymentConfig['EnableReview'] ?? true)
                          ? S.of(context).continueToReview
                          : S.of(context).continueToPayment)
                      .toUpperCase()),
                ),
              ),
            ),
          ],
        ),
        if (kPaymentConfig['EnableAddress'])
          Center(
            child: FlatButton(
              onPressed: () {
                widget.onBack();
              },
              child: Text(
                S.of(context).goBackToAddress,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 15,
                    color: kGrey400),
              ),
            ),
          )
      ],
    );
  }
}
