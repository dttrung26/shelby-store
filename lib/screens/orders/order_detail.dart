import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show AppModel, Order, OrderModel, OrderNote, UserModel;
import '../../screens/detail/review.dart';
import '../../services/index.dart';
import '../detail/review.dart';

class OrderDetail extends StatefulWidget {
  final Order order;
  final VoidCallback onRefresh;

  OrderDetail({this.order, this.onRefresh});

  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  final services = Services();
  String tracking;
  Order order;

  @override
  void initState() {
    super.initState();
    getTracking();
    order = widget.order;
  }

  void getTracking() {
    services.api.getAllTracking()?.then((onValue) {
      if (onValue != null && onValue.trackings != null) {
        for (var track in onValue.trackings) {
          if (track.orderId == order.number) {
            setState(() {
              tracking = track.trackingNumber;
            });
          }
        }
      }
    });
  }

  void cancelOrder() {
    Services().widget.cancelOrder(context, order).then((onValue) {
      setState(() {
        order = onValue;
      });
    });
  }

  void createRefund() {
    if (order.status == 'refunded') return;
    services.api.updateOrder(order.id, status: 'refunded').then((onValue) {
      setState(() {
        order = onValue;
      });
      Provider.of<OrderModel>(context, listen: false).getMyOrder(
          userModel: Provider.of<UserModel>(context, listen: false));
    });
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    final currency = Provider.of<AppModel>(context, listen: false).currency;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        title: Text(
          S.of(context).orderNo + ' #${order.number}',
          style: TextStyle(color: Theme.of(context).accentColor),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ...List.generate(
              order.lineItems.length,
              (index) => Column(
                children: [
                  GestureDetector(
                    onTap: () => navigateToProductDetail(
                        order.lineItems[index].productId),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'image-' +
                              order.id +
                              order.lineItems[index].productId,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey,
                              child: Tools.image(
                                url: order.lineItems[index].featuredImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.lineItems[index].name,
                                style: Theme.of(context).textTheme.subtitle1,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Qty: ${order.lineItems[index].quantity.toString()}',
                                    ),
                                  ),
                                  if (order.status == 'completed')
                                    if (!kPaymentConfig['EnableShipping'] ||
                                        !kPaymentConfig['EnableAddress'])
                                      DownloadButton(
                                          order.lineItems[index].productId),
                                ],
                              ),
                              if (order.lineItems[index].addonsOptions
                                      ?.isNotEmpty ??
                                  false)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    '${order.lineItems[index].addonsOptions}',
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Review for completed order only.
                  if (order.status == 'completed')
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Reviews(
                        order.lineItems[index].productId,
                        showYourRatingOnly: true,
                      ),
                    ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3.0,
                      vertical: 3.0,
                    ),
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 8,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          S.of(context).itemTotal,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          Tools.getCurrencyFormatted(
                            order.lineItems[index].total,
                            currencyRate,
                            currency: currency,
                          ),
                          style: Theme.of(context).textTheme.subtitle1.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        S.of(context).subtotal,
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                      Text(
                        Tools.getCurrencyFormatted(
                            order.lineItems.fold(
                                0, (sum, e) => sum + double.parse(e.total)),
                            currencyRate),
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  (order.shippingMethodTitle != null &&
                          kPaymentConfig['EnableShipping'])
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(S.of(context).shippingMethod,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(
                                      fontWeight: FontWeight.w400,
                                    )),
                            Text(
                              order.shippingMethodTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            )
                          ],
                        )
                      : Container(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        S.of(context).totalTax,
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                      Text(
                        Tools.getCurrencyFormatted(
                            order.totalTax, currencyRate),
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      )
                    ],
                  ),
                  Divider(
                    height: 20,
                    color: Theme.of(context).accentColor,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        S.of(context).total,
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                      Text(
                        Tools.getCurrencyFormatted(order.total, currencyRate),
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            tracking != null ? const SizedBox(height: 20) : Container(),
            tracking != null
                ? GestureDetector(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: <Widget>[
                          Text('${S.of(context).trackingNumberIs} '),
                          Text(
                            tracking,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      return Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebviewScaffold(
                            url: "${afterShip['tracking_url']}/$tracking",
                            appBar: AppBar(
                              brightness: Theme.of(context).brightness,
                              leading: GestureDetector(
                                child: const Icon(Icons.arrow_back_ios),
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              title: Text(S.of(context).trackingPage),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Container(),
            Services().widget.renderOrderTimelineTracking(context, order),
            const SizedBox(height: 20),

            /// Render the Cancel and Refund
            if (kPaymentConfig['EnableRefundCancel'])
              Services()
                  .widget
                  .renderButtons(context, order, cancelOrder, createRefund),

            const SizedBox(height: 20),

            if (order.billing != null) ...[
              Text(S.of(context).shippingAddress,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(
                ((order.billing.apartment?.isEmpty ?? true)
                        ? ''
                        : '${order.billing.apartment} ') +
                    ((order.billing.block?.isEmpty ?? true)
                        ? ''
                        : '${(order.billing.apartment?.isEmpty ?? true) ? '' : '- '} ${order.billing.block}, ') +
                    order.billing.street +
                    ', ' +
                    order.billing.city +
                    ', ' +
                    getCountryName(order.billing.country),
              ),
            ],
            if (order.status == 'processing' &&
                kPaymentConfig['EnableRefundCancel'])
              Column(
                children: <Widget>[
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ButtonTheme(
                          height: 45,
                          child: RaisedButton(
                              textColor: Colors.white,
                              color: HexColor('#056C99'),
                              onPressed: refundOrder,
                              child: Text(
                                  S.of(context).refundRequest.toUpperCase(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700))),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            const SizedBox(
              height: 20,
            ),
            FutureBuilder<List<OrderNote>>(
              future: services.api
                  .getOrderNote(userModel: userModel, orderId: order.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Container();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      S.of(context).orderNotes,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...List.generate(
                          snapshot.data.length,
                          (index) {
                            return Padding(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  CustomPaint(
                                    painter: BoxComment(
                                        color: Theme.of(context).primaryColor),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 15,
                                            bottom: 25),
                                        child: HtmlWidget(
                                          snapshot.data[index].note,
                                          textStyle: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              height: 1.2),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    formatTime(DateTime.parse(
                                        snapshot.data[index].dateCreated)),
                                    style: const TextStyle(fontSize: 13),
                                  )
                                ],
                              ),
                              padding: const EdgeInsets.only(bottom: 15),
                            );
                          },
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 50)
          ],
        ),
      ),
    );
  }

  String getCountryName(country) {
    try {
      return CountryPickerUtils.getCountryByIsoCode(country).name;
    } catch (err) {
      return country;
    }
  }

  Future<void> refundOrder() async {
    _showLoading();
    try {
      await services.api.updateOrder(order.id, status: 'refunded');
      _hideLoading();
      widget.onRefresh();
      Navigator.of(context).pop();
    } catch (err) {
      _hideLoading();

      Tools.showSnackBar(Scaffold.of(context), err.toString());
    }
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(5.0)),
            padding: const EdgeInsets.all(50.0),
            child: kLoadingWidget(context),
          ),
        );
      },
    );
  }

  void _hideLoading() {
    Navigator.of(context).pop();
  }

  String formatTime(DateTime time) {
    return '${time.day}/${time.month}/${time.year}';
  }

  void navigateToProductDetail(String productID) async {
    final product = await Services().api.getProduct(productID);
    await Navigator.of(context).pushNamed(
      RouteList.productDetail,
      arguments: product,
    );
  }
}

class BoxComment extends CustomPainter {
  final Color color;

  BoxComment({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    paint.color = color;
    var path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 10);
    path.lineTo(30, size.height - 10);
    path.lineTo(20, size.height);
    path.lineTo(20, size.height - 10);
    path.lineTo(0, size.height - 10);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DownloadButton extends StatefulWidget {
  final String id;

  DownloadButton(this.id);

  @override
  _DownloadButtonState createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final services = Services();
    return InkWell(
      onTap: () async {
        setState(() {
          isLoading = true;
        });

        var product = await services.api.getProduct(widget.id);
        setState(() {
          isLoading = false;
        });
        await Share.share(product.files[0]);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          children: <Widget>[
            isLoading
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 15.0,
                      height: 15.0,
                      child: Center(
                        child: kLoadingWidget(context),
                      ),
                    ),
                  )
                : Icon(
                    Icons.file_download,
                    color: Theme.of(context).primaryColor,
                  ),
            Text(
              S.of(context).download,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
