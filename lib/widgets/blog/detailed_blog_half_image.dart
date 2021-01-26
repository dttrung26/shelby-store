import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../common/config.dart';
import '../../common/tools.dart';
import '../../models/entities/blog.dart';
import '../../models/index.dart' show Ads;

class HalfImageType extends StatefulWidget {
  final Blog item;

  HalfImageType({Key key, @required this.item}) : super(key: key);

  @override
  _HalfImageTypeState createState() => _HalfImageTypeState();
}

class _HalfImageTypeState extends State<HalfImageType> {
  bool isFBNativeBannerAdShown = false;
  bool isFBNativeAdShown = false;
  bool isFBBannerShown = false;

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
    if (kAdConfig['enable'] ?? false) {
      _initAds();
    }
    super.initState();
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
      body: Stack(
        children: <Widget>[
          Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              child: Tools.image(
                url: widget.item.imageFeature,
                fit: BoxFit.fitHeight,
                size: kSize.medium,
              )),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: GestureDetector(
                onTap: Navigator.of(context).pop,
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.black12,
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
            body: Column(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.5,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(35.0),
                            topRight: Radius.circular(35.0),
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                bottom: 15.0,
                                top: 30.0,
                              ),
                              child: Text(
                                widget.item.title,
                                softWrap: true,
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Theme.of(context).accentColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 15, left: 15),
                                  child: Tools.getCachedAvatar(
                                      'https://api.hello-avatar.com/adorables/40/${widget.item.author}.png'),
                                ),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'by ${widget.item.author} ',
                                        softWrap: false,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).accentColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.item.date,
                                        softWrap: true,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).accentColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: HtmlWidget(
                                widget.item.content,
                                hyperlinkColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.9),
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(
                                      fontSize: 14.0,
                                      height: 1.4,
                                      color: Theme.of(context).accentColor,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (kAdConfig['enable'] ?? false)
            Container(
              alignment: Alignment.bottomCenter,
              child: _buildChildWidgetAd(),
            ),
        ],
      ),
    );
  }

  void _initAds() {
    Ads.googleAdInit();
    Ads.facebookAdInit();

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
}
