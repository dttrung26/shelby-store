import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart';
import '../../../services/index.dart';
import '../../../widgets/product/product_card_view.dart';

class ProductRelated extends StatefulWidget {
  final Product product;

  ProductRelated({this.product});

  @override
  _ProductRelatedState createState() => _ProductRelatedState();
}

class _ProductRelatedState extends State<ProductRelated> {
  final _memoizer = AsyncMemoizer<List<Product>>();
  final services = Services();

  Future<List<Product>> getRelativeProducts() => _memoizer.runOnce(() {
        printLog(Provider.of<ProductModel>(context, listen: false).categoryId);
        return services.api.fetchProductsByCategory(
          categoryId:
              Provider.of<ProductModel>(context, listen: false).categoryId,
          lang: Provider.of<AppModel>(context, listen: false).langCode,
          page: 1,
        );
      });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var screenWidth = constraints.maxWidth;
        return FutureBuilder<List<Product>>(
          future: getRelativeProducts(),
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
                  printLog('ProductRelated_Error: ${snapshot.error}');
                  return Container();
                } else if (snapshot.data == null || snapshot.data.isEmpty) {
                  return Container();
                } else {
                  var list = snapshot.data
                      .where((i) => i.id != widget.product.id)
                      .toList();
                  if (list.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 18.0, horizontal: 13.0),
                          child: Text(
                            S.of(context).youMightAlsoLike,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          height: screenWidth * 0.7,
                          padding: const EdgeInsets.symmetric(horizontal: 13.0),
                          child: ListView(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            children: [
                              for (var item in snapshot.data)
                                if (item.id != widget.product.id)
                                  ProductCard(
                                      item: item, width: screenWidth * 0.35)
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return Container();
                }
            }
            return Container(); // unreachable
          },
        );
      },
    );
  }
}
