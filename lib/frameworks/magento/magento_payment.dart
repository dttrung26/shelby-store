import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../models/index.dart';
import '../../services/index.dart' show Config;

class MagentoPayment extends StatefulWidget {
  final Order order;
  final Function onFinish;

  MagentoPayment({this.order, this.onFinish});

  @override
  State<StatefulWidget> createState() {
    return MagentoPaymentState();
  }
}

class MagentoPaymentState extends State<MagentoPayment> {
  @override
  void initState() {
    super.initState();
    final flutterWebviewPlugin = FlutterWebviewPlugin();
    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      printLog('MagentoPaymentState URL: ' + url);
      if (url.contains('mspayment/resolver/notify')) {
        final uri = Uri.parse(url);
        final status = uri.queryParameters['status'];
        if (status == 'success') {
          widget.onFinish(widget.order);
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var checkoutUrl = '';
    final paymentMethod = Provider.of<CartModel>(context).paymentMethod.id;
    if (paymentMethod == 'HyperPay_SadadPayware') {
      checkoutUrl = Config().url +
          '/mspayment/resolver_hyperpay/sadad?order_id=' +
          widget.order.number;
    } else {
      checkoutUrl = Config().url +
          '/mspayment/resolver_hyperpay/request?order_id=' +
          widget.order.number;
    }

    return WebviewScaffold(
      withJavascript: true,
      appCacheEnabled: true,
      url: checkoutUrl,
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
      withZoom: true,
      withLocalStorage: true,
      hidden: true,
      initialChild: Container(child: kLoadingWidget(context)),
    );
  }
}
