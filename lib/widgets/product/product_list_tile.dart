import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show AppModel, CartModel, Product, RecentModel;
import '../../routes/aware.dart';
import '../../screens/index.dart' show ProductDetailScreen;
import '../common/sale_progress_bar.dart';
import '../common/start_rating.dart';
import 'heart_button.dart';

class ProductItemTileView extends StatelessWidget {
  final Product item;
  final EdgeInsets padding;
  final bool showProgressBar;

  ProductItemTileView({
    this.item,
    this.padding,
    this.showProgressBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTapProduct(context),
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(width: 8),
            Flexible(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2.0),
                child: Stack(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 15.0),
                      child: getImageFeature(
                        () => onTapProduct(context),
                      ),
                    ),
                    if ((item.onSale ?? false) && item.regularPrice.isNotEmpty)
                      InkWell(
                        onTap: () => onTapProduct(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(8))),
                          child: Text(
                            '${(100 - double.parse(item.price) / double.parse(item.regularPrice.toString()) * 100).toInt()} %',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
            if (item != null)
              Flexible(
                flex: 3,
                child: _ProductDescription(
                  item: item,
                  showProgressBar: showProgressBar,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget getImageFeature(onTapProduct) {
    return GestureDetector(
      onTap: onTapProduct,
      child: Tools.image(
        url: item.imageFeature,
        size: kSize.medium,
        isResize: true,
        // height: _height,
        fit: BoxFit.fitHeight,
      ),
    );
  }

  void onTapProduct(context) {
    if (item.imageFeature == '') return;
    Provider.of<RecentModel>(context, listen: false).addRecentProduct(item);
    //Load update item detail screen for FluxBuilder
    eventBus.fire('detail');

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => RouteAwareWidget(
          'detail',
          child: ProductDetailScreen(product: item),
        ),
        fullscreenDialog: kIsWeb,
      ),
    );
  }
}

class _ProductDescription extends StatelessWidget {
  const _ProductDescription({
    Key key,
    this.item,
    this.showProgressBar = false,
  }) : super(key: key);

  final Product item;
  final bool showProgressBar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final addProductToCart =
        Provider.of<CartModel>(context, listen: false).addProductToCart;

    final currency = Provider.of<AppModel>(context, listen: false).currency;
    final currencyRate = Provider.of<AppModel>(context).currencyRate;

    final isTablet = Tools.isTablet(MediaQuery.of(context));

    var isSale = (item.onSale ?? false) &&
        Tools.getPriceProductValue(item, currency, onSale: true) !=
            Tools.getPriceProductValue(item, currency, onSale: false);

    var ratingCountFontSize = isTablet ? 16.0 : 12.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 10),
            if (item.categoryName != null)
              Text(
                item.categoryName.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            Text(
              item.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15.0,
              ),
            ),
            const SizedBox(height: 4),
            if (item.tagLine != null)
              Text(
                '${item.tagLine}',
                maxLines: 1,
                style: const TextStyle(fontSize: 13),
              ),
            if (isSale) const SizedBox(width: 5),
            Wrap(
              children: <Widget>[
                Text(
                  item.type == 'grouped'
                      ? 'From ${Tools.getPriceProduct(item, currencyRate, currency, onSale: true)}'
                      : Tools.getPriceProduct(item, currencyRate, currency,
                          onSale: true),
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        fontSize: 18,
                        color: theme.accentColor,
                      ),
                ),
                const SizedBox(width: 10),
                if (isSale)
                  Text(
                    Tools.getPriceProduct(item, currencyRate, currency,
                        onSale: false),
                    style: Theme.of(context).textTheme.headline6.copyWith(
                          fontSize: 16,
                          color: Theme.of(context).accentColor.withOpacity(0.5),
                          decoration: TextDecoration.lineThrough,
                        ),
                  ),
              ],
            ),
            SizedBox(height: (showProgressBar ?? false) ? 16 : 20),
            _buildStockStatus(context),
            const SizedBox(height: 6),
            if (kAdvanceConfig['EnableRating'])
              if (kAdvanceConfig['hideEmptyProductListRating'] == false ||
                  (item.ratingCount != null && item.ratingCount > 0))
                SmoothStarRating(
                  allowHalfRating: true,
                  starCount: 5,
                  rating: item.averageRating ?? 0.0,
                  size: 14,
                  label: Text(
                    item.ratingCount == 0 || item.ratingCount == null
                        ? ''
                        : '${item.ratingCount} ',
                    style: TextStyle(
                      fontSize: ratingCountFontSize,
                    ),
                  ),
                  spacing: 0.0,
                ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if (!item.isEmptyProduct() &&
                    item.type != 'variable' &&
                    item.inStock != null &&
                    item.inStock)
                  FlatButton(
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text(S.of(context).addToCart),
                    onPressed: () => addProductToCart(product: item),
                  ),
                const Spacer(),
                CircleAvatar(child: HeartButton(product: item, size: 18)),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildStockStatus(BuildContext context) {
    if (showProgressBar ?? false) {
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: SaleProgressBar(
            width: MediaQuery.of(context).size.width, product: item),
      );
    }

    if (kAdvanceConfig['showStockStatus'] && !item.isEmptyProduct()) {
      if (item.backOrdered != null && item.backOrdered) {
        return Text(
          '${S.of(context).backOrder}',
          style: const TextStyle(
            color: kColorBackOrder,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        );
      }
      if (item.inStock != null) {
        return Text(
          item.inStock ? S.of(context).inStock : S.of(context).outOfStock,
          style: TextStyle(
            color: item.inStock ? kColorInStock : kColorOutOfStock,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        );
      }
    }
    return const SizedBox();
  }
}
