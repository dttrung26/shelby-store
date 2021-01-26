import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show AppModel, Product;
import '../../services/index.dart';
import '../../widgets/product/product_card_view.dart';

class RelatedProduct extends StatefulWidget {
  final Product product;

  RelatedProduct(this.product);

  @override
  _RelatedProductState createState() => _RelatedProductState();
}

class _RelatedProductState extends State<RelatedProduct> {
  final _memoizer = AsyncMemoizer<List<Product>>();

  final services = Services();

  Future<List<Product>> getRelativeProducts(context) => _memoizer.runOnce(() {
        return services.api.fetchProductsByCategory(
            categoryId: widget.product.categoryId,
            lang: Provider.of<AppModel>(context).langCode);
      });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return FutureBuilder<List<Product>>(
          future: getRelativeProducts(context),
          builder:
              (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Container(
                  height: 100,
                  child: kLoadingWidget(context),
                );
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Container(
                    height: 100,
                    child: Center(
                      child: Text(
                        S.of(context).error(snapshot.error),
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                    ),
                  );
                } else if (snapshot.data.isEmpty) {
                  return const SizedBox();
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18.0,
                          horizontal: 16.0,
                        ),
                        child: Text(
                          S.of(context).youMightAlsoLike,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                          height: constraint.maxWidth * 0.9,
                          child: ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            cacheExtent: MediaQuery.of(context).size.width,
                            scrollDirection: Axis.horizontal,
                            children: [
                              for (var item in snapshot.data)
                                if (item.id != widget.product.id)
                                  ProductCard(
                                      item: item,
                                      width: constraint.maxWidth * 0.35)
                            ],
                          ))
                    ],
                  );
                }
            }
            return const SizedBox(); // unreachable
          },
        );
      },
    );
  }
}
