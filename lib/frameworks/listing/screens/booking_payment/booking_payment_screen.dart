import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import '../../../../common/config.dart';
import '../../../../common/constants.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/user_model.dart';
import 'booking_payment_method_screen.dart';
import 'booking_payment_model.dart';
import 'payment/paypal/index.dart';
import 'payment/razor/services.dart';
import 'payment/stripe/index.dart';
import 'payment/tap/index.dart';
import 'widgets/continue_floating_button.dart';

class BookingPaymentScreen extends StatefulWidget {
  /// Function to refresh the booking history after payment
  final Function callback;

  const BookingPaymentScreen({Key key, this.callback}) : super(key: key);
  @override
  _BookingPaymentScreenState createState() => _BookingPaymentScreenState();
}

class _BookingPaymentScreenState extends State<BookingPaymentScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _pageController = PageController();
  List<Widget> lstScreen = [];
  int index = 0;

  @override
  void initState() {
    lstScreen.addAll([
      // BookingAddressScreen(),
      BookingPaymentMethodScreen(),
    ]);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateBooking() async {
    final model = Provider.of<BookingPaymentModel>(context, listen: false);
    await model.updateBookingStatus(true);
    Navigator.pop(context);
    widget.callback();
  }

  void _makePayment() {
    final model = Provider.of<BookingPaymentModel>(context, listen: false);
    final paymentMethod = model.lstPaymentMethod[model.index];

    if (isNotBlank(PaypalConfig['paymentMethodId']) &&
        paymentMethod.id.contains(PaypalConfig['paymentMethodId']) &&
        PaypalConfig['enabled'] == true) {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => PaypalPayment(
            booking: model.booking,
            onFinish: (number) async {
              if (number == null) {
                return;
              } else {
                _updateBooking();
              }
            },
          ),
        ),
      );
    }

    if (isNotBlank(PaypalConfig['paymentMethodId']) &&
        paymentMethod.id.contains(TapConfig['paymentMethodId']) &&
        TapConfig['enabled'] == true) {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
            builder: (context) => TapPayment(
                  booking: model.booking,
                  onFinish: (number) async {
                    if (number == null) {
                      return;
                    } else {
                      _updateBooking();
                    }
                  },
                )),
      );
    }

    if (isNotBlank(kStripeConfig['paymentMethodId']) &&
        paymentMethod.id.contains(kStripeConfig['paymentMethodId']) &&
        kStripeConfig['enabled'] == true) {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (_) => StripePayment(
            booking: model.booking,
            onFinish: (success) async {
              if (success != null) {
                if (success) {
                  _updateBooking();
                } else {
                  return;
                }
              }
            },
          ),
        ),
      );
    }

    if (isNotBlank(RazorpayConfig['paymentMethodId']) &&
        paymentMethod.id.contains(RazorpayConfig['paymentMethodId']) &&
        RazorpayConfig['enabled'] == true) {
      final user = Provider.of<UserModel>(context, listen: false).user;
      final _razorServices =
          RazorServices(_scaffoldKey, model.booking, user, _updateBooking);
      _razorServices.openPayment();
    }
  }

  void _nextPage() {
    if (index < lstScreen.length - 1) {
      index++;
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
      return;
    }
    _makePayment();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<BookingPaymentModel>(
      builder: (context, model, _) => Stack(
        fit: StackFit.expand,
        children: [
          Scaffold(
            key: _scaffoldKey,
            backgroundColor: Theme.of(context).backgroundColor,
            appBar: AppBar(
              brightness: Theme.of(context).brightness,
              backgroundColor: Theme.of(context).backgroundColor,
              title: Text(S.of(context).paymentMethods),
            ),
            floatingActionButton: ContinueFloatingButton(
              title: S.of(context).continues,
              icon: Icons.arrow_forward_ios,
              onTap: _nextPage,
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.miniCenterFloat,
            body: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: lstScreen,
            ),
          ),
          if (model.state == BookingPaymentModelState.paymentProcessing)
            Container(
              height: size.height,
              width: size.width,
              color: Colors.grey.withOpacity(0.3),
              child: Center(
                child: kLoadingWidget(context),
              ),
            ),
        ],
      ),
    );
  }
}
