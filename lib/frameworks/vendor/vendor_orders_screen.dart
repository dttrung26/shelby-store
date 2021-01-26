import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show AppModel, Order, OrderModel, UserModel;
import '../../screens/orders/order_detail.dart';
import '../../services/index.dart';

class VendorOrdersScreen extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<VendorOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    var userModel = Provider.of<UserModel>(context);

    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          title: Text(
            S.of(context).orderHistory,
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0.0,
        ),
        body: FutureBuilder(
          builder: (context, projectSnap) {
            if (projectSnap.connectionState == ConnectionState.none ||
                projectSnap.connectionState == ConnectionState.waiting) {
              return Center(
                child: kLoadingWidget(context),
              );
            }

            if (projectSnap.connectionState == ConnectionState.done &&
                projectSnap.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    child: Text(
                        '${projectSnap.data.length} ${S.of(context).items}'),
                  ),
                  Expanded(
                    child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: projectSnap.data.length,
                        itemBuilder: (context, index) {
                          return OrderItem(
                            order: projectSnap.data[index],
                            onRefresh: () {},
                          );
                        }),
                  )
                ],
              );
            }
            return Container();
          },
          future: Services().api.getVendorOrders(userModel: userModel),
        ));
  }

  void refreshMyOrders() {
    Provider.of<OrderModel>(context, listen: false)
        .getMyOrder(userModel: Provider.of<UserModel>(context, listen: false));
  }
}

class OrderItem extends StatelessWidget {
  final Order order;
  final VoidCallback onRefresh;

  OrderItem({this.order, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {
            if (order.statusUrl != null) {
              launch(order.statusUrl);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OrderDetail(
                          order: order,
                          onRefresh: onRefresh,
                        )),
              );
            }
          },
          child: Container(
            height: 40,
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                borderRadius: BorderRadius.circular(3)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('#${order.number}',
                    style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontWeight: FontWeight.bold)),
                const Icon(Icons.arrow_right),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(S.of(context).orderDate),
              Text(
                DateFormat('dd/MM/yyyy').format(order.createdAt),
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(S.of(context).status),
              Text(
                order.status.toUpperCase(),
                style: TextStyle(
                    color: kOrderStatusColor[order.status] != null
                        ? HexColor(kOrderStatusColor[order.status])
                        : Theme.of(context).accentColor,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(S.of(context).paymentMethod),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                  child: Text(
                order.paymentMethodTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ))
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(S.of(context).total),
              Text(
                Tools.getCurrencyFormatted(order.total, currencyRate),
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        const SizedBox(height: 20)
      ],
    );
  }
}
