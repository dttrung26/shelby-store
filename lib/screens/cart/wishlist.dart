import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../models/wishlist_model.dart';
import '../../widgets/home/header/header_view.dart';
import '../../widgets/product/product_card_view.dart';

class WishList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<WishListModel>(builder: (context, model, child) {
      if (model.products.isNotEmpty) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                HeaderView(
                    headerText: S.of(context).myWishList,
                    showSeeAll: true,
                    callback: () {
                      Navigator.pushNamed(context, '/wishlist');
                    }),
                Container(
                    height: MediaQuery.of(context).size.width * 0.8,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var item in model.products)
                            ProductCard(
                                item: item,
                                showCart: true,
                                width: constraints.maxWidth * 0.35)
                        ],
                      ),
                    ))
              ],
            );
          },
        );
      }
      return Container();
    });
  }
}
