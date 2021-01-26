import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/config.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/entities/index.dart';
import '../../../screens/index.dart';
import '../../../services/service_config.dart';
import 'booking/booking.dart';
import 'product_categories.dart';

class ProductTitleShort extends StatelessWidget {
  final Product product;
  final User user;

  ProductTitleShort({this.product, this.user});

  void _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _bookNow(context) {
    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserScreen(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingScreen(
            product: product,
          ),
        ),
      );
    }
  }

  List<Widget> getPricing(context) {
    final theme = Theme.of(context);
    return [
      if (product.price != null && product.regularPrice != null)
        Row(
          children: <Widget>[
            Icon(
              Icons.monetization_on,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(Tools.getCurrencyFormatted(product.regularPrice, null),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                )),
            const Text(' - ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                )),
            Text(Tools.getCurrencyFormatted(product.price, null),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ))
          ],
        ),
      const SizedBox(height: 2),
      if (product.averageRating != null && product.averageRating != 0.0)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              SmoothStarRating(
                allowHalfRating: true,
                starCount: 5,
                rating: product.averageRating ?? 0.0,
                size: 14.0,
                color: theme.primaryColor,
                borderColor: theme.primaryColor,
                spacing: 0.0,
              ),
              const SizedBox(width: 2),
              if (product.totalReview != 0)
                Text(
                  ' ${product.totalReview} ',
                  style: TextStyle(
                      fontSize: 14, color: Colors.black.withOpacity(0.7)),
                ),
            ],
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var list = <Widget>[];
    var supportBooking = Config().typeName == 'listeo';

    if (isNotBlank(product.location)) {
      list.add(InfoItem(
        icon: Icons.location_on,
        title: product.location,
      ));
    }
    if (isNotBlank(product.phone)) {
      list.add(InfoItem(
        icon: Icons.phone,
        title: product.phone,
        onTap: () async {
          await _launchURL('tel:' + product.phone);
        },
      ));
    }
    if (isNotBlank(product.email)) {
      list.add(InfoItem(
        icon: Icons.email,
        title: product.email,
        onTap: () async {
          await _launchURL('mailto:' + product.email);
        },
      ));
    }
    if (isNotBlank(product.website)) {
      list.add(InfoItem(
        icon: Icons.language,
        title: product.website,
        onTap: () async {
          await _launchURL(product.website);
        },
      ));
    }

    if (isNotBlank(product.location)) {
      list.add(InfoItem(
        icon: Icons.location_on,
        title: product.location,
      ));
    }

    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 5),
          ProductCategories(
              product: product, type: DataMapping().kTaxonomies['categories']),
          const SizedBox(height: 5),
          Text(
            product.name,
            style: TextStyle(
              fontSize: 30,
              color: Colors.black.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          ...getPricing(context),
          const SizedBox(height: 10),
          if (list.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: list,
              ),
            ),
          if (supportBooking)
            Center(
              child: FlatButton(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 40),
                color: Colors.redAccent,
                onPressed: () => _bookNow(context),
                child: Text(
                  S.of(context).bookingNow,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  InfoItem({this.title, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              icon,
              size: 16,
              color: Colors.black87,
            ),
            const SizedBox(
              width: 15.0,
            ),
            Expanded(
                child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black.withOpacity(0.9),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
