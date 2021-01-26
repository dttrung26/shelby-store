import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';
import 'package:share/share.dart';

import '../../../../common/config.dart';
import '../../../../common/constants.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/index.dart';
import '../../../../screens/index.dart';
import '../../../../services/index.dart';
import '../../../../widgets/common/expansion_info.dart';
import '../../../../widgets/product/heart_button.dart';
import '../airbnb_slider.dart';
import '../product_description.dart';
import '../product_map.dart';
import '../product_menu.dart';
import '../product_related.dart';
import '../product_taxonomies.dart';
import '../product_title.dart';
import '../review.dart';

class ListingSimpleLayout extends StatefulWidget {
  final Product product;

  ListingSimpleLayout({this.product});

  @override
  _ListingSimpleLayoutState createState() => _ListingSimpleLayoutState();
}

class _ListingSimpleLayoutState extends State<ListingSimpleLayout>
    with SingleTickerProviderStateMixin {
  final services = Services();
  final _scrollController = ScrollController();

  GoogleMapController pageController;

  int quantity = 1;
  String size = '';
  String color = '';

  var top = 0.0;

  @override
  void initState() {
    if (kAdConfig['enable']) Ads().adInit();
    super.initState();
  }

  @override
  void dispose() {
    if (kAdConfig['enable']) {
      Ads.hideBanner();
      Ads.hideInterstitialAd();
    }
    super.dispose();
  }

//  _onShowGallery(context, [index = 0]) {
//    showDialog<void>(
//        context: context,
//        builder: (BuildContext context) {
//          return ImageGalery(images: product.images, index: index);
//        });
//  }

  void showOptions(context) {
    var wishlist = Provider.of<WishListModel>(context, listen: false).products;
    final isExist = wishlist.firstWhere((item) => item.id == widget.product.id,
        orElse: () => null);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                  title: Text(
                      isExist == null
                          ? S.of(context).saveToWishList
                          : S.of(context).removeFromWishList,
                      textAlign: TextAlign.center),
                  onTap: () {
                    if (isExist == null) {
                      Provider.of<WishListModel>(context, listen: false)
                          .addToWishlist(widget.product);
                    } else {
                      Provider.of<WishListModel>(context, listen: false)
                          .removeToWishlist(widget.product);
                    }

                    Navigator.of(context).pop();
                  }),
              ListTile(
                  title: Text(S.of(context).share, textAlign: TextAlign.center),
                  onTap: () {
                    Navigator.of(context).pop();
                    Share.share(widget.product.permalink);
                  }),
              Container(
                height: 1,
                decoration: const BoxDecoration(color: kGrey200),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                },
                title: Text(
                  S.of(context).cancel,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        });
  }

  List<Widget> getReviews() {
    return [
      ExpansionInfo(
        expand: true,
        title: S.of(context).readReviews,
        children: <Widget>[
          Reviews(int.parse(widget.product.id)),
        ],
      ),
    ];
  }

  List<Widget> getListingContent(context, user) {
    return [
      ProductTitle(product: widget.product, user: user),
      const SizedBox(height: 10),
      if (isNotBlank(widget.product.description))
        ProductDescription(
          product: widget.product,
        ),
      if (widget.product != null)
        if (widget.product.listingMenu != null)
          if (widget.product.listingMenu.isNotEmpty)
            ProductMenu(
              product: widget.product,
            ),
      ProductTaxonomies(
        product: widget.product,
        title: S.of(context).features,
        type: DataMapping().kTaxonomies['features'],
      ),
      ProductMap(
        product: widget.product,
      ),
      ...getReviews(),
      ProductRelated(
        product: widget.product,
      ),
      SizedBox(
        height: kAdConfig['enable'] ? 100 : 50,
      ),
    ];
  }

  List<Widget> getGoogleSheet(context) {
    return [
      ProductTitle(
        product: widget.product,
      ),
      ProductDescription(
        product: widget.product,
      ),
      ProductMap(
        product: widget.product,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> getThemeContent(value) {
      switch (Config().typeName) {
        case 'google-sheet':
          return getGoogleSheet(context);
          break;
        default:
          return getListingContent(context, value.user);
          break;
      }
    }

    return Consumer2<AppModel, UserModel>(
        builder: (context, valueApp, valueUser, child) {
      return Container(
        color: Theme.of(context).backgroundColor,
        child: SafeArea(
          top: false,
          child: Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            floatingActionButton: SmartChat(
              margin: EdgeInsets.only(
                bottom: kAdConfig['enable'] ? 50 : 30,
              ),
            ),
            body: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                    backgroundColor: Colors.black87,
                    elevation: 1.0,
                    expandedHeight: MediaQuery.of(context).size.height * 0.6,
                    pinned: true,
                    floating: false,
                    leading: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    actions: <Widget>[
                      HeartButton(
                        product: widget.product,
                        size: 20.0,
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        color: Colors.white,
                        onPressed: () => showOptions(context),
                      ),
                    ],
                    flexibleSpace: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return FlexibleSpaceBar(
                          background: AirbnbSlider(
                            images: widget.product.images,
                            height: MediaQuery.of(context).size.height * 0.6,
                          ),
                        );
                      },
                    )),
                SliverList(
                  delegate: SliverChildListDelegate(
                    <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: getThemeContent(valueUser),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
