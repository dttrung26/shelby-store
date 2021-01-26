import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart' as html;
import 'package:webview_flutter/webview_flutter.dart';

import '../../common/config.dart';
import '../../common/tools.dart';
import '../../models/entities/blog.dart';
import '../../models/index.dart' show Blog, Ads;

class OneQuarterImageType extends StatefulWidget {
  final Blog item;

  OneQuarterImageType({Key key, @required this.item}) : super(key: key);

  @override
  _OneQuarterImageTypeState createState() => _OneQuarterImageTypeState();
}

class _OneQuarterImageTypeState extends State<OneQuarterImageType> {
  ScrollController _scrollController;
  bool isExpandedListView = true;
  bool isVideoDetected = false;
  bool isFBNativeBannerAdShown = false;
  bool isFBNativeAdShown = false;
  bool isFBBannerShown = false;
  String videoUrl;
  Key key = UniqueKey();

  @override
  void dispose() {
    if (kAdConfig['enable'] ?? false) {
      Ads.hideBanner();
      Ads.hideInterstitialAd();
    }
    super.dispose();
  }

  @override
  void initState() {
    if (Videos.getVideoLink(widget.item.content) != null) {
      setState(() {
        videoUrl = Videos.getVideoLink(widget.item.content);

        isVideoDetected = true;
      });
    } else {
      isVideoDetected = false;
    }

    if (kAdConfig['enable'] ?? false) {
      _initAds();
    }

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  void _scrollListener() {
    if (_scrollController.offset == 0) {
      setState(() {
        isExpandedListView = true;
      });
    } else {
      setState(() {
        isExpandedListView = false;
      });
    }
  }

  void _initAds() {
    Ads.googleAdInit();

    if (kAdConfig['type'] == kAdType.facebookBanner ||
        kAdConfig['type'] == kAdType.facebookNative ||
        kAdConfig['type'] == kAdType.facebookInterstitial ||
        kAdConfig['type'] == kAdType.facebookNativeBanner) Ads.facebookAdInit();

    switch (kAdConfig['type']) {
      case kAdType.googleBanner:
        {
          Ads.createBannerAd();
          Ads.showBanner();
          break;
        }
      case kAdType.googleInterstitial:
        {
          Ads.createInterstitialAd();
          Ads.showInterstitialAd();
          break;
        }
      case kAdType.googleReward:
        {
          Ads.showRewardedVideoAd();
          break;
        }
      case kAdType.facebookBanner:
        {
          setState(() {
            isFBBannerShown = true;
          });
          break;
        }
      case kAdType.facebookNative:
        {
          setState(() {
            isFBNativeAdShown = true;
          });
          break;
        }
      case kAdType.facebookNativeBanner:
        {
          setState(() {
            isFBNativeBannerAdShown = true;
          });
          break;
        }
      case kAdType.facebookInterstitial:
        {
          Ads.showFacebookInterstitialAd();
          break;
        }
    }
  }

  Widget _buildChildWidgetAd() {
    if (isFBBannerShown) {
      return Ads().facebookBanner();
    } else if (isFBNativeBannerAdShown) return Ads().facebookBannerNative();
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    child: ListView(
                      controller: _scrollController,
                      children: <Widget>[
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: Container(
                                height: MediaQuery.of(context).size.height / 3,
                                width: MediaQuery.of(context).size.width - 30,
                                child: Stack(
                                  children: <Widget>[
                                    Tools.image(
                                      url: widget.item.imageFeature,
                                      fit: BoxFit.cover,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              3,
                                      size: kSize.medium,
                                    ),
                                    isVideoDetected
                                        ? WebView(
                                            key: key,
                                            initialUrl: videoUrl,
                                            javascriptMode:
                                                JavascriptMode.unrestricted,
                                          )
                                        : Tools.image(
                                            url: widget.item.imageFeature,
                                            fit: BoxFit.cover,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                3,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            size: kSize.large,
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 15, left: 15, right: 15, bottom: 5),
                          child: Text(
                            widget.item.title,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: 25,
                              color: Theme.of(context)
                                  .accentColor
                                  .withOpacity(0.8),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        html.HtmlWidget(
                          widget.item.content,
                          webView: true,
                          hyperlinkColor:
                              Theme.of(context).primaryColor.withOpacity(0.9),
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(
                                  fontSize: 13.0,
                                  height: 1.4,
                                  color: Theme.of(context).accentColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 90,
              child: AnimatedOpacity(
                opacity: isExpandedListView ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 180,
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Tools.getCachedAvatar(
                                'https://api.hello-avatar.com/adorables/${widget.item.author}.png'),
                          ),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'by ${widget.item.author} ',
                                  softWrap: false,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .accentColor
                                        .withOpacity(0.45),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  widget.item.date,
                                  softWrap: true,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .accentColor
                                        .withOpacity(0.45),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 5,
              left: 5,
              child: GestureDetector(
                onTap: Navigator.of(context).pop,
                child: Container(
                  margin: const EdgeInsets.all(12.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 18.0,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
            ),
            if (kAdConfig['enable'] ?? false)
              Container(
                alignment: Alignment.bottomCenter,
                child: _buildChildWidgetAd(),
              ),
          ],
        ),
      ),
    );
  }
}
