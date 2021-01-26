import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show AppModel, CartModel, Coupons, Discount;
import '../../services/index.dart';
import 'coupon_list.dart';
import 'point_reward.dart';

class ShoppingCartSummary extends StatefulWidget {
  ShoppingCartSummary({this.model, this.onApplyCoupon});

  final CartModel model;
  final Function onApplyCoupon;

  @override
  _ShoppingCartSummaryState createState() => _ShoppingCartSummaryState();
}

class _ShoppingCartSummaryState extends State<ShoppingCartSummary> {
  final services = Services();
  Coupons coupons;
  bool _enable = true;
  bool _loading = false;
  Map<String, dynamic> defaultCurrency = kAdvanceConfig['DefaultCurrency'];

  @override
  void initState() {
    super.initState();
    if (widget.model.couponObj != null && widget.model.couponObj.amount > 0) {
      _enable = false;
    }
    getCoupon();
  }

  Future<void> getCoupon() async {
    try {
      coupons = await services.api.getCoupons();
    } catch (e) {
//      print(e.toString());
    }
  }

  void showError(String message) {
    setState(() => _loading = false);
    final snackBar = SnackBar(
      content: Text(S.of(context).warning(message)),
      duration: const Duration(seconds: 30),
      action: SnackBarAction(
        label: S.of(context).close,
        onPressed: () {},
      ),
    );
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(snackBar);
  }

  /// Check coupon code
  void checkCoupon(String couponCode) {
    if (couponCode.isEmpty) {
      showError(S.of(context).pleaseFillCode);
      return;
    }

    setState(() => _loading = true);

    Services().widget.applyCoupon(context, coupons: coupons, code: couponCode,
        success: (Discount discount) async {
      await widget.model.updateDiscount(discount: discount);
      setState(() {
        _enable = false;
        _loading = false;
      });
    }, error: showError);
  }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<AppModel>(context).currency;
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    final smallAmountStyle = TextStyle(color: Theme.of(context).accentColor);
    final largeAmountStyle =
        TextStyle(color: Theme.of(context).accentColor, fontSize: 20);
    final formatter = NumberFormat.currency(
        locale: 'en',
        symbol: defaultCurrency['symbol'],
        decimalDigits: defaultCurrency['decimalDigits']);
    final savedCoupon = Provider.of<CartModel>(context).savedCoupon;
    final couponController = TextEditingController(text: savedCoupon ?? '');

    var couponMsg = S.of(context).couponMsgSuccess;
    if (widget.model.couponObj != null) {
      if (widget.model.couponObj.discountType == 'percent') {
        couponMsg += '${widget.model.couponObj.amount}%';
      } else {
        couponMsg += ' - ${formatter.format(widget.model.couponObj.amount)}';
      }
    }
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width,
      child: Container(
        width: screenSize.width / (2 / (screenSize.height / screenSize.width)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (kAdvanceConfig['EnableCouponCode'] ?? true)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                        decoration: _enable
                            ? BoxDecoration(
                                color: Theme.of(context).backgroundColor)
                            : const BoxDecoration(color: Color(0xFFF1F2F3)),
                        child: GestureDetector(
                          onTap: (kAdvanceConfig['ShowCouponList'] ?? false)
                              ? () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      fullscreenDialog: true,
                                      builder: (context) => CouponList(
                                        isFromCart: true,
                                        coupons: coupons,
                                        onSelect: (String couponCode) {
                                          setState(() {
                                            couponController.text = couponCode;
                                          });
                                          checkCoupon(couponController.text);
                                        },
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          child: AbsorbPointer(
                            absorbing:
                                (kAdvanceConfig['ShowCouponList'] ?? false),
                            child: TextField(
                              controller: couponController,
                              enabled: _enable && !_loading,
                              decoration: InputDecoration(
                                  prefixIcon:
                                      (kAdvanceConfig['ShowCouponList'] ??
                                              false)
                                          ? Icon(
                                              CupertinoIcons.search,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            )
                                          : null,
                                  labelText: _enable
                                      ? S.of(context).couponCode
                                      : widget.model.couponObj.code,
                                  //hintStyle: TextStyle(color: _enable ? Colors.grey : Colors.black),
                                  contentPadding: const EdgeInsets.all(2)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 10,
                    ),
                    RaisedButton.icon(
                      elevation: 0.0,
                      label: Text(_loading || widget.model.calculatingDiscount
                          ? S.of(context).loading
                          : _enable
                              ? S.of(context).apply
                              : S.of(context).remove),
                      icon: const Icon(
                        CupertinoIcons.checkmark_seal_fill,
                        size: 18,
                      ),
                      color: Theme.of(context).primaryColorLight,
                      textColor: Theme.of(context).primaryColor,
                      onPressed: !widget.model.calculatingDiscount
                          ? () {
                              if (_enable) {
                                checkCoupon(couponController.text);
                              } else {
                                setState(() {
                                  _enable = true;
                                  widget.model.resetCoupon();
                                  widget.model.discountAmount = 0.0;
                                });
                              }
                            }
                          : null,
                    )
                  ],
                ),
              ),
            _enable
                ? Container()
                : Padding(
                    padding:
                        const EdgeInsets.only(left: 40, right: 40, bottom: 15),
                    child: Text(
                      couponMsg,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
            PointReward(model: widget.model),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              child: Container(
                decoration:
                    BoxDecoration(color: Theme.of(context).primaryColorLight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 15.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(S.of(context).products,
                                style: smallAmountStyle),
                          ),
                          Text(
                            'x${widget.model.totalCartQuantity}',
                            style: smallAmountStyle,
                          ),
                        ],
                      ),
                      if (widget.model.rewardTotal > 0)
                        const SizedBox(height: 10),
                      if (widget.model.rewardTotal > 0)
                        Row(
                          children: [
                            Expanded(
                              child: Text(S.of(context).cartDiscount,
                                  style: smallAmountStyle),
                            ),
                            Text(
                              Tools.getCurrencyFormatted(
                                  widget.model.rewardTotal, currencyRate,
                                  currency: currency),
                              style: smallAmountStyle,
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text('${S.of(context).total}:',
                                style: largeAmountStyle),
                          ),
                          widget.model.calculatingDiscount
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                  ),
                                )
                              : Text(
                                  Tools.getCurrencyFormatted(
                                      widget.model.getTotal() -
                                          widget.model.getShippingCost(),
                                      currencyRate,
                                      currency: currency),
                                  style: largeAmountStyle,
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
