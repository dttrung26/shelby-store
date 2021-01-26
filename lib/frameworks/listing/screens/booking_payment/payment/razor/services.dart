import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../../../common/config.dart';
import '../../../../../../common/tools.dart';
import '../../../../../../models/entities/index.dart';

class RazorServices {
  final razorPay = Razorpay();
  GlobalKey<ScaffoldState> scaffoldKey;
  ListingBooking booking;
  User user;
  Function updateBooking;

  RazorServices(this.scaffoldKey, this.booking, this.user, this.updateBooking) {
    razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentFailure);
  }

  String _formatRazorPrice(String price) {
    if (isNotBlank(price)) {
      final p = double.parse(price) * 100;
      return p.toString();
    } else {
      return '0';
    }
  }

  void openPayment() {
    var options = {
      'key': RazorpayConfig['keyId'],
      'amount': _formatRazorPrice(booking.price),
      'name': '${user.firstName} ${user.lastName}',
      'currency': 'INR',
      'prefill': {'contact': user.billing.phone, 'email': user.email}
    };
    razorPay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Tools.showSnackBar(scaffoldKey.currentState, response.paymentId);
    updateBooking();
  }

  void _handlePaymentFailure(PaymentFailureResponse response) {
    Tools.showSnackBar(scaffoldKey.currentState, response.message);
  }
}
