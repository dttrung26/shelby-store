import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show AppModel, Product, ProductModel, ProductVariation;
import '../../screens/base.dart';
import '../../widgets/common/countdown_timer.dart';
import '../../widgets/common/sale_progress_bar.dart';
import '../../widgets/common/start_rating.dart';

class ProductTitle extends StatefulWidget {
  final Product product;

  ProductTitle(this.product);

  @override
  _ProductTitleState createState() => _ProductTitleState();
}

class _ProductTitleState extends BaseScreen<ProductTitle> {
  var regularPrice;
  var onSale = false;
  int sale = 100;
  String price;
  ProductVariation productVariation;
  String dateOnSaleTo;

  @override
  void afterFirstLayout(BuildContext context) async {
    getProductPrice();
  }

  // ignore: always_declare_return_types
  getProductPrice() {
    try {
      regularPrice = productVariation != null
          ? productVariation.regularPrice
          : widget.product.regularPrice;
      onSale = productVariation != null
          ? productVariation.onSale
          : widget.product.onSale;
      price = productVariation != null &&
              (productVariation?.price?.isNotEmpty ?? false)
          ? productVariation.price
          : isNotBlank(widget.product.price)
              ? widget.product.price
              : widget.product.regularPrice;

      /// update the Sale price
      if (onSale) {
        price = productVariation != null
            ? productVariation.salePrice
            : isNotBlank(widget.product.salePrice)
                ? widget.product.salePrice
                : widget.product.price;
        dateOnSaleTo = productVariation != null
            ? productVariation.dateOnSaleTo
            : widget.product.dateOnSaleTo;
      }

      if (onSale && regularPrice.isNotEmpty && double.parse(regularPrice) > 0) {
        sale = (100 - (double.parse(price) / double.parse(regularPrice)) * 100)
            .toInt();
      }
    } catch (e, trace) {
      printLog(trace);
      printLog(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    productVariation = Provider.of<ProductModel>(context).productVariation;
    getProductPrice();

    final currency = Provider.of<AppModel>(context).currency;
    final currencyRate =
        Provider.of<AppModel>(context).currencyRate;
    final dateOnSaleTo = DateTime.tryParse(
            productVariation?.dateOnSaleTo ?? widget.product.dateOnSaleTo ?? '')
        ?.millisecondsSinceEpoch;
    final countDown =
        (dateOnSaleTo ?? 0) - DateTime.now().millisecondsSinceEpoch;
    var isShowCountDown = (kSaleOffProduct['ShowCountDown'] ?? false) &&
        dateOnSaleTo != null &&
        countDown > 0;

    var isSaleOff = (onSale &&
            widget.product.type != 'grouped' &&
            widget.product.type != 'variable') ||
        (onSale &&
            widget.product.type == 'variable' &&
            productVariation != null);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.product.vendor != null)
          Row(
            children: <Widget>[
              Text(
                widget.product.vendor,
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      fontWeight: FontWeight.w400,
                      color: theme.accentColor,
                    ),
              ),
            ],
          ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                widget.product.name,
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    .apply(fontSizeFactor: 0.9),
              ),
            ),
            if (isSaleOff)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                margin: const EdgeInsets.only(left: 4, top: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  S.of(context).sale('$sale'),
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                        color: Colors.white,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Text(
              widget.product.type != 'grouped'
                  ? Tools.getCurrencyFormatted(price ?? '0.0', currencyRate,
                      currency: currency)
                  : Provider.of<ProductModel>(context).detailPriceRange,
              style: Theme.of(context).textTheme.headline5.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),

            /// For variable product, hide regular price when loading product variation.
            if (isSaleOff)
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(width: 5),
                    Text(
                      Tools.getCurrencyFormatted(
                        regularPrice,
                        currencyRate,
                        currency: currency,
                      ),
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            color:
                                Theme.of(context).accentColor.withOpacity(0.6),
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.lineThrough,
                          ),
                    ),
                    const SizedBox(width: 10),
                    if (isShowCountDown) ...[
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          S.of(context).endsIn('').toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(
                                color: theme.accentColor.withOpacity(0.9),
                              )
                              .apply(fontSizeFactor: 0.6),
                        ),
                      ),
                      CountDownTimer(
                        Duration(milliseconds: countDown),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
        Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: [
            if (kAdvanceConfig['EnableRating'])
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: SmoothStarRating(
                  allowHalfRating: true,
                  starCount: 5,
                  spacing: 0.0,
                  rating: widget.product.averageRating,
                  size: 17.0,
                  label: Text(
                    ' (${widget.product.ratingCount})',
                    style: Theme.of(context).textTheme.subtitle2.copyWith(
                          color: Theme.of(context).accentColor.withOpacity(0.8),
                        ),
                  ),
                ),
              ),
            const Spacer(),
            if (dateOnSaleTo != null && countDown > 0)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SaleProgressBar(
                  product: widget.product,
                  productVariation: productVariation,
                  width: 160,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
