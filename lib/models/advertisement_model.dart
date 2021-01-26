import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';

import '../common/config.dart';
import '../common/constants.dart';

class Ads with ChangeNotifier {
  static InterstitialAd _interstitialAd;
  static BannerAd _bannerAd;
  static MobileAdTargetingInfo _targetingInfo;
  BannerAd myBanner;
  bool isFBNativeBannerAdShown = false;
  bool isFBNativeAdShown = false;
  bool isFBBannerShown = false;

  void adInit() {
    if (kAdConfig['enable'] == false) {
      return;
    }
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

      case kAdType.facebookInterstitial:
        {
          Ads.showFacebookInterstitialAd();
          break;
        }
    }
  }

  static void googleAdInit() {
    if (!kIsWeb) {
      FirebaseAdMob.instance.initialize(
        appId: isAndroid ? kAdConfig['androidAppId'] : kAdConfig['iosAppId'],
      );
      _targetingInfo = const MobileAdTargetingInfo(
        keywords: <String>['flutterio', 'beautiful apps'],
        contentUrl: 'https://flutter.io',
        childDirected:
            false, // or MobileAdGender.female, MobileAdGender.unknown
        testDevices: <
            String>[], // Android emulators are considered test devices
      );
    }
  }

  static BannerAd createBannerAd() {
    if (!kIsWeb) {
      return BannerAd(
        // Replace the testAdUnitId with an ad unit id from the AdMob dash.
        // https://developers.google.com/admob/android/test-ads
        // https://developers.google.com/admob/ios/test-ads
        adUnitId: isAndroid
            ? kAdConfig['androidUnitBanner']
            : kAdConfig['iosUnitBanner'],
        size: AdSize.smartBanner,
        listener: (MobileAdEvent event) {
          printLog('BannerAd event is $event');
        },
      );
    }
    return null;
  }

  static void showBanner() {
    _bannerAd ??= createBannerAd();
    _bannerAd.load().then((load) {
      _bannerAd.show(anchorType: AnchorType.bottom);
    });
  }

  static void hideBanner() {
    _bannerAd.dispose();
    _bannerAd = null;
  }

  static InterstitialAd createInterstitialAd() {
    if (!kIsWeb) {
      return InterstitialAd(
          adUnitId: isAndroid
              ? kAdConfig['androidUnitInterstitial']
              : kAdConfig['iosUnitInterstitial'],
          listener: (MobileAdEvent event) {
            printLog('InterstitialAd event is $event');
          });
    }
    return null;
  }

  static void showInterstitialAd() {
    _interstitialAd ??= createInterstitialAd();
    _interstitialAd.load();
    Future.delayed(
        Duration(seconds: kAdConfig['waitingTimeToDisplayInterstitial']),
        () async {
      if (await _interstitialAd.isLoaded()) {
        await _interstitialAd.show(
          anchorType: AnchorType.bottom,
          anchorOffset: 0.0,
          horizontalCenterOffset: 0.0,
        );
      }
    });
  }

  static void hideInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd.dispose();
      _interstitialAd = null;
    }
  }

  static void showRewardedVideoAd() {
    if (!kIsWeb) {
      RewardedVideoAd.instance.load(
          adUnitId: isAndroid
              ? kAdConfig['androidUnitReward']
              : kAdConfig['iosUnitReward'],
          targetingInfo: _targetingInfo);
      Future.delayed(Duration(seconds: kAdConfig['waitingTimeToDisplayReward']),
          () async {
        await RewardedVideoAd.instance.show();
      });
    }
  }

  /// Facebook-Ads is temporary disable due to the iOS build issue on this library
  static void facebookAdInit() {
    FacebookAudienceNetwork.init(
      testingId: kAdConfig['hasdedIdTestingDevice'],
    );
  }

  static void showFacebookInterstitialAd() {
    FacebookInterstitialAd.loadInterstitialAd(
      placementId: isAndroid
          ? kAdConfig['interstitialAndroidPlacementId']
          : kAdConfig['interstitialiOSPlacementId'],
      listener: (result, value) {
        if (result == InterstitialAdResult.LOADED) {
          FacebookInterstitialAd.showInterstitialAd(delay: 5000);
        }
      },
    );
  }

  Widget facebookBanner() {
//    return const SizedBox();
    if (kAdConfig['enable'] && kAdConfig['type'] == kAdType.facebookBanner) {
      return FacebookBannerAd(
        placementId: isAndroid
            ? kAdConfig['bannerAndroidPlacementId']
            : kAdConfig['banneriOSPlacementId'],
        bannerSize: BannerSize.STANDARD,
        listener: (result, value) {
          switch (result) {
            case BannerAdResult.ERROR:
              printLog('Error: $value');
              break;
            case BannerAdResult.LOADED:
              printLog('Loaded: $value');
              break;
            case BannerAdResult.CLICKED:
              printLog('Clicked: $value');
              break;
            case BannerAdResult.LOGGING_IMPRESSION:
              printLog('Logging Impression: $value');
              break;
          }
        },
      );
    } else {
      return Container();
    }
  }

  Widget facebookNative() {
    // Hide FB Ads due to library issues
//    return const SizedBox();
    return FacebookNativeAd(
        placementId: isAndroid
            ? kAdConfig['nativeAndroidPlacementId']
            : kAdConfig['nativeiOSPlacementId'],
        adType: NativeAdType.NATIVE_AD,
        width: double.infinity,
        height: 300,
        backgroundColor: Colors.blue,
        titleColor: Colors.white,
        descriptionColor: Colors.white,
        buttonColor: Colors.deepPurple,
        buttonTitleColor: Colors.white,
        buttonBorderColor: Colors.white,
        listener: (result, value) {
          printLog('Native Ad: $result --> $value');
        });
  }

  Widget facebookBannerNative() {
    // Hide FB Ads due to library issues
//    return const SizedBox();
    return FacebookNativeAd(
      placementId: kAdConfig['nativeBannerAndroidPlacementId'],
      adType: NativeAdType.NATIVE_BANNER_AD,
      bannerAdSize: NativeBannerAdSize.HEIGHT_100,
      width: double.infinity,
      backgroundColor: Colors.blue,
      titleColor: Colors.white,
      descriptionColor: Colors.white,
      buttonColor: Colors.deepPurple,
      buttonTitleColor: Colors.white,
      buttonBorderColor: Colors.white,
      listener: (result, value) {
        printLog('Native Ad: $result --> $value');
      },
    );
  }
}
