import 'package:flutter/material.dart';

import '../../../common/tools.dart';
import '../../../models/index.dart' show Product;
import '../../../screens/base.dart';

/// The Banner type to display the image
class BannerImageItem extends StatefulWidget {
  @override
  final Key key;
  final dynamic config;
  final double width;
  final double padding;
  final BoxFit boxFit;
  final double radius;

  BannerImageItem({
    this.key,
    this.config,
    this.padding,
    this.width,
    this.boxFit,
    this.radius,
  }) : super(key: key);

  @override
  _BannerImageItemState createState() => _BannerImageItemState();
}

class _BannerImageItemState extends BaseScreen<BannerImageItem> {
  List<Product> _products;

  @override
  void afterFirstLayout(BuildContext context) {
    /// for pre-load the list product
    if (widget.config['data'] != null) {
      _products = widget.config['data'];
    }
  }

  @override
  Widget build(BuildContext context) {
    var _padding =
        Tools.formatDouble(widget.config['padding'] ?? widget.padding ?? 10.0);
    var _radius = Tools.formatDouble(widget.config['radius'] ??
        (widget.radius ?? 0.0));

    final screenSize = MediaQuery.of(context).size;
    final screenWidth =
        screenSize.width / (2 / (screenSize.height / screenSize.width));
    final itemWidth = widget.width ?? screenWidth;

    return GestureDetector(
      onTap: () => Utils.onTapNavigateOptions(
          context: context, config: widget.config, products: _products),
      child: Container(
        width: itemWidth,
        child: Padding(
          padding: EdgeInsets.only(left: _padding, right: _padding),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_radius),
            child: widget.config['image'].toString().contains('http')
                ? Tools.image(
                    fit: widget.boxFit ?? BoxFit.fitWidth,
                    url: widget.config['image'],
                  )
                : Image.asset(
                    widget.config['image'],
                    fit: widget.boxFit ?? BoxFit.fitWidth,
                  ),
          ),
        ),
      ),
    );
  }
}
