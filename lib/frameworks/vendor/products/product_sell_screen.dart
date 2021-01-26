import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart' show Product, UserModel;
import '../../../services/index.dart';
import '../../../widgets/product/product_card_view.dart';

class ProductSellScreen extends StatefulWidget {
  @override
  _StateProductSell createState() => _StateProductSell();
}

class _StateProductSell extends State<ProductSellScreen> {
  final Services _services = Services();
  List<Product> _products = [];
  bool isLoading = true;
  bool loadMore = true;
  int page = 1;
  String errMsg;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final userModel = Provider.of<UserModel>(context, listen: false);
      _services.api
          .getOwnProducts(userModel.user.cookie, page: 1)
          .then((onValue) {
        setState(() {
          if (onValue.isNotEmpty) {
            _products = onValue;
          }
          isLoading = false;
        });
      }).catchError((e) {
        setState(() {
          errMsg = e.toString();
        });
      });
    });
  }

  Future createProduct() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    await Navigator.pushNamed(context, RouteList.createProduct);
    setState(() {
      isLoading = true;
    });

    final product =
        await _services.api.getOwnProducts(userModel.user.cookie, page: 1);
    setState(() {
      _products = product;
      isLoading = false;
    });
  }

  void _onRefresh() {
    final userModel = Provider.of<UserModel>(context, listen: false);
    _services.api
        .getOwnProducts(userModel.user.cookie, page: 1)
        .then((onValue) {
      setState(() {
        _products = onValue;
        loadMore = true;
        page = 1;
      });
      _refreshController.refreshCompleted();
    }).catchError((e) {
      setState(() {
        errMsg = e.toString();
      });
    });
  }

  void _onLoading() {
    final userModel = Provider.of<UserModel>(context, listen: false);
    _services.api
        .getOwnProducts(userModel.user.cookie, page: page + 1)
        .then((onValue) {
      setState(() {
        _products = [..._products, ...onValue];
        page = page + 1;
      });
      if (onValue.isEmpty) {
        setState(() {
          loadMore = false;
        });
      }
      _refreshController.loadComplete();
    }).catchError((e) {
      setState(() {
        errMsg = e.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).myProducts,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: Theme.of(context).accentIconTheme,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (errMsg != null) {
            return Center(
              child: Text(errMsg),
            );
          }
          return isLoading
              ? StaggeredGridView.countBuilder(
                  controller: ScrollController(),
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  itemCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  itemBuilder: (context, value) {
                    return ProductCard(
                      item: Product.empty('$value'),
                      width: constraints.maxWidth / 2,
                    );
                  },
                  staggeredTileBuilder: (index) => const StaggeredTile.fit(2),
                )
              : SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: loadMore,
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  child: _products.isNotEmpty
                      ? StaggeredGridView.countBuilder(
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          itemCount: _products.length,
                          itemBuilder: (context, value) {
                            return ProductCard(
                              item: _products[value],
                              width: constraints.maxWidth / 2,
                            );
                          },
                          staggeredTileBuilder: (index) =>
                              const StaggeredTile.fit(2),
                        )
                      : Center(
                          child: Text(S.of(context).myProductsEmpty),
                        ),
                );
        },
      ),
      floatingActionButton: GestureDetector(
        onTap: createProduct,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              const BoxShadow(color: Colors.blueGrey, blurRadius: 10)
            ],
          ),
          child: const Icon(
            Icons.add,
            size: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
