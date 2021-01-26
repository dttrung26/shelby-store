import 'dart:async';

import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/config.dart';
import 'common/constants.dart';
import 'common/packages.dart' show ScreenUtil;
import 'models/index.dart'
    show
        AppModel,
        BlogModel,
        CartModel,
        CategoryModel,
        FilterAttributeModel,
        FilterTagModel,
        TagModel,
        UserModel;
import 'models/listing/listing_location_model.dart';
import 'screens/base.dart';
import 'screens/index.dart' show LoginScreen, OnBoardScreen;
import 'services/index.dart';
import 'widgets/common/animated_splash.dart';
import 'widgets/common/custom_splash.dart';
import 'widgets/common/flare_splash_screen.dart';
import 'widgets/common/rive_splashscreen.dart';
import 'widgets/common/static_splashscreen.dart';

class AppInit extends StatefulWidget {
  final Function onNext;

  AppInit({this.onNext});

  @override
  _AppInitState createState() => _AppInitState();
}

class _AppInitState extends BaseScreen<AppInit> {
  final StreamController<bool> _streamInit = StreamController<bool>();

  bool isFirstSeen = false;
  bool isLoggedIn = false;
  bool isLoading = true;
  bool isWaitingToNext = false;

  Map appConfig;

  /// check if the screen is already seen At the first time
  Future<bool> checkFirstSeen() async {
    /// Ignore if OnBoardOnlyShowFirstTime is set to true.
    if (kAdvanceConfig['OnBoardOnlyShowFirstTime'] == false) {
      return false;
    }

    var prefs = await SharedPreferences.getInstance();
    var _seen = prefs.getBool('seen') ?? false;
    return _seen;
  }

  /// Check if the App is Login
  Future checkLogin() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getBool('loggedIn') ?? false;
  }

  Future loadInitData() async {
    try {
      printLog('[AppState] Inital Data');

      isFirstSeen = await checkFirstSeen();
      isLoggedIn = await checkLogin();

      /// Load App model config
      Services().setAppConfig(serverConfig);
      appConfig =
          await Provider.of<AppModel>(context, listen: false).loadAppConfig();

      Future.delayed(Duration.zero, () {
        /// Load more Category/Blog/Attribute Model beforehand
        if (mounted) {
          final lang = Provider.of<AppModel>(context, listen: false).langCode;

          Provider.of<CategoryModel>(context, listen: false).getCategories(
            lang: lang,
            sortingList:
                Provider.of<AppModel>(context, listen: false).categories,
            categoryLayout:
                Provider.of<AppModel>(context, listen: false).categoryLayout,
          );

          if ([
            ConfigType.listpro,
            ConfigType.listeo,
          ].contains(Config().type)) {
            Provider.of<ListingLocationModel>(context, listen: false)
                .getLocations();
          }

          Provider.of<AppModel>(context, listen: false).loadCurrency();

          Provider.of<TagModel>(context, listen: false).getTags();

          Provider.of<BlogModel>(context, listen: false).getBlogs();

          Provider.of<FilterTagModel>(context, listen: false).getFilterTags();

          Provider.of<FilterAttributeModel>(context, listen: false)
              .getFilterAttributes();

          Provider.of<CartModel>(context, listen: false).changeCurrencyRates(
              Provider.of<AppModel>(context, listen: false).currencyRate);

          //save logged in user
          Provider.of<CartModel>(context, listen: false)
              .setUser(Provider.of<UserModel>(context, listen: false).user);
          if (Provider.of<UserModel>(context, listen: false).user != null) {
            /// Preload address.
            Provider.of<CartModel>(context, listen: false).getAddress();
          }

          setState(() {
            isLoading = false;
          });
          if (isWaitingToNext) {
            goToNextScreen();
          }
        }
      });

      /// Firebase Dynamic Link Init
      if (firebaseDynamicLinkConfig['isEnabled'] && isMobile) {
        printLog('[dynamic_link] Firebase Dynamic Link Init');
        var dynamicLinkService = DynamicLinkService();
        dynamicLinkService.generateFirebaseDynamicLink();
      }

      /// Facebook Ads init
      if (kAdConfig['enable']) {
        debugPrint('[AppState] Init Facebook Audience Network');
        await FacebookAudienceNetwork.init();
      }

      printLog('[AppState] Init Data Finish');
    } catch (e, trace) {
      printLog(e.toString());
      printLog(trace.toString());
      setState(() {
        isLoading = false;
      });
      if (isWaitingToNext) {
        goToNextScreen();
      }
    }
  }

  Widget onNextScreen(bool isFirstSeen) {
    if (!isFirstSeen && !kIsWeb && appConfig != null) {
      if (onBoardingData.isNotEmpty) return OnBoardScreen(appConfig);
    }

    if (kLoginSetting['IsRequiredLogin'] && !isLoggedIn) {
      return LoginScreen(
        onLoginSuccess: (context) async {
          await Navigator.pushNamed(context, RouteList.dashboard);
        },
      );
    }
    return widget.onNext();
  }

  void goToNextScreen() {
    Navigator.of(context).pushReplacement(CupertinoPageRoute(
        builder: (BuildContext context) => onNextScreen(isFirstSeen)));
  }

  void checkToShowNextScreen() {
    if (isLoading) {
      isWaitingToNext = true;
    } else {
      goToNextScreen();
    }
  }

  @override
  void dispose() {
    _streamInit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var splashScreenType = kSplashScreenType;
    dynamic splashScreenData = kSplashScreen;

    /// showing this blank page will impact to the UX
    // if (appConfig == null) {
    //   return Center(child: Container(color: Theme.of(context).backgroundColor));
    // }

    if (appConfig != null && appConfig['SplashScreen'] != null) {
      splashScreenType = appConfig['SplashScreen']['type'];
      splashScreenData = appConfig['SplashScreen']['data'];
    }

    if (splashScreenType == 'rive') {
      const animationName = kAnimationName;
      return RiveSplashScreen(
        onSuccess: checkToShowNextScreen,
        asset: splashScreenData,
        animationName: animationName,
      );
    }

    if (splashScreenType == 'flare') {
      return SplashScreen.navigate(
        name: splashScreenData,
        startAnimation: 'fluxstore',
        backgroundColor: Colors.white,
        next: checkToShowNextScreen,
        until: () => Future.delayed(const Duration(seconds: 2)),
      );
    }

    if (splashScreenType == 'animated') {
      debugPrint('[FLARESCREEN] Animated');
      return AnimatedSplash(
        imagePath: splashScreenData,
        next: checkToShowNextScreen,
        duration: 2500,
        type: AnimatedSplashType.StaticDuration,
        isPushNext: true,
      );
    }
    if (splashScreenType == 'zoomIn') {
      return CustomSplash(
        imagePath: splashScreenData,
        backGroundColor: Colors.white,
        animationEffect: 'zoom-in',
        logoSize: 50,
        next: checkToShowNextScreen,
        duration: 2500,
      );
    }
    if (splashScreenType == 'static') {
      return StaticSplashScreen(
        imagePath: splashScreenData,
        onNextScreen: checkToShowNextScreen,
      );
    }
    return const SizedBox();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    ScreenUtil.init(context);
    loadInitData();
  }
}
