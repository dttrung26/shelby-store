import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../models/index.dart' show CartModel, Product;
import '../../../services/service_config.dart';
import '../../common/start_rating.dart';

class ProductSelectCard extends StatelessWidget {
  final Product item;
  final width;
  final marginRight;
  final kSize size;
  final bool showCart;
  final bool showHeart;

  ProductSelectCard(
      {this.item,
      this.width,
      this.size = kSize.medium,
      this.showHeart = false,
      this.showCart = false,
      this.marginRight = 10.0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final addProductToCart = Provider.of<CartModel>(context).addProductToCart;
    final currency = Provider.of<CartModel>(context).currency;
    final currencyRates = Provider.of<CartModel>(context).currencyRates;
    final isTablet = Tools.isTablet(MediaQuery.of(context));
    var titleFontSize = isTablet ? 24.0 : 14.0;
    var iconSize = isTablet ? 24.0 : 18.0;
    var starSize = isTablet ? 20.0 : 13.0;

    Future<Widget> getImage() async {
      return ClipRRect(
        child: Tools.image(
          url: item.imageFeature,
          width: width,
          size: kSize.medium,
          isResize: true,
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.circular(10),
      );
    }

    void onTapProduct() {
      if (item.imageFeature == '') return;

      Navigator.of(context).pushNamed(
        RouteList.productDetail,
        arguments: item,
      );
    }

    return Container(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.all(5),
      child: Column(
        children: <Widget>[
          FutureBuilder<Widget>(
            future: getImage(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  width: width,
                  height: width * 1.2,
                );
              }
              return GestureDetector(onTap: onTapProduct, child: snapshot.data);
            },
          ),
          Container(
            width: width,
            alignment: Alignment.topLeft,
            padding:
                const EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(item.name,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1),
                const SizedBox(height: 6),
                Text(Tools.getPriceProduct(item, currencyRates, currency),
                    style: TextStyle(color: theme.accentColor)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    if (kAdvanceConfig['EnableRating'])
                      SmoothStarRating(
                          allowHalfRating: true,
                          starCount: 5,
                          rating: item.averageRating ?? 0.0,
                          size: starSize,
                          label: Text('(${item.averageRating ?? 0.0})'),
                          color: theme.primaryColor,
                          borderColor: theme.primaryColor,
                          spacing: 0.0),
                    if (showCart &&
                        !item.isEmptyProduct() &&
                        !Config().isListingType)
                      Material(
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: InkWell(
                            child: Icon(
                              Icons.add_shopping_cart,
                              size: iconSize,
                            ),
                            onTap: () {
                              addProductToCart(product: item);
                            },
                            splashColor: Colors.grey,
                            radius: 10.0,
                          ),
                        ),
                      ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
