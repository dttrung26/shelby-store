import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:provider/provider.dart';

import '../../../../../../common/config.dart';
import '../../../../../../common/constants.dart';
import '../../../../../../common/tools.dart';
import '../../../../../../models/entities/listing_booking.dart';
import '../../../../../../models/user_model.dart';
import 'services.dart';

class TapPayment extends StatefulWidget {
  final Map<String, dynamic> params;
  final Function onFinish;
  final ListingBooking booking;
  TapPayment({this.params, this.onFinish, this.booking});

  @override
  State<StatefulWidget> createState() {
    return TapPaymentState();
  }
}

class TapPaymentState extends State<TapPayment> {
  String checkoutUrl;
  TapServices services = TapServices();

  @override
  void initState() {
    super.initState();
    final flutterWebviewPlugin = FlutterWebviewPlugin();
    flutterWebviewPlugin.onUrlChanged.listen((String url) async {
      if (url.startsWith('http://your_website.com/redirect_url')) {
        final uri = Uri.parse(url);
        final tapId = uri.queryParameters['tap_id'];
        if (tapId != null) {
          widget.onFinish(tapId);
        }
        Navigator.of(context).pop();
      }
    });

    Future.delayed(Duration.zero, () async {
      try {
        final params = getOrderParams();
        try {
          final url = await services.getCheckoutUrl(params);
          setState(() {
            checkoutUrl = url;
          });
        } catch (e) {
          Tools.showSnackBar(Scaffold.of(context), e.toString());
        }
      } catch (e) {
        Tools.showSnackBar(Scaffold.of(context), e.toString());
      }
    });
  }

  Map<String, dynamic> getOrderParams() {
    final user = Provider.of<UserModel>(context, listen: false).user;
    return {
      'amount': widget.booking.price,
      'currency': (kAdvanceConfig['DefaultCurrency'] as Map)['currency'],
      'threeDSecure': true,
      'save_card': false,
      'receipt': {'email': false, 'sms': true},
      'customer': {
        'first_name': user.firstName,
        'last_name': user.lastName,
        'email': user.email
      },
      'source': {'id': 'src_all'},
      'post': {'url': 'http://your_website.com/post_url'},
      'redirect': {'url': 'http://your_website.com/redirect_url'}
    };
  }

  @override
  Widget build(BuildContext context) {
    if (checkoutUrl != null) {
      return WebviewScaffold(
        url: checkoutUrl,
        appBar: AppBar(
            brightness: Theme.of(context).brightness,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            backgroundColor: Colors.white,
            elevation: 0.0),
        withZoom: true,
        withLocalStorage: true,
        hidden: true,
        initialChild: Container(child: kLoadingWidget(context)),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          brightness: Theme.of(context).brightness,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          backgroundColor: kGrey200,
          elevation: 0.0,
        ),
        body: Container(child: kLoadingWidget(context)),
      );
    }
  }
}
