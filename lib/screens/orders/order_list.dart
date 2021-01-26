import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/l10n.dart';
import '../../models/index.dart';
import '../../models/order_list_model.dart';
import 'order_detail.dart';
import 'widgets/order_list_item.dart';
import 'widgets/order_list_loading_item.dart';

class OrderList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final userModel = Provider.of<UserModel>(context, listen: false);
    return ChangeNotifierProvider<OrderListModel>(
      create: (_) => OrderListModel(userModel),
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          brightness: Theme.of(context).brightness,
          title: Text(
            S.of(context).orderHistory,
            style: TextStyle(
              color: Theme.of(context).accentColor,
            ),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).backgroundColor,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_sharp,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(
          width: size.width,
          height: size.height,
          child: Consumer<OrderListModel>(
            builder: (context, model, _) {
              if (model.state == OrderListModelState.loading) {
                return ListView.builder(
                  itemBuilder: (context, index) => const OrderListLoadingItem(),
                  itemCount: 5,
                );
              }
              return SmartRefresher(
                header: const MaterialClassicHeader(
                  backgroundColor: Colors.white,
                ),
                controller: model.refreshController,
                enablePullDown: true,
                enablePullUp: !model.isEnd,
                onRefresh: model.getMyOrder,
                onLoading: model.loadMore,
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    final order = model.orders[index];
                    return InkWell(
                      onTap: () {
                        if (order.statusUrl != null) {
                          launch(order.statusUrl);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetail(
                                order: order,
                              ),
                            ),
                          );
                        }
                      },
                      child: OrderListItem(order: order),
                    );
                  },
                  itemCount: model.orders.length,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
