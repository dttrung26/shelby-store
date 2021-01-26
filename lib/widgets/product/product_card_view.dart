import 'dart:math' as math;

import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show AppModel, RecentModel, CartModel, Product;
import '../../routes/flux_navigate.dart';
import '../../services/service_config.dart';
import '../common/sale_progress_bar.dart';
import '../common/start_rating.dart';
import 'heart_button.dart';

class ProductCard extends StatelessWidget {
  final Product item;
  final double width;
  final double maxWidth;
  final double marginRight;
  final kSize size;
  final bool showCart;
  final bool showHeart;
  final bool showProgressBar;
  final height;
  final bool hideDetail;
  final offset;
  final tablet;
  final double ratioProductImage;

  ProductCard({
    this.item,
    this.width,
    this.maxWidth,
    this.size = kSize.medium,
    this.showHeart = false,
    this.showCart = false,
    this.showProgressBar = false,
    this.height,
    this.offset,
    this.hideDetail = false,
    this.tablet,
    this.marginRight = 6.0,
    this.ratioProductImage = 1.2,
  });

  @override
  Widget build(BuildContext context) {
    final addProductToCart =
        Provider.of<CartModel>(context, listen: false).addProductToCart;
    final currency = Provider.of<AppModel>(context, listen: false).currencyCode;
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    var salePercent = 0;

    if (item == null) return const SizedBox();

    var regularPrice = 0.0;
    var productImage = width * (ratioProductImage ?? 1.2);

    // ignore: unrelated_type_equality_checks
    if (item.regularPrice != null &&
        item.regularPrice.isNotEmpty &&
        item.regularPrice != '0.0') {
      regularPrice = (double.tryParse(item.regularPrice.toString()));
    }

    final gauss = offset != null
        ? math.exp(-(math.pow(offset.abs() - 0.5, 2) / 0.08))
        : 0.0;

    /// Calculate the Sale price
    var isSale = (item.onSale ?? false) &&
        Tools.getPriceProductValue(item, currency, onSale: true) !=
            Tools.getPriceProductValue(item, currency, onSale: false);
    if (isSale && regularPrice != 0) {
      salePercent =
          (double.parse(item.salePrice) - regularPrice) * 100 ~/ regularPrice;
    }

    if (item.type == 'variable') {
      isSale = item.onSale ?? false;
    }

    if (hideDetail) {
      return _buildImageFeature(
        context,
        () => _onTapProduct(context),
      );
    }

    var priceProduct = Tools.getPriceProductValue(
      item,
      currency,
      onSale: true,
    );

    /// Sold by widget
    var _soldByStore = item.store != null && item.store.name != ''
        ? Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 2),
            child: Text(
              S.of(context).soldBy + ' ' + item.store.name,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            ),
          )
        : const SizedBox();

    /// product name
    Widget _productTitle = Text(
      item.name + '\n' ?? '',
      style: Theme.of(context).textTheme.subtitle1.apply(
            fontSizeFactor: 0.9,
          ),
      maxLines: 2,
    );

    /// Product Pricing
    Widget _productPricing = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(
          item.type == 'grouped'
              ? '${S.of(context).from} ${Tools.getPriceProduct(item, currencyRate, currency, onSale: true)}'
              : priceProduct == '0.0'
                  ? S.of(context).loading
                  : Config().isListingType
                      ? Tools.getCurrencyFormatted(
                          item.price ?? item.regularPrice ?? '0', null)
                      : Tools.getPriceProduct(item, currencyRate, currency,
                          onSale: true),
          style: Theme.of(context)
              .textTheme
              .headline6
              .copyWith(
                fontWeight: FontWeight.w600,
              )
              .apply(fontSizeFactor: 0.8),
        ),

        /// Not show regular price for variant product (product.regularPrice = "").
        if (isSale && item.type != 'variable') ...[
          const SizedBox(width: 5),
          Text(
            item.type == 'grouped'
                ? ''
                : Tools.getPriceProduct(item, currencyRate, currency,
                    onSale: false),
            style: Theme.of(context)
                .textTheme
                .caption
                .copyWith(
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).accentColor.withOpacity(0.6),
                  decoration: TextDecoration.lineThrough,
                )
                .apply(fontSizeFactor: 0.8),
          ),
        ]
      ],
    );

    /// Product Stock Status
    var _stockStatus = _buildStockStatus(context);

    /// product rating, Hide rating for onSale layout.
    Widget _rating = (kAdvanceConfig['EnableRating']) &&
            (kAdvanceConfig['hideEmptyProductListRating'] == false ||
                (item.ratingCount != null && item.ratingCount > 0)) &&
            !(showProgressBar ?? false)
        ? SmoothStarRating(
            allowHalfRating: true,
            starCount: 5,
            rating: item.averageRating ?? 0.0,
            size: 10.0,
            color: kColorRatingStar,
            borderColor: kColorRatingStar,
            label: Text(
              item.ratingCount == 0 || item.ratingCount == null
                  ? ''
                  : '${item.ratingCount}',
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .apply(fontSizeFactor: 0.7),
            ),
            spacing: 0.0)
        : Container();

    /// Show Cart button
    Widget _showCart = (showCart &&
            !item.isEmptyProduct() &&
            item.inStock != null &&
            item.inStock &&
            item.type != 'variable')
        ? IconButton(
            icon: const Icon(Icons.add_shopping_cart, size: 18),
            onPressed: () {
              var message = addProductToCart(product: item, context: context);
              _showFlashNotification(item, message, context);
            })
        : Container(width: 30, height: 30);

    /// Show Stock status & Rating
    Widget _productStockRating = Align(
      alignment: Alignment.bottomLeft,
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _stockStatus,
                    _rating,
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
          Positioned(
            right: 0,
            top: -14,
            child: _showCart,
          )
        ],
      ),
    );

    Widget _productImage = Stack(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(maxHeight: productImage),
          child: Transform.translate(
            offset: Offset(18 * gauss, 0.0),
            child: _buildImageFeature(
              context,
              () => _onTapProduct(context),
            ),
          ),
        ),

        /// Not show sale percent for variant product (product.regularPrice = "").
        if (isSale &&
            (item.regularPrice?.isNotEmpty ?? false) &&
            regularPrice != null &&
            regularPrice != 0.0 &&
            item.type != 'variable')
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(12))),
              child: Text(
                '$salePercent%',
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )
                    .apply(fontSizeFactor: 0.9),
              ),
            ),
          ),

        /// Show On Sale label for variant product.
        if (isSale && item.type == 'variable')
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(8))),
              child: Text(
                S.of(context).onSale,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ),
      ],
    );

    Widget _productInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _productTitle,
        _soldByStore,
        const SizedBox(height: 5),
        _productPricing,
        const SizedBox(height: 2),
        _productStockRating,
      ],
    );

    return GestureDetector(
      onTap: () => _onTapProduct(context),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: <Widget>[
          Container(
            constraints: BoxConstraints(maxWidth: maxWidth ?? width),
            width: width - 6,
            margin: const EdgeInsets.only(top: 4, right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(3.0),
              // boxShadow: [
              //   const BoxShadow(
              //     color: Colors.black12,
              //     offset: Offset(0, 1),
              //     blurRadius: 2,
              //   ),
              // ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _productImage,
                _productInfo,
              ],
            ),
          ),
          if (showHeart && !item.isEmptyProduct())
            Positioned(
              top: 5,
              right: 5,
              child: HeartButton(product: item, size: 18),
            )
        ],
      ),
    );
  }

  Widget _buildImageFeature(context, onTapProduct) {
    if (item.imageFeature != null &&
        item.imageFeature.contains('placeholder')) {
      return Container(
        height: double.infinity * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 10,
        ),
        child: Text(
          item.name,
          style: Theme.of(context)
              .textTheme
              .headline5
              .copyWith(color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: onTapProduct,
      child: Tools.image(
        url: item.imageFeature,
        width: width,
        size: kSize.medium,
        isResize: true,
        fit: BoxFit.cover,
        offset: offset ?? 0.0,
      ),
    );
  }

  void _onTapProduct(context) {
    if (item.imageFeature == '') return;
    Provider.of<RecentModel>(context, listen: false).addRecentProduct(item);
    //Load update product detail screen for FluxBuilder
    eventBus.fire('detail');
    FluxNavigate.pushNamed(
      RouteList.productDetail,
      arguments: item,
    );
  }

  void _showFlashNotification(Product product, String message, context) {
    if (message.isNotEmpty) {
      showFlash(
        context: context,
        duration: const Duration(seconds: 3),
        builder: (context, controller) {
          return Flash(
            borderRadius: BorderRadius.circular(3.0),
            backgroundColor: Theme.of(context).errorColor,
            controller: controller,
            style: FlashStyle.floating,
            position: FlashPosition.top,
            horizontalDismissDirection: HorizontalDismissDirection.horizontal,
            child: FlashBar(
              icon: const Icon(
                Icons.check,
                color: Colors.white,
              ),
              message: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      );
    } else {
      showFlash(
        context: context,
        duration: const Duration(seconds: 3),
        builder: (context, controller) {
          return Flash(
            borderRadius: BorderRadius.circular(3.0),
            backgroundColor: Theme.of(context).primaryColor,
            controller: controller,
            style: FlashStyle.floating,
            position: FlashPosition.top,
            horizontalDismissDirection: HorizontalDismissDirection.horizontal,
            child: FlashBar(
              icon: const Icon(
                Icons.check,
                color: Colors.white,
              ),
              title: Text(
                product.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.0,
                ),
              ),
              message: Text(
                S.of(context).addToCartSucessfully,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildStockStatus(BuildContext context) {
    if (showProgressBar ?? false) {
      return SaleProgressBar(width: width, product: item);
    }

    return (kAdvanceConfig['showStockStatus'] && !item.isEmptyProduct())
        ? item.backOrdered != null && item.backOrdered
            ? Text(
                '${S.of(context).backOrder}',
                style: const TextStyle(
                  color: kColorBackOrder,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              )
            : item.inStock != null
                ? Text(
                    item.inStock
                        ? S.of(context).inStock
                        : S.of(context).outOfStock,
                    style: TextStyle(
                      color: item.inStock ? kColorInStock : kColorOutOfStock,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  )
                : Container()
        : Container();
  }
}
