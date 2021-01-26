import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../models/app_model.dart';
import '../../models/index.dart' show Product, ProductModel;
import '../../models/point_model.dart';
import '../../models/user_model.dart';
import '../../screens/base.dart';
import '../../screens/index.dart' show ProductDetailScreen;
import '../../services/index.dart';
import '../../widgets/firebase/one_signal_wapper.dart';
import '../../widgets/home/background.dart';
import '../../widgets/home/fake_status_bar.dart';
import '../../widgets/home/index.dart';
import 'deeplink_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen();

  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends BaseScreen<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  static BuildContext homeContext;

  static BuildContext loadingContext;

  @override
  bool get wantKeepAlive => true;

  Uri _latestUri;
  StreamSubscription _sub;
  int itemId;

  @override
  void dispose() {
    printLog('[Home] dispose');
    _sub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    printLog('[Home] initState');
    initPlatformState();
    super.initState();
  }

  Future<void> initPlatformState() async {
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      await initPlatformStateForStringUniLinks();
    }
  }

  Future<void> initPlatformStateForStringUniLinks() async {
    // Attach a listener to the links stream
    _sub = getLinksStream().listen((String link) {
      if (!mounted) return;
      setState(() {
        _latestUri = null;
        try {
          if (link != null) _latestUri = Uri.parse(link);
          setState(() {
            itemId = int.parse(_latestUri.path.split('/')[1]);
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDeepLink(
                itemId: itemId,
              ),
            ),
          );
        } on FormatException {
          printLog('[initPlatformStateForStringUniLinks] error');
        }
      });
    }, onError: (err) {
      if (!mounted) return;
      setState(() {
        _latestUri = null;
      });
    });

    getLinksStream().listen((String link) {
      printLog('got link: $link');
    }, onError: (err) {
      printLog('got err: $err');
    });
  }

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    printLog('[Home] afterFirstLayout');

    Future.delayed(
        const Duration(seconds: 1),
        () => Utils.changeStatusBarColor(
            Provider.of<AppModel>(context, listen: false).themeMode));

    homeContext = context;

    if (OneSignalWapper.hasNotificationData &&
        OneSignalWapper.productIdArray.isNotEmpty) {
      showLoading(context);
    }

    final userModel = Provider.of<UserModel>(context, listen: false);

    if (userModel.user != null &&
        userModel.user.cookie != null &&
        kAdvanceConfig['EnableSyncCartFromWebsite']) {
      await Services()
          .widget
          .syncCartFromWebsite(userModel.user.cookie, context);
    }

    if (userModel.user != null && userModel.user.cookie != null) {
      await Provider.of<PointModel>(context, listen: false).getMyPoint(
          Provider.of<UserModel>(context, listen: false).user.cookie);
    }

    DynamicLinkService();

    ShowNotificationOffer(context);
  }

  // ignore: always_declare_return_types
  static ShowNotificationOffer(BuildContext context) async {
    if (OneSignalWapper.hasNotificationData &&
        OneSignalWapper.productIdArray.isNotEmpty) {
      var loadedProducts = <Product>[];
      loadedProducts.clear();
      final _service = Services();
      for (var i = 0; i < OneSignalWapper.productIdArray.length; i++) {
        var newProduct =
            await _service.api.getProduct(OneSignalWapper.productIdArray[i]);
        loadedProducts.add(newProduct);
      }
      hideLoading();
      var loadedCategoryID = OneSignalWapper.categoryID;
      OneSignalWapper.hasNotificationData = false;
      OneSignalWapper.productIdArray.clear();
      OneSignalWapper.categoryID = 'null';
      if (loadedProducts.length == 1) {
        return Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) =>
                  ProductDetailScreen(product: loadedProducts[0]),
              fullscreenDialog: true,
            ));
      } else if (loadedProducts.length > 1) {
        dynamic config;
        if (loadedCategoryID != 'null') {
          config = {'category': loadedCategoryID, 'name': 'Hot Offers!'};
        } else {
          config = {'category': '15', 'name': 'Hot Offers!'};
        }
        await ProductModel.showList(
            context: context, config: config, products: loadedProducts);
      }
    }
  }

  // ignore: always_declare_return_types
  static showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        loadingContext = context;
        return Center(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(5.0)),
            padding: const EdgeInsets.all(50.0),
            child: kLoadingWidget(context),
          ),
        );
      },
    );
  }

  // ignore: always_declare_return_types
  static hideLoading() {
    Navigator.of(loadingContext).pop();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    printLog('[Home] build');
    return Consumer<AppModel>(
      builder: (context, value, child) {
        if (value.appConfig == null) {
          return kLoadingWidget(context);
        }
        bool isStickyHeader = value.appConfig['Setting'] != null
            ? (value.appConfig['Setting']['StickyHeader'] ?? false)
            : false;

        return Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          body: Stack(
            children: <Widget>[
              if (value.appConfig['Background'] != null)
                isStickyHeader
                    ? SafeArea(
                        child: HomeBackground(
                          config: value.appConfig['Background'],
                        ),
                      )
                    : HomeBackground(config: value.appConfig['Background']),
              HomeLayout(
                isPinAppBar: isStickyHeader,
                isShowAppbar:
                    value.appConfig['HorizonLayout'][0]['layout'] == 'logo',
                configs: value.appConfig,
                key: Key(value.langCode),
              ),
              const FakeStatusBar(),
            ],
          ),
        );
      },
    );
  }
}
