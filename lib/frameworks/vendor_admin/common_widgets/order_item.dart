import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../common/tools.dart';
import '../../../models/app_model.dart';
import '../../../models/entities/order.dart';
import '../screens/order_item_details_screen.dart';

class OrderItem extends StatelessWidget {
  final Order order;
  final Function(String, String) onCallBack;
  const OrderItem({Key key, this.order, this.onCallBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const fontFamily = 'Montserrat';
    final currency = Provider.of<AppModel>(context, listen: false).currency;
    final currencyRate =
        Provider.of<AppModel>(context, listen: false).currencyRate;

    var statusOrderColor;
    switch (order.status.toLowerCase()) {
      case 'pending':
        {
          statusOrderColor = Colors.yellow;
          break;
        }
      case 'processing':
        {
          statusOrderColor = Colors.orange;
          break;
        }
      case 'completed':
        {
          statusOrderColor = Colors.green;
          break;
        }
      case 'refunded':
        {
          statusOrderColor = Colors.red;
          break;
        }
    }

    final formatter = DateFormat.yMd().add_jm();

    return InkWell(
      onTap: onCallBack != null
          ? () => Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => VendorAdminOrderItemDetailsScreen(
                    order: order,
                    onCallBack: onCallBack,
                  ),
                ),
              )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.number}',
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                            fontFamily: fontFamily,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      '${formatter.format(order.createdAt)}',
                      style: const TextStyle(
                          fontFamily: fontFamily, fontSize: 10.0),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Text(
                '${order.status}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 12.0,
                    color: statusOrderColor),
              )),
              Expanded(
                  child: Text(
                Tools.getCurrencyFormatted(
                  order.total,
                  currencyRate,
                  currency: currency,
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: fontFamily, fontSize: 12.0),
              )),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(height: 1),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
