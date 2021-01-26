import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/tools.dart';
import '../../models/index.dart' show Product, ProductModel, ProductVariation;
import '../../widgets/common/image_galery.dart';

class VariantImageFeature extends StatelessWidget {
  final Product product;

  VariantImageFeature(this.product);

  @override
  Widget build(BuildContext context) {
    ProductVariation productVariation;
    productVariation = Provider.of<ProductModel>(context).productVariation;
    final imageFeature = productVariation != null
        ? productVariation.imageFeature
        : product.imageFeature;

    void _onShowGallery(context, [index = 0]) {
      Navigator.push(
        context,
        PageRouteBuilder(pageBuilder: (context, __, ___) {
          return ImageGalery(images: product.images, index: index);
        }),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return FlexibleSpaceBar(
          background: GestureDetector(
            onTap: () => _onShowGallery(context),
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: double.parse(kProductDetail['marginTop'].toString()),
                  child: Tools.image(
                    url: imageFeature,
                    fit: BoxFit.contain,
                    isResize: true,
                    size: kSize.medium,
                    width: constraints.maxWidth,
                    hidePlaceHolder: true,
                  ),
                ),
                Positioned(
                  top: double.parse(kProductDetail['marginTop'].toString()),
                  child: Tools.image(
                    url: imageFeature,
                    fit: BoxFit.contain,
                    width: constraints.maxWidth,
                    size: kSize.large,
                    hidePlaceHolder: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
