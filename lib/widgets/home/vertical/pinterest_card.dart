import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../models/index.dart' show CartModel, Product;
import '../../common/start_rating.dart';
import '../../product/heart_button.dart';

class PinterestCard extends StatelessWidget {
  final Product item;
  final width;
  final marginRight;
  final kSize size;
  final bool showCart;
  final bool showHeart;
  final bool showOnlyImage;

  PinterestCard({
    this.item,
    this.width,
    this.size = kSize.medium,
    this.showHeart = true,
    this.showCart = false,
    this.showOnlyImage = false,
    this.marginRight = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final addProductToCart = Provider.of<CartModel>(context).addProductToCart;
    final currency = Provider.of<CartModel>(context).currency;
    final currencyRates = Provider.of<CartModel>(context).currencyRates;
    final isTablet = Tools.isTablet(MediaQuery.of(context));

    var titleFontSize = isTablet ? 24.0 : 14.0;
    var iconSize = isTablet ? 24.0 : 18.0;
    var starSize = isTablet ? 20.0 : 10.0;

    void onTapProduct() {
      if (item.imageFeature == '') return;

      Navigator.of(context).pushNamed(
        RouteList.productDetail,
        arguments: item,
      );
    }

    return GestureDetector(
      onTap: onTapProduct,
      child: Container(
        color: Theme.of(context).cardColor,
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Tools.image(
                  url: item.imageFeature,
                  width: width,
                  size: kSize.medium,
                  isResize: true,
                  fit: BoxFit.contain,
                ),
                if (showOnlyImage == null || !showOnlyImage)
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 8,
                      right: 8,
                    ),
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
                        item.tagLine != null
                            ? Text(
                                '${item.tagLine}',
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            : const SizedBox(),
                        const SizedBox(height: 6),
                        Text(
                            Tools.getPriceProduct(
                                item, currencyRates, currency),
                            style: TextStyle(color: theme.accentColor)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            if (kAdvanceConfig['EnableRating'])
                              Expanded(
                                child: SmoothStarRating(
                                    allowHalfRating: true,
                                    starCount: 5,
                                    label: Text(
                                      '${item.ratingCount}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    rating: item.averageRating ?? 0.0,
                                    size: starSize,
                                    color: theme.primaryColor,
                                    borderColor: theme.primaryColor,
                                    spacing: 0.0),
                              ),
                            if (showCart && !item.isEmptyProduct())
                              IconButton(
                                icon: Icon(
                                  Icons.add_shopping_cart,
                                  size: iconSize,
                                ),
                                onPressed: () {
                                  addProductToCart(product: item);
                                },
                              )
                          ],
                        )
                      ],
                    ),
                  )
              ],
            ),
            if (showHeart && !item.isEmptyProduct())
              Positioned(
                top: 0,
                right: 0,
                child: HeartButton(product: item, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}
