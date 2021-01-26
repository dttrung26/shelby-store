import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/index.dart' show Product, WishListModel;

class HeartButton extends StatelessWidget {
  final Product product;
  final double size;
  final Color color;

  HeartButton({Key key, this.product, this.size, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Provider.of<WishListModel>(context, listen: false),
      child: Consumer<WishListModel>(
        builder: (BuildContext context, WishListModel model, _) {
          final isExist = model.products
              .firstWhere((item) => item.id == product.id, orElse: () => null);
          if (isExist == null) {
            return IconButton(
              onPressed: () {
                Provider.of<WishListModel>(context, listen: false)
                    .addToWishlist(product);
              },
              icon: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.3),
                child: Icon(FontAwesomeIcons.heart,
                    color: Theme.of(context).accentColor.withOpacity(0.5),
                    size: size ?? 16.0),
              ),
            );
          }

          return IconButton(
            onPressed: () {
              Provider.of<WishListModel>(context, listen: false)
                  .removeToWishlist(product);
            },
            icon: CircleAvatar(
              backgroundColor: Colors.pink.withOpacity(0.1),
              child: Icon(FontAwesomeIcons.solidHeart,
                  color: Colors.pink, size: size ?? 16.0),
            ),
          );
        },
      ),
    );
  }
}
