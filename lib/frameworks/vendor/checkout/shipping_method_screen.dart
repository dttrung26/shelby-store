import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart'
    show
        AppModel,
        CartModel,
        ShippingMethod,
        Store,
        VendorShippingMethod,
        VendorShippingMethodModel;

class ShippingMethods extends StatefulWidget {
  final Function onBack;
  final Function onNext;

  ShippingMethods({this.onBack, this.onNext});

  @override
  _ShippingMethodsState createState() => _ShippingMethodsState();
}

class _ShippingMethodsState extends State<ShippingMethods> {
  Map<String, int> selectedMethods = {};

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final shippingMethodModel =
          Provider.of<VendorShippingMethodModel>(context, listen: false);
      final cartModel = Provider.of<CartModel>(context, listen: false);
      cartModel.selectedShippingMethods.forEach((selected) {
        shippingMethodModel.list.forEach((element) {
          if (selected.store.id == element.store.id) {
            for (var i = 0; i < element.shippingMethods.length; i++) {
              if (element.shippingMethods[i].id ==
                  selected.shippingMethods[0].id) {
                setState(() {
                  selectedMethods[selected.store.id.toString()] = i;
                });
              }
            }
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final shippingMethodModel = Provider.of<VendorShippingMethodModel>(context);

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
          child: Consumer<VendorShippingMethodModel>(
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
                  for (int i = 0; i < model.list.length; i++)
                    if (model.list[i].shippingMethods?.isNotEmpty ?? false)
                      Column(
                        children: <Widget>[
                          if (model.list[i].store != null &&
                              kVendorConfig['DisableVendorShipping'] != true)
                            Container(
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColorLight),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.store,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    if (!isBlank(model.list[i].store.name))
                                      Text(
                                        model.list[i].store.name,
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).accentColor,
                                            fontSize: 18),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          renderShippingMethods(model.list[i].store,
                              model.list[i].shippingMethods)
                        ],
                      ),
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
                    if (selectedMethods.values.toList().isNotEmpty &&
                        selectedMethods.values.toList().length ==
                            shippingMethodModel.list.length) {
                      var list = <VendorShippingMethod>[];
                      shippingMethodModel.list.forEach((element) {
                        list.add(VendorShippingMethod(element.store, [
                          element.shippingMethods[selectedMethods[
                              element.store != null
                                  ? element.store.id.toString()
                                  : '-1']]
                        ]));
                      });
                      Provider.of<CartModel>(context, listen: false)
                          .setSelectedMethods(list);
                      widget.onNext();
                    }
                  },
                  textColor: Colors.white,
                  color: Theme.of(context).primaryColor,
                  child: Text(S.of(context).continueToReview.toUpperCase()),
                ),
              ),
            ),
          ],
        ),
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

  Widget renderShippingMethods(
      Store store, List<ShippingMethod> shippingMethods) {
    final currency = Provider.of<CartModel>(context, listen: false).currency;
    final currencyRate =
        Provider.of<AppModel>(context, listen: false).currencyRate;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < shippingMethods.length; i++)
            Column(
              children: <Widget>[
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
                    child: Row(
                      children: <Widget>[
                        Radio(
                          value: i,
                          groupValue: store != null &&
                                  selectedMethods[store.id.toString()] != null
                              ? selectedMethods[store.id.toString()]
                              : selectedMethods['-1'],
                          onChanged: (i) {
                            setState(() {
                              selectedMethods[store != null
                                  ? store.id.toString()
                                  : '-1'] = i;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(shippingMethods[i].title,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).accentColor)),
                              const SizedBox(height: 5),
                              if (shippingMethods[i].cost > 0.0 ||
                                  !isNotBlank(shippingMethods[i].classCost))
                                Text(
                                  Tools.getCurrencyFormatted(
                                      shippingMethods[i].cost, currencyRate,
                                      currency: currency),
                                  style: const TextStyle(
                                      fontSize: 14, color: kGrey400),
                                ),
                              if (shippingMethods[i].cost == 0.0 &&
                                  isNotBlank(shippingMethods[i].classCost))
                                Text(
                                  shippingMethods[i].classCost,
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
                i < shippingMethods.length - 1
                    ? const Divider(height: 1)
                    : Container()
              ],
            )
        ],
      ),
    );
  }
}
