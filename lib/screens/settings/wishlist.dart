import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show AppModel, CartModel, Product, WishListModel;
import '../../services/service_config.dart';
import '../../tabbar.dart';
import '../../widgets/product/product_bottom_sheet.dart';
import '../custom/smartchat.dart';

class WishListScreen extends StatefulWidget {
  final bool canPop;
  final bool showChat;

  WishListScreen({this.canPop = true, this.showChat});

  @override
  State<StatefulWidget> createState() {
    return WishListState();
  }
}

class WishListState extends State<WishListScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _hideController;

  @override
  void initState() {
    super.initState();
    _hideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: 1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    var showChat = widget.showChat ?? false;

    return Stack(children: [
      Scaffold(
        floatingActionButton: showChat
            ? SmartChat(
                margin: EdgeInsets.only(
                  right:
                      Provider.of<AppModel>(context, listen: false).langCode ==
                              'ar'
                          ? 30.0
                          : 0.0,
                ),
              )
            : Container(),
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
            brightness: Theme.of(context).brightness,
            elevation: 0.5,
            leading: widget.canPop
                ? IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      size: 22,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                : Container(),
            title: Text(
              S.of(context).myWishList,
              style: TextStyle(color: Theme.of(context).accentColor),
            ),
            backgroundColor: Theme.of(context).backgroundColor),
        body: ListenableProvider.value(
            value: Provider.of<WishListModel>(context, listen: false),
            child: Consumer<WishListModel>(builder: (context, model, child) {
              if (model.products.isEmpty) {
                return EmptyWishlist(
                  canPop: widget.canPop,
                  onShowHome: () {
                    MainTabControlDelegate.getInstance().changeTab('home');
                    if (widget.canPop) {
                      Navigator.of(context).pop();
                    }
                  },
                );
              } else {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        child: Text(
                            '${model.products.length} ' + S.of(context).items,
                            style:
                                const TextStyle(fontSize: 14, color: kGrey400)),
                      ),
                      const Divider(height: 1, color: kGrey200),
                      const SizedBox(height: 15),
                      Expanded(
                        child: ListView.builder(
                            itemCount: model.products.length,
                            itemBuilder: (context, index) {
                              return WishlistItem(
                                  product: model.products[index],
                                  onRemove: () {
                                    Provider.of<WishListModel>(context,
                                            listen: false)
                                        .removeToWishlist(
                                            model.products[index]);
                                  },
                                  onAddToCart: () {
                                    if (model.products[index].isPurchased &&
                                        model.products[index].isDownloadable) {
                                      Share.share(
                                          model.products[index].files[0]);
                                      return;
                                    }
                                    Provider.of<CartModel>(context,
                                            listen: false)
                                        .addProductToCart(
                                            product: model.products[index],
                                            quantity: 1);
                                  });
                            }),
                      )
                    ]);
              }
            })),
      ),
      if (kAdvanceConfig['EnableShoppingCart'])
        Align(
            child: ExpandingBottomSheet(hideController: _hideController),
            alignment: Alignment.bottomRight)
    ]);
  }
}

class EmptyWishlist extends StatelessWidget {
  final Function onShowHome;
  final bool canPop;

  EmptyWishlist({this.onShowHome, this.canPop = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 80),
          Image.asset(
            'assets/images/empty_wishlist.png',
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 20),
          Text(S.of(context).noFavoritesYet,
              style: const TextStyle(fontSize: 18, color: Colors.black),
              textAlign: TextAlign.center),
          const SizedBox(height: 15),
          Text(S.of(context).emptyWishlistSubtitle,
              style: const TextStyle(fontSize: 14, color: kGrey900),
              textAlign: TextAlign.center),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: ButtonTheme(
                  height: 45,
                  child: RaisedButton(
                      child: Text(S.of(context).startShopping.toUpperCase()),
                      color: Colors.black,
                      textColor: Colors.white,
                      onPressed: onShowHome),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ButtonTheme(
                  height: 44,
                  child: RaisedButton(
                    child: Text(S.of(context).searchForItems.toUpperCase()),
                    color: kGrey200,
                    textColor: kGrey400,
                    onPressed: () {
                      if (canPop) {
                        Navigator.of(context).popAndPushNamed('/search');
                      } else {
                        MainTabControlDelegate.getInstance()
                            .changeTab('search');
                      }
                    },
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class WishlistItem extends StatelessWidget {
  WishlistItem({@required this.product, this.onAddToCart, this.onRemove});

  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final localTheme = Theme.of(context);
    final currency = Provider.of<CartModel>(context).currency;
    final currencyRate = Provider.of<AppModel>(context).currencyRate;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                RouteList.productDetail,
                arguments: product,
              );
            },
            child: Row(
              key: ValueKey(product.id),
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: onRemove,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: constraints.maxWidth * 0.25,
                              height: constraints.maxWidth * 0.3,
                              child: Tools.image(
                                  url: product.imageFeature,
                                  size: kSize.medium),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name ?? '',
                                    style: localTheme.textTheme.caption,
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                      Tools.getPriceProduct(
                                          product, currencyRate, currency),
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .copyWith(
                                              color: kGrey400, fontSize: 14)),
                                  const SizedBox(height: 10),
                                  if (!Config().isListingType)
                                    RaisedButton(
                                        textColor: Colors.white,
                                        color: localTheme.primaryColor,
                                        child: (product.isPurchased &&
                                                product.isDownloadable)
                                            ? Text(S
                                                .of(context)
                                                .download
                                                .toUpperCase())
                                            : Text(S
                                                .of(context)
                                                .addToCart
                                                .toUpperCase()),
                                        onPressed: onAddToCart)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          const Divider(color: kGrey200, height: 1),
          const SizedBox(height: 10.0),
        ]);
      },
    );
  }
}
