import 'dart:collection';
import 'dart:ui';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rubber/rubber.dart';

import '../../../../common/tools.dart';
import '../../../../models/app_model.dart';
import '../../../../models/entities/index.dart';
import '../../../../models/user_model.dart';
import '../product_title_short.dart';

class ListingFullSizeLayout extends StatefulWidget {
  final Product product;

  ListingFullSizeLayout({this.product});

  @override
  _FullSizeLayoutState createState() => _FullSizeLayoutState();
}

class _FullSizeLayoutState extends State<ListingFullSizeLayout>
    with SingleTickerProviderStateMixin {
  Map<String, String> mapAttribute = HashMap();
  RubberAnimationController _controller;
  final _dampingValue = DampingRatio.MEDIUM_BOUNCY;
  final _stiffnessValue = Stiffness.HIGH;
  var top = 0.0;

  @override
  void initState() {
    _controller = RubberAnimationController(
        vsync: this,
        lowerBoundValue: AnimationControllerValue(pixel: 140),
        upperBoundValue: AnimationControllerValue(percentage: 0.6),
        springDescription: SpringDescription.withDampingRatio(
            mass: 1, stiffness: _stiffnessValue, ratio: _dampingValue),
        duration: const Duration(milliseconds: 300));
    super.initState();
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
                dotColor: Colors.black45,
                indicatorBgPadding: 5.0,
                dotBgColor: Colors.transparent,
                borderRadius: true,
                dotPosition: DotPosition.bottomCenter,
                dotVerticalPadding: 20,
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
            right: 10,
            child: IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
                onPressed: () => {} // Detail.showMenu(context, widget.product),
                ),
          ),
        ],
      ),
    );
  }

  Widget _getUpperLayer() {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Consumer2<AppModel, UserModel>(
        builder: (context, valueApp, valueUser, child) {
      return Material(
        color: Colors.transparent,
        child: Container(
          width: width * 0.78,
          height: height * 0.55,
          margin: EdgeInsets.only(left: width * 0.2),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10.0)),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ProductTitleShort(
                          product: widget.product, user: valueUser.user),
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
    );
  }
}
