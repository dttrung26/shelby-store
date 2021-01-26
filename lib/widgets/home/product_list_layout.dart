import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/tools.dart';
import '../../models/index.dart'
    show AppModel, Product, ProductModel, RecentModel;
import '../../models/user_model.dart';
import '../../services/index.dart';
import '../../widgets/product/product_card_view.dart';
import '../common/custom_physic.dart';
import 'header/header_view.dart';
import 'product_list_tile.dart';
import 'product_staggered.dart';

class ProductListLayout extends StatefulWidget {
  final config;

  ProductListLayout({this.config, Key key}) : super(key: key);

  @override
  _ProductListLayoutState createState() => _ProductListLayoutState();
}

class _ProductListLayoutState extends State<ProductListLayout> {
  final Services _service = Services();

  Future<List<Product>> _getProductLayout;

  final _memoizer = AsyncMemoizer<List<Product>>();

  @override
  void initState() {
    /// only create the future once
    _getProductLayout = getProductLayout(context);
    super.initState();
  }

  double _buildProductWidth(screenWidth) {
    switch (widget.config['layout']) {
      case 'twoColumn':
        return screenWidth * 0.5;
      case 'threeColumn':
        return screenWidth * 0.35;
      case 'fourColumn':
        return screenWidth / 4;
      case 'recentView':
        return screenWidth * 0.35;
      case 'saleOff':
        return screenWidth * 0.35;
      case 'card':
      case 'listTile':
      default:
        return screenWidth - 10;
    }
  }

  double _buildProductMaxWidth(screenWidth) {
    switch (widget.config['layout']) {
      case 'twoColumn':
        return 300;
      case 'threeColumn':
        return 200;
      case 'fourColumn':
        return 150;
      case 'recentView':
        return 200;
      case 'saleOff':
        return 200;
      case 'card':
      case 'listTile':
      default:
        return 400;
    }
  }

  double _buildProductHeight(screenWidth, isTablet) {
    switch (widget.config['layout']) {
      case 'twoColumn':
      case 'threeColumn':
      case 'fourColumn':
      case 'recentView':
        return 200;
        break;
      case 'saleOff':
        return 200;
      case 'card':
      case 'listTile':
      default:
        var cardHeight = widget.config['height'] != null
            ? widget.config['height'] + 40.0
            : screenWidth * 1.4;
        // return isTablet ? screenWidth * 1.3 : cardHeight;
        return cardHeight;
        break;
    }
  }

  Widget getProductListWidgets(context, List<Product> products, width) {
    final isTablet = Tools.isTablet(MediaQuery.of(context));

    final physics = widget.config['isSnapping'] == true
        ? CustomScrollPhysic(width: _buildProductWidth(width) + 10)
        : const ScrollPhysics();

    if (products == null) return Container();

    var ratioProductImage =
        Provider.of<AppModel>(context, listen: false).ratioProductImage;

    return Container(
      color: Theme.of(context).backgroundColor,
      constraints: BoxConstraints(
        minHeight: _buildProductHeight(width, isTablet) ?? 0,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: physics,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(width: 12.0),
            for (var i = 0; i < products.length; i++)
              Services().widget.renderProductCardView(
                    item: products[i],
                    width: _buildProductWidth(width),
                    maxWidth: _buildProductMaxWidth(width),
                    height: _buildProductHeight(width, isTablet),
                    showProgressBar: widget.config['layout'] == 'saleOff',
                    ratioProductImage: ratioProductImage,
                  )
          ],
        ),
      ),
    );
  }

  Widget WaitingListItemTileWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        for (var i = 0; i < 4; i++)
          Container(
            width: 400,
            child: ListTile(
              leading: Container(
                width: 50,
                height: 100,
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                alignment: Alignment.center,
                color: Colors.grey.withOpacity(0.3),
              ),
              title: Container(
                width: 70,
                height: 30,
                color: Colors.grey.withOpacity(0.4),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Container(
                  width: 30,
                  height: 10,
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
              dense: false,
            ),
          ),
      ],
    );
  }

  Future<List<Product>> getProductLayout(context) => _memoizer.runOnce(() {
        if (widget.config['layout'] == 'recentView') {
          return Provider.of<RecentModel>(context, listen: false)
              .getRecentProduct();
        }

        if (widget.config['layout'] == 'saleOff') {
          /// Fetch only onSale products for saleOff layout.
          widget.config['onSale'] = true;
        }

        final _userId = Provider.of<UserModel>(context, listen: false).user?.id;
        return _service.api.fetchProductsLayout(
            config: widget.config,
            lang: Provider.of<AppModel>(context, listen: false).langCode,
            userId: _userId);
      });

  @override
  Widget build(BuildContext context) {
    final isTablet = Tools.isTablet(MediaQuery.of(context));
    final recentProduct = Provider.of<RecentModel>(context).products;
    final isRecentLayout = widget.config['layout'] == 'recentView';
    final isSaleOffLayout = widget.config['layout'] == 'saleOff';

    if (isRecentLayout && recentProduct.length < 3) return const SizedBox();

    return LayoutBuilder(
      builder: (context, constraint) {
        return FractionallySizedBox(
          widthFactor: 1.0,
          child: FutureBuilder<List<Product>>(
            future: _getProductLayout,
            builder:
                (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return widget.config['layout'] == 'listTile'
                      ? WaitingListItemTileWidget()
                      : Column(
                          children: <Widget>[
                            HeaderView(
                              headerText: widget.config['name'] ?? '',
                              showSeeAll: isRecentLayout ? false : true,
                              callback: () => ProductModel.showList(
                                  context: context, config: widget.config),
                            ),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: _buildProductHeight(
                                        constraint.maxWidth, isTablet) ??
                                    0,
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    const SizedBox(width: 10.0),
                                    for (var i = 0; i < 4; i++)
                                      ProductCard(
                                        item: Product.empty(i.toString()),
                                        width: _buildProductWidth(
                                            constraint.maxWidth),
                                        // tablet: constraint.maxWidth / MediaQuery.of(context).size.height > 1.2,
                                      )
                                  ],
                                ),
                              ),
                            )
                          ],
                        );
                case ConnectionState.done:
                default:
                  if (snapshot.hasError || snapshot.data == null) {
                    return Container();
                  } else {
                    var _durationInMilliSeconds =
                        _getCountDownDuration(snapshot.data, isSaleOffLayout);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (widget.config['image'] != null &&
                            widget.config['image'] != '')
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 15),
                            child: Tools.image(
                              url: widget.config['image'],
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ),
                          ),
                        HeaderView(
                          headerText: widget.config['name'] ?? '',
                          showSeeAll: isRecentLayout ? false : true,
                          margin: widget.config['image'] != null ? 6.0 : 10.0,
                          callback: () => ProductModel.showList(
                            context: context,
                            config: widget.config,
                            products: snapshot.data,
                            showCountdown: (widget.config['showCountDown'] ??
                                    kSaleOffProduct['ShowCountDown']) &&
                                isSaleOffLayout &&
                                _durationInMilliSeconds > 0,
                            countdownDuration:
                                Duration(milliseconds: _durationInMilliSeconds),
                          ),
                          showCountdown: (widget.config['showCountDown'] ??
                                  kSaleOffProduct['ShowCountDown']) &&
                              isSaleOffLayout &&
                              _durationInMilliSeconds > 0,
                          countdownDuration:
                              Duration(milliseconds: _durationInMilliSeconds),
                        ),
                        widget.config['layout'] == 'staggered'
                            ? ProductStaggered(
                                snapshot.data, constraint.maxWidth)
                            : widget.config['layout'] == 'listTile'
                                ? ProductListTitle(snapshot.data)
                                : getProductListWidgets(context, snapshot.data,
                                    constraint.maxWidth),
                      ],
                    );
                  }
              }
            },
          ),
        );
      },
    );
  }

  int _getCountDownDuration(List<Product> data,
      [bool isSaleOffLayout = false]) {
    if ((widget.config['showCountDown'] ?? kSaleOffProduct['ShowCountDown']) &&
        isSaleOffLayout &&
        data.isNotEmpty) {
      return (DateTime.tryParse(data.first?.dateOnSaleTo ?? '')
                  ?.millisecondsSinceEpoch ??
              0) -
          (DateTime.now().millisecondsSinceEpoch ?? 0);
    }
    return 0;
  }
}
