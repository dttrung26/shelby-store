import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../common/config.dart';
import '../common/tools.dart';
import '../generated/l10n.dart';
import '../models/index.dart'
    show CartModel, Product, ProductModel, ProductVariation;
import '../screens/cart/cart.dart';
import '../widgets/common/webview.dart';
import '../widgets/product/product_variant.dart';

mixin ProductVariantMixin {
  ProductVariation updateVariation(
    List<ProductVariation> variations,
    Map<String, String> mapAttribute,
  ) {
    final templateVariation =
        variations.isNotEmpty ? variations.first.attributes : null;
    final listAttributes = variations.map((e) => e.attributes);

    ProductVariation productVariation;
    var attributeString = '';

    /// Flat attribute
    /// Example attribute = { "color": "RED", "SIZE" : "S", "Height": "Short" }
    /// => "colorRedsizeSHeightShort"
    templateVariation?.forEach((element) {
      final key = element.name;
      final value = mapAttribute[key];
      attributeString += value != null ? '$key$value' : '';
    });

    /// Find attributeS contain attribute selected
    final validAttribute = listAttributes.lastWhere(
      (attributes) =>
          attributes.map((e) => e.toString()).join().contains(attributeString),
      orElse: () => null,
    );

    if (validAttribute == null) return null;

    /// Find ProductVariation contain attribute selected
    /// Compare address because use reference
    productVariation =
        variations.lastWhere((element) => element.attributes == validAttribute);

    productVariation.attributes.forEach((element) {
      if (!mapAttribute.containsKey(element.name)) {
        mapAttribute[element.name] = element.option;
      }
    });
    return productVariation;
    // if (variations != null) {
    //   var variation = variations.firstWhere((item) {
    //     bool isCorrect = true;
    //     for (var attribute in item.attributes) {
    //       if (attribute.option != mapAttribute[attribute.name] &&
    //           (attribute.id != null ||
    //               checkVariantLengths(variations, mapAttribute))) {
    //         isCorrect = false;
    //         break;
    //       }
    //     }
    //     if (isCorrect) {
    //       for (var key in mapAttribute.keys.toList()) {
    //         bool check = false;
    //         for (var attribute in item.attributes) {
    //           if (key == attribute.name) {
    //             check = true;
    //             break;
    //           }
    //         }
    //         if (!check) {
    //           Attribute att = Attribute()
    //             ..id = null
    //             ..name = key
    //             ..option = mapAttribute[key];
    //           item.attributes.add(att);
    //         }
    //       }
    //     }
    //     return isCorrect;
    //   }, orElse: () {
    //     return null;
    //   });
    //   return variation;
    // }
    // return null;
  }

  // bool checkVariantLengths(variations, mapAttribute) {
  //   for (var variant in variations) {
  //     if (variant.attributes.length == mapAttribute.keys.toList().length) {
  //       bool check = true;
  //       for (var i = 0; i < variant.attributes.length; i++) {
  //         if (variant.attributes[i].option !=
  //             mapAttribute[variant.attributes[i].name]) {
  //           check = false;
  //           break;
  //         }
  //       }
  //       if (check) {
  //         return true;
  //       }
  //     }
  //   }
  //   return false;
  // }

  bool isPurchased(
    ProductVariation productVariation,
    Product product,
    Map<String, String> mapAttribute,
    bool isAvailable,
  ) {
    var inStock =
        productVariation != null ? productVariation.inStock : product.inStock;

    var isValidAttribute = false;
    try {
      if (product.attributes.length == mapAttribute.length &&
          (product.attributes.length == mapAttribute.length ||
              product.type != 'variable')) {
        isValidAttribute = true;
      }
    } catch (_) {}

    return inStock && isValidAttribute && isAvailable;
  }

  List<Widget> makeProductTitleWidget(BuildContext context,
      ProductVariation productVariation, Product product, bool isAvailable) {
    var listWidget = <Widget>[];

    var inStock = (productVariation != null
            ? productVariation.inStock
            : product.inStock) ??
        false;

    var stockQuantity = (kProductDetail['showStockQuantity'] ?? true) &&
            product.stockQuantity != null
        ? '  (${product.stockQuantity}) '
        : '';
    if (Provider.of<ProductModel>(context, listen: false).productVariation !=
        null) {
      stockQuantity = (kProductDetail['showStockQuantity'] ?? true) &&
              Provider.of<ProductModel>(context, listen: false)
                      .productVariation
                      .stockQuantity !=
                  null
          ? '  (${Provider.of<ProductModel>(context, listen: false).productVariation.stockQuantity}) '
          : '';
    }

    if (isAvailable) {
      listWidget.add(
        const SizedBox(height: 5.0),
      );

      listWidget.add(
        Row(
          children: <Widget>[
            if ((kProductDetail['showSku'] ?? true) &&
                product.sku != null &&
                product.sku != '') ...[
              Text(
                '${S.of(context).sku}: ',
                style: Theme.of(context).textTheme.subtitle2,
              ),
              Text(
                product.sku,
                style: Theme.of(context).textTheme.subtitle2.copyWith(
                      color: inStock
                          ? Theme.of(context).primaryColor
                          : const Color(0xFFe74c3c),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ],
        ),
      );

      listWidget.add(
        const SizedBox(height: 5.0),
      );

      listWidget.add(
        Row(
          children: <Widget>[
            if (kAdvanceConfig['showStockStatus']) ...[
              Text(
                '${S.of(context).availability}: ',
                style: Theme.of(context).textTheme.subtitle2,
              ),
              product.backOrdered != null && product.backOrdered
                  ? Text(
                      '${S.of(context).backOrder}',
                      style: Theme.of(context).textTheme.subtitle2.copyWith(
                            color: const Color(0xFFEAA601),
                            fontWeight: FontWeight.w600,
                          ),
                    )
                  : Text(
                      inStock
                          ? '${S.of(context).inStock}${stockQuantity ?? ''}'
                          : S.of(context).outOfStock,
                      style: Theme.of(context).textTheme.subtitle2.copyWith(
                            color: inStock
                                ? Theme.of(context).primaryColor
                                : const Color(0xFFe74c3c),
                            fontWeight: FontWeight.w600,
                          ),
                    )
            ],
          ],
        ),
      );

      if (product.shortDescription != null &&
          product.shortDescription.isNotEmpty) {
        listWidget.add(
          Container(
            margin: const EdgeInsets.only(top: 15),
            child: Html(
              data: product.shortDescription,
              onLinkTap: Tools.launchURL,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight.withOpacity(0.7),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        );
      }

      listWidget.add(
        const SizedBox(height: 15.0),
      );
    }

    return listWidget;
  }

  List<Widget> makeBuyButtonWidget(
    BuildContext context,
    ProductVariation productVariation,
    Product product,
    Map<String, String> mapAttribute,
    int maxQuantity,
    int quantity,
    Function addToCart,
    Function onChangeQuantity,
    bool isAvailable,
  ) {
    final theme = Theme.of(context);

    var inStock = (productVariation != null
            ? productVariation.inStock
            : product.inStock) ??
        false;
    final isExternal = product.type == 'external' ? true : false;

    final buyOrOutOfStockButton = Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: isExternal
            ? (inStock &&
                    (product.attributes.length == mapAttribute.length) &&
                    isAvailable)
                ? theme.primaryColor
                : theme.disabledColor
            : theme.primaryColor,
      ),
      child: Center(
        child: Text(
          ((inStock && isAvailable) || isExternal)
              ? S.of(context).buyNow.toUpperCase()
              : (isAvailable
                  ? S.of(context).outOfStock.toUpperCase()
                  : S.of(context).unavailable.toUpperCase()),
          style: Theme.of(context).textTheme.button.copyWith(
                color: Colors.white,
              ),
        ),
      ),
    );

    if (!inStock && !isExternal && !product.backOrdered) {
      return [
        buyOrOutOfStockButton,
      ];
    }

    if ((product.isPurchased ?? false) && (product.isDownloadable ?? false)) {
      return [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async => await Share.share(product.files[0]),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                      child: Text(
                    S.of(context).download,
                    style: Theme.of(context).textTheme.button.copyWith(
                          color: Colors.white,
                        ),
                  )),
                ),
              ),
            ),
          ],
        ),
      ];
    }

    return [
      if (!isExternal && (kProductDetail['showStockQuantity'] ?? true)) ...[
        const SizedBox(width: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                S.of(context).selectTheQuantity + ':',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Expanded(
              child: Container(
                height: 32.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                ),
                child: QuantitySelection(
                  expanded: true,
                  value: quantity,
                  color: theme.accentColor,
                  limitSelectQuantity: maxQuantity,
                  onChanged: onChangeQuantity,
                ),
              ),
            ),
          ],
        ),
      ],
      const SizedBox(height: 10),
      Row(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () => addToCart(true, inStock),
              child: buyOrOutOfStockButton,
            ),
          ),
          const SizedBox(width: 10),
          if (isAvailable && inStock && !isExternal)
            Expanded(
              child: GestureDetector(
                onTap: () => addToCart(false, inStock),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Theme.of(context).primaryColorLight,
                  ),
                  child: Center(
                    child: Text(
                      S.of(context).addToCart.toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      )
    ];
  }

  /// Add to Cart & Buy Now function
  void addToCart(BuildContext context, Product product, int quantity,
      ProductVariation productVariation, Map<String, String> mapAttribute,
      [bool buyNow = false, bool inStock = false]) {
    if (!inStock) {
      return;
    }

    final cartModel = Provider.of<CartModel>(context, listen: false);
    if (product.type == 'external') {
      openWebView(context, product);
      return;
    }

    final _mapAttribute = Map<String, String>.from(mapAttribute);
    productVariation =
        Provider.of<ProductModel>(context, listen: false).productVariation;
    var message = cartModel.addProductToCart(
        context: context,
        product: product,
        quantity: quantity,
        variation: productVariation,
        options: _mapAttribute);

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
      if (buyNow) {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => Scaffold(
              backgroundColor: Theme.of(context).backgroundColor,
              body: CartScreen(isModal: true, isBuyNow: true),
            ),
            fullscreenDialog: true,
          ),
        );
      }
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

  /// Support Affiliate product
  void openWebView(BuildContext context, Product product) {
    if (product.affiliateUrl == null || product.affiliateUrl.isEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back_ios),
            ),
          ),
          body: Center(
            child: Text(S.of(context).notFound),
          ),
        );
      }));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebView(
          url: product.affiliateUrl,
          title: product.name,
        ),
      ),
    );
  }
}
