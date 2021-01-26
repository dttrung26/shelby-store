import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/entities/order.dart';
import '../../../routes/flux_navigate.dart';
import '../../../widgets/common/webview.dart';

class OrderListItem extends StatelessWidget {
  final Order order;

  const OrderListItem({Key key, this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          const BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 6,
          )
        ],
      ),
      margin: const EdgeInsets.only(
        top: 15.0,
        left: 15.0,
        right: 15.0,
        bottom: 10.0,
      ),
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding:
                  const EdgeInsets.only(left: 10.0, top: 10.0, right: 15.0),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14.0),
                  topRight: Radius.circular(14.0),
                ),
                color: Theme.of(context).backgroundColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (order.lineItems.isNotEmpty)
                    Stack(
                      children: [
                        const SizedBox(width: 92, height: 86),
                        if (order.lineItems.length > 1)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Opacity(
                              opacity: 0.6,
                              child: Hero(
                                tag: 'image-' +
                                    order.id +
                                    order.lineItems[1].productId,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    color: Theme.of(context).primaryColorLight,
                                  ),
                                  width: 80,
                                  height: 75,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Tools.image(
                                      url: order.lineItems[1].featuredImage ??
                                          kDefaultImage,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Hero(
                            tag: 'image-' +
                                order.id +
                                order.lineItems[0].productId,
                            child: Container(
                              width: 85,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  const BoxShadow(
                                    color: Colors.black12,
                                    offset: Offset(0, 2),
                                    blurRadius: 2,
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Tools.image(
                                  url: order.lineItems[0].featuredImage ??
                                      kDefaultImage,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  const SizedBox(width: 10),
                  if (order.lineItems.isNotEmpty)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            '${order.lineItems[0].name}',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${order.billing.firstName} | ${order.billing.city}, ${order.billing.country}',
                            style: const TextStyle(fontSize: 14.0),
                          ),
                          const Expanded(
                            child: SizedBox(height: 1),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  S.of(context).createdOn +
                                      '${DateFormat('d MMM, HH:mm').format(order.createdAt)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(
                                        color: Theme.of(context)
                                            .accentColor
                                            .withOpacity(0.8),
                                      ),
                                ),
                              ),
                              Text(
                                S.of(context).orderNo + '${order.number}',
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    .copyWith(
                                      color: Theme.of(context)
                                          .accentColor
                                          .withOpacity(0.8),
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Divider(
          //   height: 1,
          //   color: Theme.of(context).primaryColorLight,
          // ),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14.0),
                  bottomRight: Radius.circular(14.0),
                ),
                color: Theme.of(context).backgroundColor,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Theme.of(context).primaryColorLight,
                ),
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.only(right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 8,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    OrderStatus(
                      title: S.of(context).total,
                      detail: Tools.getCurrencyFormatted(order.total, null),
                    ),
                    OrderStatus(
                      title: S.of(context).tax,
                      detail: Tools.getCurrencyFormatted(order.totalTax, null),
                    ),
                    OrderStatus(
                      title: S.of(context).Qty,
                      detail: order.quantity.toString(),
                    ),
                    if (order.status?.isNotEmpty ?? false)
                      OrderStatus(
                        title:  S.of(context).status,
                        detail: order.status,
                      ),
                    if (order.statusUrl?.isNotEmpty ?? false)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Status',
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                .copyWith(
                                  color: Theme.of(context)
                                      .accentColor
                                      .withOpacity(0.7),
                                  fontWeight: FontWeight.w700,
                                )
                                .apply(fontSizeFactor: 0.9),
                          ),
                          const SizedBox(height: 3),
                          GestureDetector(
                            onTap: () {
                              FluxNavigate.push(
                                MaterialPageRoute(
                                  builder: (context) => WebView(
                                    url: order.statusUrl,
                                    title: S.of(context).status,
                                  ),
                                ),
                                forceRootNavigator: true,
                              );
                            },
                            child: Text(
                              'Detail',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ],
                      )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderStatus extends StatelessWidget {
  final String title;
  final String detail;

  const OrderStatus({Key key, this.title, this.detail}) : super(key: key);

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
        return status;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    var statusOrderColor;
    switch (detail.toLowerCase()) {
      case 'pending':
        {
          statusOrderColor = Colors.red;
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
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title.toString(),
          style: Theme.of(context)
              .textTheme
              .caption
              .copyWith(
                color: Theme.of(context).accentColor.withOpacity(0.7),
                fontWeight: FontWeight.w700,
              )
              .apply(fontSizeFactor: 0.9),
        ),
        const SizedBox(height: 3),
        Text(
          Utils.capitalize(getTitleStatus(detail, context)),
          style: Theme.of(context).textTheme.subtitle1.copyWith(
                color: statusOrderColor,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
