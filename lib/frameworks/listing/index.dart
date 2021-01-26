import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart';
import '../../services/service_config.dart';
import '../woocommerce/index.dart';
import 'screens/add_listing_screen.dart';
import 'screens/booking_history/booking_history_screen.dart';
import 'screens/search/listing_search_screen.dart';
import 'screens/themes/full_size_image_type.dart';
import 'screens/themes/half_size_image_type.dart';
import 'screens/themes/simple_type.dart';
import 'widgets/listing_card_view.dart';

class ListingWidget extends WooWidget {
  @override
  bool get enableProductReview => true;

  @override
  Widget renderNewListing(context) {
    final user = Provider.of<UserModel>(context, listen: false).user;
    if (user == null || !Config().isListingType) {
      return Container();
    }

    if (user != null) {
      ///Listeo theme
      if (serverConfig['type'] == 'listeo') {
        if (user.role != null) {
          if (!user.role.toLowerCase().contains('owner')) {
            return Container();
          }
        } else {
          return Container();
        }
      }
    } else {
      return Container();
    }
    return Card(
      color: Theme.of(context).backgroundColor,
      margin: const EdgeInsets.only(bottom: 2.0),
      elevation: 0,
      child: ListTile(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => AddListingScreen(),
            ),
          );
        },
        leading: Icon(
          Icons.add_photo_alternate_outlined,
          size: 24,
          color: Theme.of(context).accentColor,
        ),
        title: Text(
          S.of(context).addListing,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Theme.of(context).accentColor,
        ),
      ),
    );
  }

  /// This feature is only support for the Listeo theme only ⚡
  @override
  Widget renderBookingHistory(context) {
    final user = Provider.of<UserModel>(context, listen: false).user;
    if (user == null || !Config().isListingType) {
      return Container();
    }

    if (user != null && serverConfig['type'] != 'listeo') {
      return Container();
    }

    return Card(
      color: Theme.of(context).backgroundColor,
      margin: const EdgeInsets.only(bottom: 2.0),
      elevation: 0,
      child: ListTile(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => BookingHistoryScreen(),
            ),
          );
        },
        leading: Icon(
          Icons.history,
          size: 24,
          color: Theme.of(context).accentColor,
        ),
        title: Text(
          S.of(context).bookingHistory,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Theme.of(context).accentColor,
        ),
      ),
    );
  }

  @override
  Widget renderDetailScreen(context, product, layoutType) {
    switch (layoutType) {
      case 'halfSizeImageType':
        return ListingHalfSizeLayout(product: product);
      case 'fullSizeImageType':
        return ListingFullSizeLayout(product: product);
      default:
        return ListingSimpleLayout(product: product);
    }
  }

  @override
  Widget renderSearchScreen(context, {showChat}) {
    return ListingSearchScreen();
  }

  @override
  Future<void> resetPassword(BuildContext context, String username) async {
    try {
      final val = await Provider.of<UserModel>(context, listen: false)
          .submitForgotPassword(
              forgotPwLink: '', data: {'user_login': username});
      if (val.isEmpty) {
        Tools.showSnackBar(
            Scaffold.of(context), S.of(context).checkConfirmLink);
        Future.delayed(
            const Duration(seconds: 1), () => Navigator.of(context).pop());
      } else {
        Tools.showSnackBar(Scaffold.of(context), val);
      }
      return;
    } catch (e) {
      printLog(e);
      return 'Unknown Error: $e';
    }
  }

  @override
  Widget renderProductCardView(
      {Product item,
      double width,
      double maxWidth,
      double height,
      bool showCart = false,
      bool showHeart = false,
      bool showProgressBar = false,
      double marginRight,
      double ratioProductImage = 1.2}) {
    return ListingCardView(
      item: item,
      width: width,
      height: height,
      showCart: showCart,
      showHeart: showHeart,
    );
  }
}
