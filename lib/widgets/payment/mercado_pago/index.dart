import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../common/constants.dart';
import '../../../models/index.dart' show AppModel, CartModel, Product;
import 'services.dart';

class MercadoPagoPayment extends StatefulWidget {
  final Function onFinish;

  MercadoPagoPayment({this.onFinish});

  @override
  State<StatefulWidget> createState() {
    return MercadoPagoPaymentState();
  }
}

class MercadoPagoPaymentState extends State<MercadoPagoPayment> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MercadoPagoServices _services = MercadoPagoServices();
  String url;
  String id = '';
  Map<String, dynamic> getOrderParams() {
    var cartModel = Provider.of<CartModel>(context, listen: false);
    final currency = Provider.of<AppModel>(context, listen: false).currency;
    List items = cartModel.productsInCart.keys.map(
      (key) {
        var productId = Product.cleanProductID(key);

        final product = cartModel.getProductById(productId);
        final variation = cartModel.getProductVariationById(key);
        final price = variation != null ? variation.price : product.price;

        return {
          'title': product.name,
          'description': '',
          'quantity': cartModel.productsInCart[key],
          'unit_price': double.parse(price),
          'currency_id': currency
        };
      },
    ).toList();

    var temp = <String, dynamic>{
      'items': items,
    };

    return temp;
  }

  Future<void> customWebViewListener(WebViewController _controller) async {
    var currentUrl = await _controller.currentUrl();
    if (currentUrl.contains('congrats/approved')) {
      widget.onFinish(id);
      Navigator.of(context).pop();
    } else {
      await Future.delayed(const Duration(seconds: 2))
          .then((value) => customWebViewListener(_controller));
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var map = await _services.getPaymentUrl(getOrderParams());
      url = map['paymentUrl'];
      id = map['orderId'];
      if (url == null) {
        return;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (url != null) {
      return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          leading: GestureDetector(
            onTap: () {
              widget.onFinish(null);
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios),
          ),
        ),
        body: WebView(
          initialUrl: url,
          onWebViewCreated: customWebViewListener,
          javascriptMode: JavascriptMode.unrestricted,
          navigationDelegate: (NavigationRequest request) {
            if (request.url.contains('congrats/approved')) {
              widget.onFinish(id);
              Navigator.of(context).pop();
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              widget.onFinish(null);
              Navigator.of(context).pop();
            }),
        backgroundColor: kGrey200,
        elevation: 0.0,
      ),
      body: Container(child: kLoadingWidget(context)),
    );
  }
}
