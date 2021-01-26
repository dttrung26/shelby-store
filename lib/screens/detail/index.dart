import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show AppModel, Product, WishListModel;
import '../../routes/flux_navigate.dart';
import '../../services/index.dart';
import '../../widgets/common/image_galery.dart';

export 'themes/full_size_image_type.dart';
export 'themes/half_size_image_type.dart';
export 'themes/simple_type.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  static void showMenu(context, product) {
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                  title:
                      Text(S.of(context).myCart, textAlign: TextAlign.center),
                  onTap: () {
                    Navigator.of(context).pop();
                    FluxNavigate.pushNamed(
                      RouteList.cart,
                      forceRootNavigator: true,
                    );
                  }),
              ListTile(
                  title: Text(S.of(context).showGallery,
                      textAlign: TextAlign.center),
                  onTap: () {
                    Navigator.of(context).pop();
                    showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return ImageGalery(images: product.images, index: 0);
                        });
                  }),
              ListTile(
                  title: Text(S.of(context).saveToWishList,
                      textAlign: TextAlign.center),
                  onTap: () {
                    Provider.of<WishListModel>(context, listen: false)
                        .addToWishlist(product);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                  title: Text(S.of(context).share, textAlign: TextAlign.center),
                  onTap: () {
                    Navigator.of(context).pop();
                    Share.share(
                      product.permalink,
                      sharePositionOrigin:
                          Rect.fromLTWH(0, 0, size.width, size.height / 2),
                    );
                  }),
              Container(
                height: 1,
                decoration: const BoxDecoration(color: kGrey200),
              ),
              ListTile(
                title: Text(
                  S.of(context).cancel,
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  ProductDetailScreen({this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailScreen> {
  Product product;
  @override
  void initState() {
    product = widget.product;
    Future.delayed(Duration.zero, () async {
      product = await Services().widget.getProductDetail(context, product);
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var productDetail =
        Provider.of<AppModel>(context).appConfig['Setting']['ProductDetail'];

    var layoutType =
        productDetail ?? (kProductDetail['layout'] ?? 'simpleType');

    var layout =
        Services().widget.renderDetailScreen(context, product, layoutType);
    return GestureDetector(
      onTap: () {
        var currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: layout,
    );
  }
}
