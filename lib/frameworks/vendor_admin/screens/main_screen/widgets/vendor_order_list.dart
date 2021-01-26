import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../generated/l10n.dart';
import '../../../../../models/entities/order.dart';
import '../../../../../models/entities/sale_stats.dart';
import '../../../common_widgets/loading_item.dart';
import '../../../common_widgets/order_item.dart';
import '../../../models/main_screen_model.dart';
import '../../../models/notification_screen_model.dart';
import '../../order_list_screen/order_list_screen.dart';

class VendorOrderList extends StatelessWidget {
  final List<Order> orders;
  final int maxOrder;
  final SaleStats saleStats;
  const VendorOrderList({Key key, this.orders, this.maxOrder, this.saleStats})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    var maxOrderLength = 0;
    if (maxOrder != null && orders.isNotEmpty) {
      if (orders.length >= maxOrder) {
        maxOrderLength = maxOrder;
      }
    } else if (orders.isNotEmpty) {
      maxOrderLength = orders.length;
    }
    final mainModel =
        Provider.of<VendorAdminMainScreenModel>(context, listen: false);
    final notifyModel =
        Provider.of<VendorAdminNotificationScreenModel>(context, listen: false);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Theme.of(context).primaryColorLight,
      ),
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  S.of(context).allOrders,
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              const Expanded(
                  child: SizedBox(
                width: 1,
              )),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(CupertinoPageRoute(
                      builder: (context) => VendorAdminOrderListScreen(
                            orders: orders,
                            saleStats: saleStats,
                            updateOrdersInHomeScreen: mainModel.getVendorOrders,
                            updateSaleStats: mainModel.getSaleStats,
                            updateNotification: notifyModel.getNotification,
                          ))),
                  child: Text(
                    S.of(context).seeAll,
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15.0,
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  S.of(context).orderNo,
                  style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.start,
                ),
              ),
              Expanded(
                child: Text(
                  S.of(context).status,
                  style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  S.of(context).earnings,
                  style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          if (mainModel.state == VendorAdminMainScreenModelState.loading)
            Column(
              children: List.generate(5, (index) => VendorOrderLoadingItem()),
            ),
          if (mainModel.state == VendorAdminMainScreenModelState.loaded)
            Column(
              children: List.generate(
                  maxOrderLength,
                  (index) => OrderItem(
                        order: orders[index],
                        onCallBack: (String status, String customerNote) {
                          mainModel
                              .updateOrder(orders[index], status,
                                  customerNote: customerNote)
                              .then((value) {
                            mainModel.getVendorOrders();
                            mainModel.getSaleStats();
                            notifyModel.getNotification();
                          });
                        },
                      )),
            ),
        ],
      ),
    );
  }
}
