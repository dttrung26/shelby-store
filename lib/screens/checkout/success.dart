import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../models/index.dart' show Order, UserModel, PointModel;
import '../../screens/base.dart';
import '../../services/index.dart';

class OrderedSuccess extends StatefulWidget {
  final Order order;
  final bool isModal;
  final PageController controller;

  OrderedSuccess({this.order, this.isModal, this.controller});

  @override
  _OrderedSuccessState createState() => _OrderedSuccessState();
}

class _OrderedSuccessState extends BaseScreen<OrderedSuccess> {
  @override
  void afterFirstLayout(BuildContext context) {
    final user = Provider.of<UserModel>(context, listen: false).user;
    if (user != null && user.cookie != null) {
      Services().api.updatePoints(user.cookie, widget.order);
      Provider.of<PointModel>(context, listen: false).getMyPoint(user.cookie);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

    return ListView(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(color: Theme.of(context).primaryColorLight),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  S.of(context).itsOrdered,
                  style: TextStyle(
                      fontSize: 16, color: Theme.of(context).accentColor),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      S.of(context).orderNo,
                      style: TextStyle(
                          fontSize: 14, color: Theme.of(context).accentColor),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        '#${widget.order.number}',
                        style: TextStyle(
                            fontSize: 14, color: Theme.of(context).accentColor),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        Text(
          S.of(context).orderSuccessTitle1,
          style: TextStyle(fontSize: 18, color: Theme.of(context).accentColor),
        ),
        const SizedBox(height: 15),
        Text(
          S.of(context).orderSuccessMsg1,
          style: TextStyle(
              color: Theme.of(context).accentColor, height: 1.4, fontSize: 14),
        ),
        if (userModel.user != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Row(children: [
              Expanded(
                child: ButtonTheme(
                  height: 45,
                  child: RaisedButton(
                    elevation: 0,
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/orders');
                    },
                    child: Text(
                      S.of(context).showAllMyOrdered.toUpperCase(),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        const SizedBox(height: 40),
        Text(
          S.of(context).orderSuccessTitle2,
          style: TextStyle(fontSize: 18, color: Theme.of(context).accentColor),
        ),
        const SizedBox(height: 10),
        Text(
          S.of(context).orderSuccessMsg2,
          style: TextStyle(
              color: Theme.of(context).accentColor, height: 1.4, fontSize: 14),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Row(
            children: [
              Expanded(
                child: ButtonTheme(
                  height: 45,
                  child: OutlineButton(
                    borderSide:
                        BorderSide(color: Theme.of(context).accentColor),
                    child: Text(
                      S.of(context).backToShop.toUpperCase(),
                      style: TextStyle(color: Theme.of(context).accentColor),
                    ),
                    onPressed: () {
                      if (widget.isModal != null && widget.isModal == true) {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      } else {
                        widget.controller.animateToPage(
                          0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    shape: const RoundedRectangleBorder(),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
