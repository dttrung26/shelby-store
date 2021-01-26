import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart' show AppModel, Product;
import '../../../routes/flux_navigate.dart';

enum SimpleListType { BackgroundColor, PriceOnTheRight }

class SimpleListView extends StatelessWidget {
  final Product item;
  final SimpleListType type;

  SimpleListView({this.item, this.type});

  @override
  Widget build(BuildContext context) {
    if (item?.name == null) return const SizedBox();

    final currency = Provider.of<AppModel>(context).currency;
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    var screenWidth = MediaQuery.of(context).size.width;
    var titleFontSize = 15.0;
    var imageWidth = 60.0;
    var imageHeight = 60.0;

    final theme = Theme.of(context);

    var isSale = (item.onSale ?? false) &&
        Tools.getPriceProductValue(item, currency, onSale: true) !=
            Tools.getPriceProductValue(item, currency, onSale: false);
    if (item.type == 'variable') {
      isSale = item.onSale ?? false;
    }

    var priceProduct = Tools.getPriceProductValue(
      item,
      currency,
      onSale: true,
    );

    void onTapProduct() {
      if (item.imageFeature == '') return;
      FluxNavigate.pushNamed(
        RouteList.productDetail,
        arguments: item,
      );
    }

    /// Product Pricing
    Widget _productPricing = Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      children: <Widget>[
        Text(
          item.type == 'grouped'
              ? '${S.of(context).from} ${Tools.getPriceProduct(item, currencyRate, currency, onSale: true)}'
              : priceProduct == '0.0'
                  ? S.of(context).loading
                  : Tools.getPriceProduct(item, currencyRate, currency,
                      onSale: true),
          style: Theme.of(context).textTheme.headline6.copyWith(
                fontSize: 15,
                color: theme.accentColor,
              ),
        ),
        if (isSale) ...[
          const SizedBox(width: 5),
          Text(
            item.type == 'grouped'
                ? ''
                : Tools.getPriceProduct(item, currencyRate, currency,
                    onSale: false),
            style: Theme.of(context).textTheme.headline6.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).accentColor.withOpacity(0.6),
                  decoration: TextDecoration.lineThrough,
                ),
          ),
        ]
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: GestureDetector(
        onTap: onTapProduct,
        child: Container(
          width: screenWidth,
          decoration: BoxDecoration(
            color: type == SimpleListType.BackgroundColor
                ? Theme.of(context).primaryColorLight
                : null,
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  child: Tools.image(
                    url: item.imageFeature,
                    width: imageWidth,
                    size: kSize.medium,
                    isResize: true,
                    height: imageHeight,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(
                  width: 20.0,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      (type != SimpleListType.PriceOnTheRight)
                          ? _productPricing
                          : Container(),
                    ],
                  ),
                ),
                (type == SimpleListType.PriceOnTheRight)
                    ? Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: _productPricing,
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
