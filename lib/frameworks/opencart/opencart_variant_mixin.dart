import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../models/index.dart'
    show CartModel, Product, ProductAttribute, ProductVariation;
import '../../screens/index.dart' show CartScreen;
import '../product_variant_mixin.dart';
import 'opencart_product_option.dart';

mixin OpencartVariantMixin on ProductVariantMixin {
  Map<String, dynamic> selectedOptions = <String, dynamic>{};
  Map<String, double> productExtraPrice = <String, double>{};

  Future<void> getProductVariations({
    BuildContext context,
    Product product,
    void Function({
      Product productInfo,
      List<ProductVariation> variations,
      Map<String, String> mapAttribute,
      ProductVariation variation,
    })
        onLoad,
  }) async {
    updateVariation(null, null);
    return;
  }

  bool couldBePurchased(
      List<ProductVariation> variations,
      ProductVariation productVariation,
      Product product,
      Map<String, String> mapAttribute) {
    final isAvailable =
        productVariation != null ? productVariation.sku != null : true;
    return isPurchased(productVariation, product, mapAttribute, isAvailable);
  }

  void onSelectProductVariant({
    ProductAttribute attr,
    String val,
    List<ProductVariation> variations,
    Map<String, String> mapAttribute,
    Function onFinish,
  }) {
    mapAttribute.update(attr.name, (value) {
      final option = attr.options
          .firstWhere((o) => o['label'] == val.toString(), orElse: () => null);
      if (option != null) {
        return option['value'].toString();
      }
      return val.toString();
    }, ifAbsent: () => val.toString());
    final productVariantion = updateVariation(variations, mapAttribute);
    onFinish(mapAttribute, productVariantion);
  }

  List<Widget> getProductAttributeWidget(
    String lang,
    Product product,
    Map<String, String> mapAttribute,
    Function onSelectProductVariant,
    List<ProductVariation> variations,
  ) {
    var listWidget = <Widget>[];
    if (product.options != null && product.options.isNotEmpty) {
      product.options.forEach((option) {
        listWidget.add(OpencartOptionInput(
          value: selectedOptions[option['product_option_id']],
          option: option,
          onChanged: (selected) {
            selectedOptions.addAll(Map<String, dynamic>.from(selected));
          },
          onPriceChanged: (extraPrice) {
            productExtraPrice.addAll(Map<String, double>.from(extraPrice));
          },
        ));
      });
    }
    return listWidget;
  }

  List<Widget> getProductTitleWidget(BuildContext context,
      ProductVariation productVariation, Product product) {
    final isAvailable =
        productVariation != null ? productVariation.sku != null : true;
    return makeProductTitleWidget(
        context, productVariation, product, isAvailable);
  }

  List<Widget> getBuyButtonWidget(
    BuildContext context,
    ProductVariation productVariation,
    Product product,
    Map<String, String> mapAttribute,
    int maxQuantity,
    int quantity,
    Function addToCart,
    Function onChangeQuantity,
    List<ProductVariation> variations,
  ) {
    final isAvailable =
        productVariation != null ? productVariation.sku != null : true;
    return makeBuyButtonWidget(context, productVariation, product, mapAttribute,
        maxQuantity, quantity, addToCart, onChangeQuantity, isAvailable);
  }

  @override
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

    var extraPrice = productExtraPrice.keys.fold(0.0, (sum, key) {
      return sum + productExtraPrice[key];
    });
    var p = Product.copyWith(product);
    p.price = (double.parse(product.price) + extraPrice).toString();

    var message = cartModel.addProductToCart(
        product: p,
        quantity: quantity,
        variation: productVariation,
        options: selectedOptions);

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
}
