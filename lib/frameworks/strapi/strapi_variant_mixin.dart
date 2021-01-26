import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../models/index.dart'
    show AppModel, Product, ProductAttribute, ProductModel, ProductVariation;
import '../../services/index.dart';
import '../../widgets/product/product_variant.dart';
import '../product_variant_mixin.dart';

mixin StrapiVariantMixin on ProductVariantMixin {
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
    if (product.attributes?.isEmpty ?? true) {
      return;
    }

    Map<String, String> mapAttribute = HashMap();
    var variations = <ProductVariation>[];
    Product productInfo;
    final lang = Provider.of<AppModel>(context, listen: false).langCode;
    await Services()
        .api
        .getProductVariations(product, lang: lang)
        .then((value) {
      variations = value.toList();
    });

    if (variations.isEmpty) {
      for (var attr in product.attributes) {
        mapAttribute.update(attr.name, (value) => attr.options[0],
            ifAbsent: () => attr.options[0]);
      }
    } else {
      await Services().api.getProduct(product.id, lang: lang).then((onValue) {
        if (onValue != null) {
          productInfo = onValue;
        }
      });
      for (var variant in variations) {
        if (variant.price == product.price) {
          for (var attribute in variant.attributes) {
            for (var attr in product.attributes) {
              mapAttribute.update(attr.name, (value) => attr.options[0],
                  ifAbsent: () => attr.options[0]);
            }
            mapAttribute.update(attribute.name, (value) => attribute.option,
                ifAbsent: () => attribute.option);
          }
          break;
        }
        if (mapAttribute.isEmpty) {
          for (var attribute in product.attributes) {
            mapAttribute.update(attribute.name, (value) => value, ifAbsent: () {
              return attribute.options[0];
            });
          }
        }
      }
    }

    final productVariantion = updateVariation(variations, mapAttribute);
    if (productVariantion != null) {
      Provider.of<ProductModel>(context, listen: false)
          .changeProductVariation(productVariantion);
    }
    onLoad(
        productInfo: productInfo,
        variations: variations,
        mapAttribute: mapAttribute);
    return;
  }

  bool couldBePurchased(
      List<ProductVariation> variations,
      ProductVariation productVariation,
      Product product,
      Map<String, String> mapAttribute) {
    final isAvailable =
        productVariation != null ? productVariation.id != null : true;

    return isPurchased(productVariation, product, mapAttribute, isAvailable);
  }

  void onSelectProductVariant({
    ProductAttribute attr,
    String val,
    List<ProductVariation> variations,
    Map<String, String> mapAttribute,
    Function onFinish,
  }) {
    mapAttribute.update(attr.name, (value) => val.toString(),
        ifAbsent: () => val.toString());
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

    final checkProductAttribute =
        product.attributes != null && product.attributes.isNotEmpty;
    if (checkProductAttribute) {
      for (var attr in product.attributes) {
        if (attr.name != null && attr.name.isNotEmpty) {
          var options = List<String>.from(attr.options);

          var selectedValue = mapAttribute[attr.name] ?? '';

          listWidget.add(
            BasicSelection(
              options: options,
              title: (kProductVariantLanguage[lang] != null &&
                      kProductVariantLanguage[lang][attr.name.toLowerCase()] !=
                          null)
                  ? kProductVariantLanguage[lang][attr.name.toLowerCase()]
                  : attr.name.toLowerCase(),
              type: ProductVariantLayout[attr.name.toLowerCase()] ?? 'box',
              value: selectedValue,
              onChanged: (val) => onSelectProductVariant(
                  attr: attr,
                  val: val,
                  mapAttribute: mapAttribute,
                  variations: variations),
            ),
          );
          listWidget.add(
            const SizedBox(height: 20.0),
          );
        }
      }
    }
    return listWidget;
  }

  List<Widget> getProductTitleWidget(
      BuildContext context, productVariation, product) {
    final isAvailable =
        productVariation != null ? productVariation.id != null : true;
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
        productVariation != null ? productVariation.id != null : true;

    return makeBuyButtonWidget(context, productVariation, product, mapAttribute,
        maxQuantity, quantity, addToCart, onChangeQuantity, isAvailable);
  }
}
