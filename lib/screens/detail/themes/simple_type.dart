import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../models/index.dart'
    show Ads, AppModel, Product, ProductModel, UserModel;
import '../../../modules/booking/booking.dart';
import '../../../screens/detail/product_grouped.dart';
import '../../../services/index.dart';
import '../../../widgets/common/image_galery.dart';
import '../../../widgets/product/heart_button.dart';
import '../../../widgets/product/product_bottom_sheet.dart';
import '../../chat/chat_screen.dart';
import '../../custom/smartchat.dart';
import '../image_feature.dart';
import '../index.dart';
import '../listing_booking.dart';
import '../product_description.dart';
import '../product_detail_categories.dart';
import '../product_gallery.dart';
import '../product_tag.dart';
import '../product_title.dart';
import '../product_variant.dart';
import '../related_product.dart';
import '../variant_image_feature.dart';
import '../video_feature.dart';

class SimpleLayout extends StatefulWidget {
  final Product product;

  SimpleLayout({this.product});

  @override
  _SimpleLayoutState createState() => _SimpleLayoutState(product: product);
}

class _SimpleLayoutState extends State<SimpleLayout>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  Product product;

  String selectedUrl;
  bool isVideoSelected = false;

  _SimpleLayoutState({this.product});

  Map<String, String> mapAttribute = HashMap();
  AnimationController _hideController;

  var top = 0.0;

  @override
  void initState() {
    super.initState();

    if (kAdConfig['enable']) Ads().adInit();

    _hideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    if (kAdConfig['enable']) {
      Ads.hideBanner();
      Ads.hideInterstitialAd();
    }
    super.dispose();
  }

  /// Render product default: booking, group, variant, simple, booking
  Widget renderProductInfo() {
    var body;

    switch (product.type) {
      case 'appointment':
        return ProductBooking(
            key: ValueKey('keyProductBooking${product.id}'), product: product);
      case 'booking':
        body = ListingBooking(product);
        break;
      case 'grouped':
        body = GroupedProduct(product);
        break;
      default:
        body = ProductVariant(
          product,
          onSelectVariantImage: (String url) {
            setState(() {
              selectedUrl = url;
              isVideoSelected = false;
            });
          },
        );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: body,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final widthHeight = size.height;
    //special advertisement type
    var isGoogleBannerShown =
        kAdConfig['enable'] && kAdConfig['type'] == kAdType.googleBanner;
    var isFBNativeAdShown =
        kAdConfig['enable'] && kAdConfig['type'] == kAdType.facebookNative;

    final userModel = Provider.of<UserModel>(context, listen: false);

    return Container(
      color: Theme.of(context).backgroundColor,
      child: SafeArea(
        bottom: false,
        top: kProductDetail['safeArea'] ?? false,
        child: ChangeNotifierProvider(
          create: (_) => ProductModel(),
          child: Stack(
            children: <Widget>[
              Scaffold(
                floatingActionButton: Config().isVendorType()
                    ? Padding(
                        padding: EdgeInsets.only(
                          bottom: kAdConfig['enable'] ? 130 : 45,
                        ),
                        child: FloatingActionButton(
                          heroTag: null,
                          backgroundColor: Theme.of(context).primaryColor,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  senderUser: userModel.user,
                                  receiverEmail: widget.product.store.email,
                                  receiverName: widget.product.store.name,
                                ),
                              ),
                            ); //
                          },
                          child: const Icon(
                            Icons.chat,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                      )

                    /// Disable SmartChat for MV.
                    : kConfigChat['EnableSmartChat']
                        ? SmartChat(
                            margin: EdgeInsets.only(
                              bottom: kAdConfig['enable'] ? 130 : 45,
                              right:
                                  Provider.of<AppModel>(context, listen: false)
                                              .langCode ==
                                          'ar'
                                      ? 30
                                      : 0.0,
                            ),
                          )
                        : const SizedBox(),
                backgroundColor: Theme.of(context).backgroundColor,
                body: CustomScrollView(
                  controller: _scrollController,
                  slivers: <Widget>[
                    SliverAppBar(
                      brightness: Theme.of(context).brightness,
                      backgroundColor: Theme.of(context).backgroundColor,
                      elevation: 1.0,
                      expandedHeight:
                          kIsWeb ? 0 : widthHeight * kProductDetail['height'],
                      pinned: true,
                      floating: false,
                      leading: Padding(
                        padding: const EdgeInsets.all(8),
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: kGrey400,
                            ),
                            onPressed: () {
                              Provider.of<ProductModel>(context, listen: false)
                                  .changeProductVariation(null);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                      actions: <Widget>[
                        HeartButton(
                          product: product,
                          size: 18.0,
                          color: kGrey400,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.3),
                            child: IconButton(
                              icon: const Icon(Icons.more_vert, size: 19),
                              color: kGrey400,
                              onPressed: () => ProductDetailScreen.showMenu(
                                  context, widget.product),
                            ),
                          ),
                        ),
                      ],
                      flexibleSpace: kIsWeb
                          ? Container()
                          : _renderSelectedMedia(context, product, size),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        <Widget>[
                          const SizedBox(
                            height: 2,
                          ),
                          ProductGallery(
                            product: product,
                            onSelect: (String url, bool isVideo) {
                              if (mounted) {
                                setState(() {
                                  selectedUrl = url;
                                  isVideoSelected = isVideo;
                                });
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              bottom: 4.0,
                              left: 15,
                              right: 15,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                product.type == 'grouped'
                                    ? Container()
                                    : ProductTitle(product),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    renderProductInfo(),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          // horizontal: 15.0,
                          vertical: 8.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                              child: Column(
                                children: [
                                  Services().widget.renderVendorInfo(product),
                                  ProductDescription(product),
                                  if (kProductDetail['showProductCategories'] ??
                                      true)
                                    ProductDetailCategories(product),
                                  if (kProductDetail['showProductTags'] ?? true)
                                    ProductTag(product),
                                ],
                              ),
                            ),
                            RelatedProduct(product),
                            isFBNativeAdShown
                                ? Ads().facebookNative()
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: isGoogleBannerShown
                    ? Positioned(
                        child: ExpandingBottomSheet(
                            hideController: _hideController,
                            onInitController: (controller) {}),
                        bottom: 80,
                        right: 0,
                      )
                    : Align(
                        child: ExpandingBottomSheet(
                            hideController: _hideController,
                            onInitController: (controller) {}),
                        alignment: Alignment.bottomRight),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderSelectedMedia(
      BuildContext context, Product product, Size size) {
    /// Render selected video
    if (selectedUrl != null && isVideoSelected) {
      return FeatureVideoPlayer(
        url: selectedUrl.replaceAll('http://', 'https://'),
        autoPlay: true,
      );
    }

    /// Render selected image
    if (selectedUrl != null && !isVideoSelected) {
      return GestureDetector(
        onTap: () {
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              final images = [...product.images];
              final index = product.images.indexOf(selectedUrl);
              if (index == -1) {
                images.insert(0, selectedUrl);
              }
              return ImageGalery(
                images: images,
                index: index == -1 ? 0 : index,
              );
            },
          );
        },
        child: Tools.image(
          url: selectedUrl,
          fit: BoxFit.contain,
          width: size.width,
          size: kSize.large,
          hidePlaceHolder: true,
        ),
      );
    }

    /// Render default feature image
    return product.type == 'variable'
        ? VariantImageFeature(product)
        : ImageFeature(product);
  }
}
