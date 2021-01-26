import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../generated/l10n.dart';
import '../../../models/index.dart' show AppModel, Product;
import '../../../services/index.dart' show Services;
import 'pinterest_card.dart';

class PinterestLayout extends StatefulWidget {
  final config;

  PinterestLayout({this.config});

  @override
  _PinterestLayoutState createState() => _PinterestLayoutState();
}

class _PinterestLayoutState extends State<PinterestLayout> {
  final Services _service = Services();
  List<Product> _products = [];
  int _page = 0;
  bool _isEnd = false;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();

    _loadProduct();
  }

  void _loadProduct() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    var config = widget.config;
    _page = _page + 1;
    config['page'] = _page;
    config['limit'] = 10;

    var newProducts = await _service.api.fetchProductsLayout(
        config: config,
        lang: Provider.of<AppModel>(context, listen: false).langCode);
    var isExisted = newProducts.isNotEmpty &&
        _products.indexWhere((o) => o.id == newProducts[0].id) > -1;
    if (newProducts != null && !isExisted) {
      _products = [..._products, ...newProducts];
      if (newProducts.length < config['limit']) {
        _isEnd = true;
      }
    }
    _isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: StaggeredGridView.countBuilder(
            crossAxisCount: 4,
            mainAxisSpacing: 4.0,
            shrinkWrap: true,
            primary: false,
            crossAxisSpacing: 4.0,
            itemCount: _products.length,
            itemBuilder: (context, index) => PinterestCard(
              item: _products[index],
              showOnlyImage: widget.config['showOnlyImage'],
              width: MediaQuery.of(context).size.width / 2,
              showCart: false,
            ),
            staggeredTileBuilder: (index) => const StaggeredTile.fit(2),
          ),
        ),
        _isEnd
            ? Text(S.of(context).noData)
            : VisibilityDetector(
                key: const Key('loading_visible'),
                child: Center(
                  child: Text(S.of(context).loading),
                ),
                onVisibilityChanged: (VisibilityInfo info) => _loadProduct(),
              )
      ],
    );
  }
}
