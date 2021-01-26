import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart' show AppModel, Product;
import '../../../services/index.dart';
import '../../../widgets/product/product_card_view.dart';
import 'vertical_simple_list.dart';

class VerticalViewLayout extends StatefulWidget {
  final config;

  VerticalViewLayout({this.config, Key key}) : super(key: key);

  @override
  _PinterestLayoutState createState() => _PinterestLayoutState();
}

class _PinterestLayoutState extends State<VerticalViewLayout> {
  final Services _service = Services();
  List<Product> _products = [];
  bool canLoad = true;
  int _page = 0;

  void _loadProduct() async {
    var config = widget.config;
    _page = _page + 1;
    config['page'] = _page;
    if (!canLoad) return;
    var newProducts = await _service.api.fetchProductsLayout(
        config: config,
        lang: Provider.of<AppModel>(context, listen: false).langCode);
    if (newProducts.isEmpty) {
      setState(() {
        canLoad = false;
      });
    }
    setState(() {
      _products = [..._products, ...newProducts];
    });
  }

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  Widget build(BuildContext context) {
    var widthContent = 0;
    final isTablet = Tools.isTablet(MediaQuery.of(context));

    if (widget.config['layout'] == 'card') {
      widthContent = 1; //one column
    } else if (widget.config['layout'] == 'columns') {
      widthContent = isTablet ? 4 : 3; //three columns
    } else {
      //layout is list
      widthContent = isTablet ? 3 : 2; //two columns
    }
    // ignore: division_optimization
    var rows = (_products.length / widthContent).toInt();
    if (rows * widthContent < _products.length) rows++;

    return Column(
      children: [
        ListView.builder(
            cacheExtent: 1500,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _products.length,
            itemBuilder: (context, index) {
              if (widget.config['layout'] == 'list') {
                return SimpleListView(
                  item: _products[index],
                  type: SimpleListType.BackgroundColor,
                );
              }
              return Row(
                children: List.generate(widthContent, (child) {
                  return Expanded(
                    child: index * widthContent + child < _products.length
                        ? LayoutBuilder(
                            builder: (context, constraints) {
                              return ProductCard(
                                item: _products[index * widthContent + child],
                                showHeart: true,
                                showCart: widget.config['layout'] != 'columns',
                                width: constraints.maxWidth,
                              );
                            },
                          )
                        : Container(),
                  );
                }),
              );
            }),
        VisibilityDetector(
          key: const Key('loading_vertical'),
          child: !canLoad
              ? const SizedBox()
              : Center(
                  child: Text(S.of(context).loading),
                ),
          onVisibilityChanged: (VisibilityInfo info) => _loadProduct(),
        )
      ],
    );
  }
}
