import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';

import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/app_model.dart';
import '../../../models/entities/order.dart';
import '../../../models/entities/order_note.dart';
import '../../../screens/orders/order_detail.dart';
import '../../../widgets/common/expansion_info.dart';
import '../services/vendor_admin.dart';

part '../actions/order_item_details_actions.dart';

class VendorAdminOrderItemDetailsScreen extends StatefulWidget {
  final Order order;
  final Function onCallBack;
  const VendorAdminOrderItemDetailsScreen(
      {Key key, this.order, this.onCallBack})
      : super(key: key);

  @override
  _VendorAdminOrderItemDetailsScreenState createState() =>
      _VendorAdminOrderItemDetailsScreenState();
}

class _VendorAdminOrderItemDetailsScreenState
    extends State<VendorAdminOrderItemDetailsScreen> {
  final _noteController = TextEditingController();
  final fontSize = 16.0;
  final _services = VendorAdminApi();
  final _perPage = 10;
  int page = 1;
  List<OrderNote> orderNotes = [];
  final List<String> statuses = [
    'pending',
    'refunded',
    'completed',
    'processing'
  ];

  String _dropdownStatusValue;
  bool _enableEdit = false;

  @override
  void initState() {
    _dropdownStatusValue = widget.order.status.toLowerCase();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getOrderNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currency = Provider.of<AppModel>(context, listen: false).currency;
    final currencyRate =
        Provider.of<AppModel>(context, listen: false).currencyRate;
    var statusOrderColor = _buildStatusColor(_dropdownStatusValue);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).orderDetail,
          style: Theme.of(context).primaryTextTheme.headline5,
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back_ios_sharp),
        ),
        actions: [
          InkWell(
              onTap: () => setState(() {
                    _enableEdit = !_enableEdit;
                    if (!_enableEdit) {
                      _cancelEdit();
                    }
                  }),
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.only(right: 15.0, left: 15.0),
                child: Text(!_enableEdit
                    ? S.of(context).editWithoutColon
                    : S.of(context).cancel),
              ))),
        ],
        centerTitle: true,
      ),
      floatingActionButton: _enableEdit
          ? InkWell(
              onTap: _updateOrder,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15.0),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  S.of(context).updateStatus,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
          : Container(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${widget.order.number}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: fontSize),
                    ),
                  ),
                  if (!_enableEdit)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Text(
                        widget.order.status,
                        style: TextStyle(
                            color: statusOrderColor, fontSize: fontSize),
                      ),
                    ),
                  if (_enableEdit) _buildListStatuses(),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                widget.order.createdAt.toString(),
                style: TextStyle(fontSize: fontSize),
              ),
              const SizedBox(height: 10),
              Text(
                S.of(context).deliveredTo,
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
              ),
              const SizedBox(height: 5),
              Text(
                '${widget.order.shipping.street ?? ''} ${widget.order.shipping.city ?? ''} ${widget.order.shipping.state ?? ''} ${widget.order.shipping.zipCode ?? ''} ${widget.order.shipping.country ?? ''}',
                style: TextStyle(fontSize: fontSize),
              ),
              const SizedBox(height: 10),
              Text(
                S.of(context).paymentMethod,
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
              ),
              const SizedBox(height: 5),
              Text(
                widget.order.paymentMethodTitle,
                style: TextStyle(fontSize: fontSize),
              ),
              const SizedBox(height: 10),
              Container(
                height: 0.5,
                width: size.width,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              Column(
                children: List.generate(
                  widget.order.lineItems.length,
                  (index) => Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Container(
                              color: Colors.grey,
                              child: Tools.image(
                                url:
                                    widget.order.lineItems[index].featuredImage,
                                width: 80,
                                height: 80,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.order.lineItems[index].name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${S.of(context).Qty}: ${widget.order.lineItems[index].quantity.toString()}',
                              ),
                            ],
                          ),
                        ],
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
                          children: [
                            Container(
                              width: 10,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${S.of(context).itemTotal}: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: fontSize,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              Tools.getCurrencyFormatted(
                                widget.order.lineItems[index].total,
                                currencyRate,
                                currency: currency,
                              ),
                              style: TextStyle(
                                fontSize: fontSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 0.5,
                width: size.width,
                color: Colors.grey,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: Text(S.of(context).tax)),
                  Text(
                    widget.order.totalTax.toString(),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      S.of(context).orderTotal,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    Tools.getCurrencyFormatted(
                      widget.order.total,
                      currencyRate,
                      currency: currency,
                    ),
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 0.5,
                width: size.width,
                color: Colors.grey,
              ),
              const SizedBox(height: 10),
              Container(
                width: size.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: TextField(
                  controller: _noteController,
                  maxLines: null,
                  enabled: _enableEdit,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: S.of(context).writeYourNote,
                    contentPadding: const EdgeInsets.all(1.0),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ExpansionInfo(
                  expand: true,
                  title: S.of(context).orderNotes,
                  children: List.generate(
                    orderNotes.length,
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
                                      left: 10, right: 10, top: 15, bottom: 25),
                                  child: HtmlWidget(
                                    orderNotes[index].note,
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
                                  orderNotes[index].dateCreated)),
                              style: const TextStyle(fontSize: 13),
                            )
                          ],
                        ),
                        padding: const EdgeInsets.only(bottom: 15),
                      );
                    },
                  )),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
