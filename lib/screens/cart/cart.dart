import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../models/app_model.dart';
import '../../services/index.dart';
import '../custom/smartchat.dart';

class CartScreen extends StatefulWidget {
  final bool isModal;
  final bool isBuyNow;
  final bool showChat;

  CartScreen({this.isModal, this.isBuyNow = false, this.showChat});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  @override
  Widget build(BuildContext context) {
    var showChat = widget.showChat ?? false;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      floatingActionButton: showChat
          ? SmartChat(
              margin: EdgeInsets.only(
                right: Provider.of<AppModel>(context, listen: false).langCode ==
                        'ar'
                    ? 30.0
                    : 0.0,
              ),
            )
          : Container(),
      body: Container(
        margin: EdgeInsets.only(top: kAdConfig['enable'] ? 80.0 : 0.0),
        child: SafeArea(
          top: true,
          bottom: false,
          child: Services().widget.renderCartPageView(
              isModal: widget.isModal,
              isBuyNow: widget.isBuyNow,
              pageController: pageController,
              context: context),
        ),
      ),
    );
  }
}
