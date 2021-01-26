import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show AppModel, Order, OrderModel, UserModel;
import '../../screens/base.dart';
import 'order_detail.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends BaseScreen<MyOrders> {
  final RefreshController _refreshController = RefreshController();

  @override
  void afterFirstLayout(BuildContext context) {
    refreshMyOrders();
  }

  Future<void> _onRefresh() async {
    await Provider.of<OrderModel>(context, listen: false)
        .getMyOrder(userModel: Provider.of<UserModel>(context, listen: false));
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    await Provider.of<OrderModel>(context, listen: false)
        .loadMore(userModel: Provider.of<UserModel>(context, listen: false));
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    var isLoggedIn = Provider.of<UserModel>(context).loggedIn;

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
        body: ListenableProvider.value(
            value: Provider.of<OrderModel>(context),
            child: Consumer<OrderModel>(builder: (context, model, child) {
              if (model.myOrders == null) {
                return Center(
                  child: kLoadingWidget(context),
                );
              }
              if (!isLoggedIn) {
                final storage = LocalStorage('data_order');
                var orders = storage.getItem('orders');
                var listOrder = [];
                // for (var i in orders) {
                //   listOrder.add(Order.fromStrapiJson(i));
                // }
                for (var i in orders) {
                  listOrder.add(Order.fromJson(i));
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                      child: Text('${listOrder.length} ${S.of(context).items}'),
                    ),
                    Expanded(
                      child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount: listOrder.length,
                          itemBuilder: (context, index) {
                            return OrderItem(
                              order: listOrder[listOrder.length - index - 1],
                              onRefresh: () {},
                            );
                          }),
                    )
                  ],
                );
              }

              if (model.myOrders != null && model.myOrders.isEmpty) {
                return Center(child: Text(S.of(context).noOrders));
              }

              return Stack(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        child: Text(
                            '${model.myOrders.length} ${S.of(context).items}'),
                      ),
                      Expanded(
                        child: SmartRefresher(
                          enablePullDown: true,
                          enablePullUp: !model.endPage,
                          onRefresh: _onRefresh,
                          onLoading: _onLoading,
                          header: const WaterDropHeader(),
                          footer: kCustomFooter(context),
                          controller: _refreshController,
                          child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              itemCount: model.myOrders.length,
                              itemBuilder: (context, index) {
                                return OrderItem(
                                  order: model.myOrders[index],
                                  onRefresh: refreshMyOrders,
                                );
                              }),
                        ),
                      )
                    ],
                  ),
                  model.isLoading
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          color: Colors.black.withOpacity(0.2),
                          child: Center(
                            child: kLoadingWidget(context),
                          ),
                        )
                      : Container()
                ],
              );
            })));
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

  String getTitleStatus(String status, BuildContext context) {
    switch (status.toLowerCase()) {
      case 'on-hold':
        return S.of(context).orderStatusOnHold;
      case 'pending':
        return S.of(context).orderStatusPendingPayment;
      case 'failed':
        return S.of(context).orderStatusFailed;
      case 'processing':
        return S.of(context).orderStatusProcessing;
      case 'completed':
        return S.of(context).orderStatusCompleted;
      case 'cancelled':
        return S.of(context).orderStatusCancelled;
      case 'refunded':
        return S.of(context).orderStatusRefunded;
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    final currency = Provider.of<AppModel>(context).currency;

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
        if (order.status != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(S.of(context).status),
                Text(
                  getTitleStatus(order.status, context),
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
                Tools.getCurrencyFormatted(order.total, currencyRate,
                    currency: currency),
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
