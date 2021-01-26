import 'package:flutter/material.dart';
import 'package:flutter_ticket_widget/flutter_ticket_widget.dart';
import 'package:provider/provider.dart';

import '../../../../generated/l10n.dart';
import '../../../../models/index.dart';
import '../../../../screens/base.dart';
import 'event_booking.dart';
import 'listing_booking_model.dart';
import 'rental_booking.dart';
import 'service_booking.dart';

class BookingScreen extends StatefulWidget {
  final Product product;

  BookingScreen({this.product});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends BaseScreen<BookingScreen> {
  User user;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (mounted) {
      setState(() {
        user = Provider.of<UserModel>(context, listen: false).user;
      });
    }
  }

  Widget renderLayout() {
    switch (widget.product.type) {
      case 'service':
        return ChangeNotifierProvider<ListingBookingModel>(
            create: (_) => ListingBookingModel(widget.product),
            child: ServiceBooking(
                product: widget.product, user: user, scaffold: _scaffoldKey));
      case 'rental':
        return ChangeNotifierProvider<ListingBookingModel>(
            create: (_) => ListingBookingModel(widget.product),
            child: RentalBooking(
              product: widget.product,
              user: user,
              scaffold: _scaffoldKey,
            ));
      case 'event':
        return ChangeNotifierProvider<ListingBookingModel>(
            create: (_) => ListingBookingModel(widget.product),
            child: EventBooking(
              product: widget.product,
              user: user,
              scaffold: _scaffoldKey,
            ));
      default:
        return Text(S.of(context).notFound);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            S.of(context).booking,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w400),
          ),
          leading: GestureDetector(
            child: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: FlutterTicketWidget(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.85,
            isCornerRounded: true,
            child: Padding(
                padding: const EdgeInsets.all(20.0), child: renderLayout()),
          ),
        ),
      );
    }
    return Container();
  }
}
