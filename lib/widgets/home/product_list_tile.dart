import 'package:flutter/material.dart';

import '../../models/index.dart' show Product;
import '../../widgets/product/product_list_tile.dart' show ProductItemTileView;

class ProductListTitle extends StatelessWidget {
  final List<Product> products;

  ProductListTitle(this.products);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxWidth,
          child: PageView(
            children: <Widget>[
              for (var i = 0; i < products.length; i = i + 3)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    products[i] != null
                        ? Expanded(
                            child: ProductItemTileView(item: products[i]),
                          )
                        : Container(),
                    i + 1 < products.length
                        ? Expanded(
                            child: ProductItemTileView(item: products[i + 1]),
                          )
                        : Container(),
                    i + 2 < products.length
                        ? Expanded(
                            child: ProductItemTileView(item: products[i + 2]),
                          )
                        : Container(),
                  ],
                )
            ],
          ),
        );
      },
    );
  }
}
