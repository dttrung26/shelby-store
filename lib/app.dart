import 'dart:async';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'app_init.dart';
import 'common/config.dart';
import 'common/constants.dart';
import 'common/theme/index.dart';
import 'common/tools.dart';
import 'generated/custom_languages/custom_global_widgets.dart';
import 'generated/custom_languages/index.dart';
import 'generated/l10n.dart';
import 'models/index.dart';
import 'models/listing/listing_location_model.dart';
import 'route.dart';
import 'routes/route_observer.dart';
import 'services/index.dart';
import 'tabbar.dart';
import 'widgets/common/internet_connectivity.dart';
import 'widgets/firebase/firebase_analytics_wapper.dart';
import 'widgets/firebase/firebase_cloud_messaging_wapper.dart';
import 'widgets/firebase/one_signal_wapper.dart';

class App extends StatefulWidget {
  App();

  static final GlobalKey<NavigatorState> fluxStoreNavigatorKey = GlobalKey();

  @override
  State<StatefulWidget> createState() {
    return AppState();
  }
}

class AppState extends State<App>
    implements FirebaseCloudMessagingDelegate, UserModelDelegate {
  final _app = AppModel();
  final _product = ProductModel();
  final _wishlist = WishListModel();
  final _shippingMethod = ShippingMethodModel();
  final _paymentMethod = PaymentMethodModel();
  final _advertisementModel = Ads();
  final _order = OrderModel();
  final _recent = RecentModel();
  final _user = UserModel();
  final _filterModel = FilterAttributeModel();
  final _filterTagModel = FilterTagModel();
  final _categoryModel = CategoryModel();
  final _tagModel = TagModel();
  final _taxModel = TaxModel();
  final _pointModel = PointModel();

  // ---------- Vendor -------------
  StoreModel _storeModel;
  VendorShippingMethodModel _vendorShippingMethodModel;

  /// -------- Listing ------------///
  final _listingLocationModel = ListingLocationModel();

  CartInject cartModel = CartInject();
  bool isFirstSeen = false;
  bool isLoggedIn = false;

  FirebaseAnalyticsAbs firebaseAnalyticsAbs;

  void checkInternetConnection() {
    if (kIsWeb || isMacOS || isWindow) {
      return;
    }
    MyConnectivity.instance.initialise();
    MyConnectivity.instance.myStream.listen((onData) {
      printLog('[App] internet issue change: $onData');
    });
  }

  @override
  void initState() {
    printLog('[AppState] initState');

    if (kIsWeb) {
      printLog('[AppState] init WEB');
      firebaseAnalyticsAbs = FirebaseAnalyticsWeb();
    } else {
      firebaseAnalyticsAbs = FirebaseAnalyticsWapper()..init();

      Future.delayed(
        const Duration(seconds: 1),
        () {
          printLog('[AppState] init mobile modules ..');
          checkInternetConnection();

          _user.delegate = this;

          if (isMobile) {
            FirebaseCloudMessagagingWapper()
              ..init()
              ..delegate = this;
          }

          OneSignalWapper()..init();
          printLog('[AppState] register modules .. DONE');
        },
      );
    }

    super.initState();
  }

  void _saveMessage(Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      _app.deeplink = message['data'];
    }

    var a = FStoreNotification.fromJsonFirebase(message);
    final id = message['notification'] != null
        ? message['notification']['tag']
        : message['data']['google.message_id'];

    a.saveToLocal(id);
  }

  @override
  Future<void> onLaunch(Map<String, dynamic> message) async {
    printLog('[app.dart] onLaunch Pushnotification: $message');

    _saveMessage(message);
  }

  @override
  Future<void> onMessage(Map<String, dynamic> message) async {
    printLog('[app.dart] onMessage Pushnotification: $message');

    _saveMessage(message);
  }

  @override
  Future<void> onResume(Map<String, dynamic> message) async {
    printLog('[app.dart] onResume Pushnotification: $message');

    _saveMessage(message);
  }

  void updateDeviceToken(User user) {
    if (kAdvanceConfig['EnableFirebase']) {
      FirebaseMessaging().getToken().then((token) async {
        try {
          await Services()
              .api
              .updateUserInfo({'deviceToken': token}, user.cookie);
        } catch (e) {
          printLog(e);
        }
      });
    }
  }

  @override
  // ignore: always_declare_return_types
  Future<void> onLoaded(User user) async {
    updateDeviceToken(user);
  }

  @override
  Future<void> onLoggedIn(User user) async => updateDeviceToken(user);

  @override
  // ignore: always_declare_return_types
  onLogout(User user) async {
    if (kAdvanceConfig['EnableFirebase']) {
      try {
        await Services().api.updateUserInfo({'deviceToken': ''}, user.cookie);
      } catch (e) {
        printLog(e);
      }
    }
  }

  /// Build the App Theme
  ThemeData getTheme(context) {
    printLog('[AppState] build Theme');

    var appModel = Provider.of<AppModel>(context);
    var isDarkTheme = appModel.darkTheme ?? false;

    if (appModel.appConfig == null) {
      /// This case is loaded first time without config file
      return buildLightTheme(appModel.langCode);
    }

    if (isDarkTheme) {
      return buildDarkTheme(appModel.langCode).copyWith(
        primaryColor: HexColor(
          appModel.appConfig['Setting']['MainColor'],
        ),
      );
    }
    return buildLightTheme(appModel.langCode).copyWith(
      primaryColor: HexColor(appModel.appConfig['Setting']['MainColor']),
    );
  }

  @override
  Widget build(BuildContext context) {
    printLog('[AppState] build');
    return ChangeNotifierProvider<AppModel>(
      create: (context) => _app,
      child: Consumer<AppModel>(
        builder: (context, value, child) {
          if (value.vendorType == VendorType.multi &&
              _storeModel == null &&
              _vendorShippingMethodModel == null) {
            _storeModel = StoreModel();
            _vendorShippingMethodModel = VendorShippingMethodModel();
          }
          return Directionality(
            textDirection: TextDirection.rtl,
            child: MultiProvider(
              providers: [
                Provider<ProductModel>.value(value: _product),
                Provider<WishListModel>.value(value: _wishlist),
                Provider<ShippingMethodModel>.value(value: _shippingMethod),
                Provider<PaymentMethodModel>.value(value: _paymentMethod),
                Provider<OrderModel>.value(value: _order),
                Provider<RecentModel>.value(value: _recent),
                Provider<UserModel>.value(value: _user),
                ChangeNotifierProvider<FilterAttributeModel>(
                    create: (_) => _filterModel),
                ChangeNotifierProvider<FilterTagModel>(
                    create: (_) => _filterTagModel),
                ChangeNotifierProvider<CategoryModel>(
                    create: (_) => _categoryModel),
                ChangeNotifierProvider(create: (_) => _tagModel),
                ChangeNotifierProvider(create: (_) => cartModel.model),
                ChangeNotifierProvider(create: (_) => BlogModel()),
                ChangeNotifierProvider(create: (_) => _advertisementModel),
                Provider<TaxModel>.value(value: _taxModel),
                if (value.vendorType == VendorType.multi) ...[
                  ChangeNotifierProvider<StoreModel>(
                      create: (_) => _storeModel),
                  Provider<VendorShippingMethodModel>.value(
                      value: _vendorShippingMethodModel),
                ],
                Provider<PointModel>.value(value: _pointModel),
                if ([
                  ConfigType.listpro,
                  ConfigType.listeo,
                ].contains(Config().type)) ...[
                  ChangeNotifierProvider<ListingLocationModel>(
                      create: (_) => _listingLocationModel)
                ]
              ],
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                navigatorKey: App.fluxStoreNavigatorKey,
                locale: Locale(value.langCode, ''),
                navigatorObservers: [
                  MyRouteObserver(),
                  ...firebaseAnalyticsAbs.getMNavigatorObservers()
                ],
                localizationsDelegates: [
                  S.delegate,
                  GlobalMaterialLocalizations.delegate,
                  CustomGlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  DefaultCupertinoLocalizations.delegate,
                  ...UnSupportedLanguagesDelegate.data,
                ],
                supportedLocales:
                    S.delegate.supportedLocales + [const Locale('ku', '')],
                home: Scaffold(
                  body: AppInit(
                    onNext: () => MainTabs(),
                  ),
                ),
                routes: Routes.getAll(),
                onGenerateRoute: Routes.getRouteGenerate,
                theme: getTheme(context),
                themeMode: value.themeMode,
              ),
            ),
          );
        },
      ),
    );
  }
}
