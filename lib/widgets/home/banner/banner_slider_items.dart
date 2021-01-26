import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:page_indicator/page_indicator.dart';

import '../../../common/tools.dart';
import '../../../widgets/home/banner/banner_items.dart';
import '../../../widgets/home/header/header_text.dart';

/// The Banner Group type to display the image as multi columns
class BannerSliderItems extends StatefulWidget {
  final config;

  BannerSliderItems({this.config, Key key}) : super(key: key);

  @override
  _StateBannerSlider createState() => _StateBannerSlider();
}

class _StateBannerSlider extends State<BannerSliderItems> {
  int position = 0;

  PageController _controller;
  bool autoPlay;
  Timer timer;
  int intervalTime;
  @override
  void initState() {
    autoPlay = widget.config['autoPlay'] ?? false;
    _controller = PageController();
    intervalTime = widget.config['intervalTime'] ?? 3;
    autoPlayBanner();

    super.initState();
  }

  void autoPlayBanner() {
    List items = widget.config['items'];
    timer = Timer.periodic(Duration(seconds: intervalTime), (callback) {
      if (widget.config['design'] != 'default' || !autoPlay) {
        timer.cancel();
      } else if (widget.config['design'] == 'default' && autoPlay) {
        if (position >= items.length - 1 && _controller.hasClients) {
          _controller.jumpToPage(0);
        } else {
          if (position != null && _controller.hasClients) {
            _controller.animateToPage(position + 1,
                duration: const Duration(seconds: 1), curve: Curves.easeInOut);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    if (timer != null) {
      timer.cancel();
    }

    _controller.dispose();
    super.dispose();
  }

  Widget getBannerPageView(width) {
    List items = widget.config['items'];
    bool showNumber = widget.config['showNumber'] ?? false;

    return Padding(
      child: Stack(
        children: <Widget>[
          PageIndicatorContainer(
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  position = index;
                });
              },
              children: <Widget>[
                for (int i = 0; i < items.length; i++)
                  BannerImageItem(
                    config: items[i],
                    width: width,
                    boxFit: BoxFit.cover,
                    padding:
                        Tools.formatDouble(widget.config['padding'] ?? 0.0),
                    radius: Tools.formatDouble(widget.config['radius'] ?? 6.0),
                  ),
              ],
            ),
            align: IndicatorAlign.bottom,
            length: items.length,
            indicatorSpace: 5.0,
            padding: const EdgeInsets.all(10.0),
            indicatorColor: Colors.black12,
            indicatorSelectorColor: Colors.black87,
            shape: IndicatorShape.roundRectangleShape(
              size: showNumber ? const Size(0.0, 0.0) : const Size(25.0, 2.0),
            ),
          ),
          showNumber
              ? Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15, right: 0),
                    child: Container(
                      decoration:
                          BoxDecoration(color: Colors.black.withOpacity(0.6)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        child: Text(
                          '${position + 1}/${items.length}',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
              : Container()
        ],
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 5),
    );
  }

  Widget renderBanner(width) {
    List items = widget.config['items'];
    switch (widget.config['design']) {
      case 'swiper':
        return Swiper(
          onIndexChanged: (index) {
            setState(() {
              position = index;
            });
          },
          autoplay: autoPlay,
          itemBuilder: (BuildContext context, int index) {
            return BannerImageItem(
              config: items[index],
              width: width,
              boxFit: BoxFit.cover,
              radius: Tools.formatDouble(widget.config['radius'] ?? 6.0),
            );
          },
          itemCount: items.length,
          viewportFraction: 0.85,
          scale: 0.9,
          duration: intervalTime,
        );
      case 'tinder':
        return Swiper(
          onIndexChanged: (index) {
            setState(() {
              position = index;
            });
          },
          autoplay: autoPlay,
          itemBuilder: (BuildContext context, int index) {
            return BannerImageItem(
              config: items[index],
              width: width,
              boxFit: BoxFit.cover,
              radius: Tools.formatDouble(widget.config['radius'] ?? 6.0),
            );
          },
          itemCount: items.length,
          itemWidth: width,
          itemHeight: width * 1.2,
          layout: SwiperLayout.TINDER,
          duration: intervalTime,
        );
      case 'stack':
        return Swiper(
          onIndexChanged: (index) {
            setState(() {
              position = index;
            });
          },
          autoplay: autoPlay,
          itemBuilder: (BuildContext context, int index) {
            return BannerImageItem(
              config: items[index],
              width: width,
              boxFit: BoxFit.cover,
              radius: Tools.formatDouble(widget.config['radius'] ?? 6.0),
            );
          },
          itemCount: items.length,
          itemWidth: width - 40,
          layout: SwiperLayout.STACK,
          duration: intervalTime,
        );
      case 'custom':
        return Swiper(
          onIndexChanged: (index) {
            setState(() {
              position = index;
            });
          },
          autoplay: autoPlay,
          itemBuilder: (BuildContext context, int index) {
            return BannerImageItem(
              config: items[index],
              width: width,
              boxFit: BoxFit.cover,
              radius: Tools.formatDouble(widget.config['radius'] ?? 6.0),
            );
          },
          itemCount: items.length,
          itemWidth: width - 40,
          itemHeight: width + 100,
          duration: intervalTime,
          layout: SwiperLayout.CUSTOM,
          customLayoutOption: CustomLayoutOption(startIndex: -1, stateCount: 3)
              .addRotate([-45.0 / 180, 0.0, 45.0 / 180]).addTranslate(
            [
              const Offset(-370.0, -40.0),
              const Offset(0.0, 0.0),
              const Offset(370.0, -40.0)
            ],
          ),
        );
      default:
        return getBannerPageView(width);
    }
  }

  double bannerPercent(width) {
    final screenSize = MediaQuery.of(context).size;
    return Tools.formatDouble(
        widget.config['height'] ?? 0.5 / (screenSize.height / width));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    var isBlur = widget.config['isBlur'] == true;

    List items = widget.config['items'];
    var bannerExtraHeight =
        screenSize.height * (widget.config['title'] != null ? 0.12 : 0.0);
    var upHeight = Tools.formatDouble(widget.config['upHeight'] ?? 0.0);

    //Set autoplay for default template
    autoPlay = widget.config['autoPlay'] ?? false;
    if (widget.config['design'] == 'default' && timer != null) {
      if (!autoPlay) {
        if (timer.isActive) {
          timer.cancel();
        }
      } else {
        if (!timer.isActive) {
          Future.delayed(Duration(seconds: intervalTime), () => autoPlayBanner);
        }
      }
    }

    return LayoutBuilder(
      builder: (context, constraint) {
        var _bannerPercent = bannerPercent(constraint.maxWidth);
        return FractionallySizedBox(
          widthFactor: 1.0,
          child: Container(
            height: screenSize.height * _bannerPercent +
                bannerExtraHeight +
                upHeight,
            child: Stack(
              children: <Widget>[
                if (widget.config['showBackground'] == true)
                  Container(
                    height: screenSize.height * _bannerPercent +
                        bannerExtraHeight +
                        upHeight,
                    child: Padding(
                      child: ClipRRect(
                        child: Stack(children: <Widget>[
                          isBlur
                              ? Transform.scale(
                                  child: Image.network(
                                    items[position]['background'] ??
                                        items[position]['image'],
                                    fit: BoxFit.fill,
                                    width: screenSize.width + upHeight,
                                  ),
                                  scale: 3,
                                )
                              : Image.network(
                                  items[position]['background'] ??
                                      items[position]['image'],
                                  fit: BoxFit.fill,
                                  width: constraint.maxWidth,
                                  height: screenSize.height * _bannerPercent +
                                      bannerExtraHeight +
                                      upHeight,
                                ),
                          ClipRect(
                            child: BackdropFilter(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withOpacity(isBlur ? 0.6 : 0.0),
                                ),
                              ),
                              filter: ImageFilter.blur(
                                  sigmaX: isBlur ? 12 : 0,
                                  sigmaY: isBlur ? 12 : 0),
                            ),
                          ),
                        ]),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.elliptical(100, 6),
                        ),
                      ),
                      padding: const EdgeInsets.only(bottom: 50),
                    ),
                  ),
                if (widget.config['title'] != null)
                  HeaderText(
                    config: widget.config,
                  ),
                Container(
                  height: screenSize.height * _bannerPercent,
                  child: renderBanner(constraint.maxWidth),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
