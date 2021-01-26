import 'dart:collection';
import 'dart:ui';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rubber/rubber.dart';

import '../../../../common/config.dart';
import '../../../../common/constants.dart';
import '../../../../common/tools.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/entities/index.dart';
import '../../../../models/index.dart';
import '../../../../widgets/common/expansion_info.dart';
import '../product_description.dart';
import '../product_map.dart';
import '../product_related.dart';
import '../product_taxonomies.dart';
import '../product_title_short.dart';
import '../review.dart';

class ListingHalfSizeLayout extends StatefulWidget {
  final Product product;

  ListingHalfSizeLayout({this.product});

  @override
  _HalfSizeLayoutState createState() => _HalfSizeLayoutState();
}

class _HalfSizeLayoutState extends State<ListingHalfSizeLayout>
    with SingleTickerProviderStateMixin {
  Map<String, String> mapAttribute = HashMap();
  RubberAnimationController _controller;
  final _scrollController = ScrollController();

  var top = 0.0;
  var opacityValue = 0.9;

  @override
  void initState() {
    _controller = RubberAnimationController(
        vsync: this,
        initialValue: 0.5,
        lowerBoundValue: AnimationControllerValue(percentage: 0.15),
        halfBoundValue: AnimationControllerValue(percentage: 0.5),
        upperBoundValue: AnimationControllerValue(percentage: 0.9),
        duration: const Duration(milliseconds: 200));
    _controller.animationState.addListener(_stateListener);
    super.initState();
  }

  void _stateListener() {
    printLog(_controller.animationState.value);
    setState(() {
      opacityValue =
          _controller.animationState.value == AnimationState.collapsed
              ? 0.3
              : 0.9;
    });
  }

  Widget _getLowerLayer() {
    final widthHeight = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Material(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            child: Opacity(
              opacity: 0.3,
              child: SizedBox(
                width: width,
                height: widthHeight,
                child: Tools.image(
                  url: widget.product.imageFeature,
                  fit: BoxFit.fitHeight,
                  size: kSize.medium,
                ),
              ),
            ),
          ),
          //slider
          Positioned(
            top: 0,
            child: SizedBox(
              width: width,
              height: widthHeight,
              child: Carousel(
                images: [
                  Image.network(
                    widget.product.imageFeature,
                    fit: BoxFit.fitHeight,
                  ),
                  for (var i = 1; i < widget.product.images.length; i++)
                    Image.network(
                      widget.product.images[i],
                      fit: BoxFit.fitHeight,
                    ),
                ],
                autoplay: false,
                dotSize: 5.0,
                dotSpacing: 15.0,
                dotColor: Theme.of(context).backgroundColor.withOpacity(0.7),
                dotIncreasedColor:
                    Theme.of(context).primaryColor.withOpacity(0.9),
                indicatorBgPadding: 5.0,
                dotBgColor: Colors.transparent,
                borderRadius: true,
                dotPosition: DotPosition.bottomCenter,
                dotVerticalPadding: MediaQuery.of(context).size.height * 0.16,
                boxFit: BoxFit.fitHeight,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.2),
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 18,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => {}, // Detail.showMenu(context, widget.product),
            ),
          ),
        ],
      ),
    );
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

  Widget _getUpperLayer() {
    final width = MediaQuery.of(context).size.width;

    return Consumer2<AppModel, UserModel>(
        builder: (context, valueApp, valueUser, child) {
      return Material(
        color: Colors.transparent,
        child: Container(
          width: width,
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, offset: Offset(0, -2), blurRadius: 20),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                    color: Theme.of(context)
                        .backgroundColor
                        .withOpacity(opacityValue),
                    borderRadius: BorderRadius.circular(10.0)),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ProductTitleShort(
                          product: widget.product, user: valueUser.user),
                      if (widget.product.description != '')
                        ProductDescription(
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
                      const SizedBox(
                        height: 50,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return RubberBottomSheet(
      lowerLayer: _getLowerLayer(),
      upperLayer: _getUpperLayer(),
      animationController: _controller,
      scrollController: _scrollController,
    );
  }
}
