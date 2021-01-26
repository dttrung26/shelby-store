import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';

import '../../../../../../common/constants.dart';
import '../../../../../../common/tools.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../../../models/app_model.dart';
import '../../../../../../models/entities/index.dart'
    show CreditCard, ListingBooking;
import '../../../../../../models/user_model.dart';
import '../../../../../../widgets/payment/stripe/credit_card/credit_card_form.dart';
import '../../../../../../widgets/payment/stripe/credit_card/credit_card_widget.dart';
import 'services.dart';

class StripePayment extends StatefulWidget {
  final Function onFinish;
  final ListingBooking booking;

  const StripePayment({
    Key key,
    this.onFinish,
    this.booking,
  }) : super(key: key);

  @override
  _StripePaymentState createState() => _StripePaymentState();
}

class _StripePaymentState extends State<StripePayment> {
  StripeServices services = StripeServices();

  String cardNumber = '';
  String cardHolderName = '';
  String expiryDate = '';
  String cvv = '';
  bool showBackView = false;

  bool isChecking = false;

  bool get areFieldsValid =>
      cardHolderName.isNotEmpty &&
      cvv.isNotEmpty &&
      expiryDate.isNotEmpty &&
      cardNumber.isNotEmpty;

  String formatPrice(String price) {
    final formatCurrency = NumberFormat.currency(symbol: '', decimalDigits: 1);
    var number = '';
    if (price is String) {
      number =
          formatCurrency.format(price.isNotEmpty ? double.parse(price) : 0);
    } else {
      number = formatCurrency.format(price);
    }
    return number;
  }

  Future<void> handlePayment(BuildContext context) async {
    setState(() {
      isChecking = true;
    });
    var totalPrice = 0.0;
    if (widget.booking.price != null && widget.booking.price.isNotEmpty) {
      totalPrice = double.parse(widget.booking.price ?? 0);
    }

    final appModel = Provider.of<AppModel>(context, listen: false);
    final currencyCode = appModel.currencyCode;
    final smallestUnitRate = appModel.smallestUnitRate ?? 1;
    final user = Provider.of<UserModel>(context, listen: false).user;
    var result = false;
    try {
      final expDate = expiryDate.split('/');
      result = await services.executePayment(
            totalPrice:
                (totalPrice * smallestUnitRate).round().toStringAsFixed(0),
            currencyCode: currencyCode,
            emailAddress: user.email,
            name: cardHolderName,
            stripeCard: StripeCard(
              expMonth: int.parse(expDate.first),
              expYear: int.parse(expDate.last),
              number: cardNumber,
              cvc: cvv,
            ),
          ) ??
          false;

      if (result == true && widget.onFinish != null) {
        widget.onFinish(result);
        Navigator.of(context).pop();
      }

      if (result == false) {
        Tools.showSnackBar(
            Scaffold.of(context), S.of(context).transactionCancelled);
      }
    } catch (err) {
      if (err != null) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(S.of(context).orderStatusFailed),
              content: Text('${err?.message ?? err}'),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    S.of(context).ok,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
        return;
      }
    } finally {
      setState(() {
        isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      fit: StackFit.expand,
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            leading: GestureDetector(
              onTap: () {
                widget.onFinish(null);
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back_ios),
            ),
            title: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    S.of(context).payment,
                    textAlign: TextAlign.center,
                  ),
                ),
                Builder(builder: (BuildContext context) {
                  return ButtonTheme(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    child: RaisedButton(
                      child: isChecking
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                              ),
                            )
                          : Text(
                              S.of(context).checkout,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                      onPressed:
                          areFieldsValid ? () => handlePayment(context) : null,
                    ),
                  );
                }),
              ],
            ),
          ),
          body: GestureDetector(
            onTap: () {
              final focus = FocusScope.of(context);
              if (!focus.hasPrimaryFocus) {
                focus.unfocus();
              }
            },
            child: SafeArea(
              child: Column(
                children: [
                  CreditCardWidget(
                    expiryDate: expiryDate,
                    cardHolderName: cardHolderName,
                    cardNumber: cardNumber,
                    cvvCode: cvv,
                    showBackView: showBackView,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: CreditCardForm(
                        onCreditCardModelChange: (CreditCard model) {
                          setState(() {
                            cardNumber = model.cardNumber;
                            cardHolderName = model.cardHolderName;
                            cvv = model.cvv;
                            expiryDate = model.expiryDate;
                            showBackView = model.isCvvFocused;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isChecking)
          Container(
            width: size.width,
            height: size.height,
            color: Colors.grey.withOpacity(0.3),
            child: kLoadingWidget(context),
          ),
      ],
    );
  }
}
