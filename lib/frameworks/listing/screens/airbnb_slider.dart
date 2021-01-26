import 'package:flutter/material.dart';
import 'package:page_indicator/page_indicator.dart';

import '../../../common/config.dart';
import 'airbnb_slider_item.dart';

class AirbnbSlider extends StatefulWidget {
  final List<String> images;
  final double height;

  AirbnbSlider({this.images, this.height});

  @override
  _StateAirbnbSlider createState() => _StateAirbnbSlider();
}

class _StateAirbnbSlider extends State<AirbnbSlider> {
  final _controller = PageController();
  int position = 0;

  @override
  Widget build(BuildContext context) {
    return widget.images.isNotEmpty
        ? PageIndicatorContainer(
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                if (mounted) {
                  setState(() {
                    position = index;
                  });
                }
              },
              children: <Widget>[
                for (int i = 0; i < widget.images.length; i++)
                  AirbnbSliderItem(
                    image: widget.images[i],
                    controller: _controller,
                    pos: i,
                    length: widget.images.length,
                    height: widget.height,
                    autoPlay: kProductDetail['autoPlayGallery'] ?? false,
                  ),
              ],
            ),
            align: IndicatorAlign.bottom,
            length: widget.images.length,
            indicatorSpace: 8.0,
            padding: const EdgeInsets.all(10.0),
            indicatorColor: Colors.white30,
            indicatorSelectorColor: Colors.white,
            shape: IndicatorShape.roundRectangleShape(
              size: Size(300 / widget.images.length, 2.0),
            ),
          )
        : Container();
  }
}
