import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../../../../common/config.dart';
import '../../../../common/theme/colors.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/entities/index.dart';
import '../../../../models/wishlist_model.dart';
import '../../../../widgets/common/image_galery.dart';
import '../themes/full_size_image_type.dart';
import '../themes/half_size_image_type.dart';
import '../themes/simple_type.dart';

class ListingDetail extends StatelessWidget {
  final Product product;

  static void showMenu(context, product) {
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
                    Share.share(product.permalink);
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
              ),
            ],
          );
        });
  }

  ListingDetail({this.product});

  @override
  Widget build(BuildContext context) {
    var layoutType = kProductDetail['layout'] ?? 'simpleType';

    switch (layoutType) {
      case 'simpleType':
        return ListingSimpleLayout(product: product);
      case 'halfSizeImageType':
        return ListingHalfSizeLayout(product: product);
      case 'fullSizeImageType':
        return ListingFullSizeLayout(product: product);
      default:
        return ListingSimpleLayout(product: product);
    }
  }
}
