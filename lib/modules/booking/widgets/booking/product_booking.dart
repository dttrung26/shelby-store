import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/index.dart'
    show BookingModel, BookingInfo, CartModel, Product;
import '../../booking.dart';

class ProductBooking extends StatefulWidget {
  final Product product;

  ProductBooking({Key key, this.product}) : super(key: key);

  @override
  _ProductBookingState createState() => _ProductBookingState(product: product);
}

class _ProductBookingState extends State<ProductBooking>
    with SingleTickerProviderStateMixin {
  Product product;
  BookingModel _bookingModel;

  _ProductBookingState({this.product});

  var top = 0.0;
  void onBooking(BuildContext ct, BookingInfo bookingInfo) {
    if (bookingInfo.isEmpty == false) {
      product.bookingInfo = bookingInfo;
      addToCartForProductBooking(ct);
    }
  }

  void addToCartForProductBooking(BuildContext ct) {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    cartModel.addProductToCart(product: product, quantity: 1);
  }

  @override
  void initState() {
    super.initState();
    _bookingModel = BookingModel(product.id);
  }

  @override
  Widget build(BuildContext context) {
    return SliverFillViewport(
      delegate: SliverChildListDelegate([
        BookingWidget(
          key: ValueKey('booking${product.id}'),
          idProduct: product.id,
          controller: _bookingModel.controller,
          onBooking: (bookingInfo) {
            onBooking(context, bookingInfo);
          },
          updateSlot: _bookingModel.updateSlot,
        ),
      ]),
    );
  }
}
