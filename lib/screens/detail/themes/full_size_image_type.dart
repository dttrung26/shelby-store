import 'dart:collection';
import 'dart:ui';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rubber/rubber.dart';

import '../../../common/tools.dart';
import '../../../models/index.dart' show Product, ProductModel;
import '../index.dart';
import '../product_title.dart';
import '../product_variant.dart';

class FullSizeLayout extends StatefulWidget {
  final Product product;

  FullSizeLayout({this.product});

  @override
  _FullSizeLayoutState createState() => _FullSizeLayoutState();
}

class _FullSizeLayoutState extends State<FullSizeLayout>
    with SingleTickerProviderStateMixin {
  Map<String, String> mapAttribute = HashMap();
  RubberAnimationController _controller;
  final double _dampingValue = DampingRatio.MEDIUM_BOUNCY;
  final double _stiffnessValue = Stiffness.HIGH;
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

  Widget _getLowerLayer({width, height}) {
    final _height = height ?? MediaQuery.of(context).size.height;
    final _width = width ?? MediaQuery.of(context).size.width;
    return Material(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            child: SizedBox(
              width: _width,
              height: _height,
              child: Tools.image(
                url: widget.product.imageFeature,
                fit: BoxFit.fitHeight,
                size: kSize.medium,
              ),
            ),
          ),
          //slider
          Positioned(
            top: 0,
            child: SizedBox(
              width: _width,
              height: _height,
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
                  Provider.of<ProductModel>(context, listen: false)
                      .changeProductVariation(null);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () =>
                  ProductDetailScreen.showMenu(context, widget.product),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getUpperLayer({width, height}) {
    final _height = height ?? MediaQuery.of(context).size.height;
    final _width = width ?? MediaQuery.of(context).size.width;
    return Material(
      color: Colors.transparent,
      child: Container(
        width: _width * 0.78,
        height: _height * 0.55,
        margin: EdgeInsets.only(left: _width * 0.2),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10.0)),
              child: ChangeNotifierProvider(
                create: (_) => ProductModel(),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ProductTitle(widget.product),
                      ProductVariant(widget.product),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RubberBottomSheet(
          lowerLayer: _getLowerLayer(
              width: constraints.maxWidth, height: constraints.maxHeight),
          upperLayer: _getUpperLayer(width: constraints.maxWidth),
          animationController: _controller,
        );
      },
    );
  }
}
