import 'dart:async';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/config.dart';
import '../common/constants.dart';
import '../common/tools.dart';
import '../services/index.dart';
import 'cart/cart_model.dart';
import 'category_model.dart';

class AppModel with ChangeNotifier {
  Map<String, dynamic> appConfig;
  bool isLoading = true;
  String message;

  // bool darkTheme = kDefaultDarkTheme ?? false;
  String _langCode = kAdvanceConfig['DefaultLanguage'];
  List<String> categories;
  String categoryLayout;
  List<String> categoriesIcons;
  String productListLayout;
  double ratioProductImage;
  String currency; //USD, VND
  String currencyCode;
  int smallestUnitRate;
  Map<String, dynamic> currencyRate = <String, dynamic>{};
  bool showDemo = false;
  String username;
  bool isInit = false;
  Map<String, dynamic> drawer;
  Map deeplink;
  VendorType vendorType;
  // ListingType listingType;

  String get langCode => _langCode;
  ThemeMode themeMode;

  AppModel() {
    getConfig();
    vendorType = kFluxStoreMV.contains(serverConfig['type'])
        ? VendorType.multi
        : VendorType.single;
  }

  bool get darkTheme => themeMode == ThemeMode.dark;

  set darkTheme(bool value) =>
      themeMode = value ? ThemeMode.dark : ThemeMode.light;

  Future<bool> getConfig() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      var defaultCurrency = kAdvanceConfig['DefaultCurrency'] as Map;

      _langCode =
          prefs.getString('language') ?? kAdvanceConfig['DefaultLanguage'];
      darkTheme = prefs.getBool('darkTheme') ?? kDefaultDarkTheme ?? false;
      currency = prefs.getString('currency') ?? defaultCurrency['currency'];
      currencyCode =
          prefs.getString('currencyCode') ?? defaultCurrency['currencyCode'];
      smallestUnitRate = defaultCurrency['smallestUnitRate'];
      isInit = true;
      await updateTheme(darkTheme);
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> changeLanguage(String country, BuildContext context) async {
    try {
      var prefs = await SharedPreferences.getInstance();
      _langCode = country;
      await prefs.setString('language', _langCode);
      await loadAppConfig(isSwitched: true);
      await loadCurrency();
      eventBus.fire(const EventChangeLanguage());

      await Provider.of<CategoryModel>(context, listen: false)
          .getCategories(lang: country, sortingList: categories);

      return true;
    } catch (err) {
      return false;
    }
  }

  Future<void> changeCurrency(String item, BuildContext context,
      {String code}) async {
    try {
      Provider.of<CartModel>(context, listen: false).changeCurrency(item);
      var prefs = await SharedPreferences.getInstance();
      currency = item;
      currencyCode = code;
      await prefs.setString('currencyCode', currencyCode);
      await prefs.setString('currency', currency);
      notifyListeners();
    } catch (error) {
      printLog('[_getFacebookLink] error: ${error.toString()}');
    }
  }

  Future<void> updateTheme(bool theme) async {
    try {
      var prefs = await SharedPreferences.getInstance();
      darkTheme = theme;
      Utils.changeStatusBarColor(themeMode);
      await prefs.setBool('darkTheme', theme);
      notifyListeners();
    } catch (error) {
      printLog('[_getFacebookLink] error: ${error.toString()}');
    }
  }

  void updateShowDemo(bool value) {
    showDemo = value;
    notifyListeners();
  }

  void updateUsername(String user) {
    username = user;
    notifyListeners();
  }

  void loadStreamConfig(config) {
    appConfig = config;
    productListLayout = appConfig['Setting']['ProductListLayout'];
    isLoading = false;
    notifyListeners();
  }

  Future<Map> loadAppConfig({isSwitched = false}) async {
    try {
      if (!isInit) {
        await getConfig();
      }
      final storage = LocalStorage('builder.json');
      var config = await storage.getItem('config');
      if (config != null) {
        appConfig = config;
      } else {
        /// we only apply the http config if isUpdated = false, not using switching language
        // ignore: prefer_contains
        if (kAppConfig.indexOf('http') != -1) {
          // load on cloud config and update on air
          var path = kAppConfig;
          if (path.contains('.json')) {
            path = path.substring(0, path.lastIndexOf('/'));
            path += '/config_$langCode.json';
          }
          final appJson = await http.get(Uri.encodeFull(path),
              headers: {'Accept': 'application/json'});
          appConfig =
              convert.jsonDecode(convert.utf8.decode(appJson.bodyBytes));
        } else {
          // load local config
          var path = 'lib/config/config_$langCode.json';
          try {
            final appJson = await rootBundle.loadString(path);
            appConfig = convert.jsonDecode(appJson);
          } catch (e) {
            final appJson = await rootBundle.loadString(kAppConfig);
            appConfig = convert.jsonDecode(appJson);
          }
        }
      }

      /// Load Product ratio from config file
      productListLayout = appConfig['Setting']['ProductListLayout'];
      ratioProductImage = appConfig['Setting']['ratioProductImage'] ??
          kAdvanceConfig['RatioProductImage'] ??
          1.2;

      drawer = appConfig['Drawer'] != null
          ? Map<String, dynamic>.from(appConfig['Drawer'])
          : kDefaultDrawer;

      /// Load categories config for the Tabbar menu
      /// User to sort the category Setting
      var categoryTab = appConfig['TabBar'].firstWhere(
          (e) => e['layout'] == 'category' || e['layout'] == 'vendors',
          orElse: () => {});
      if (categoryTab['categories'] != null) {
        categories = List<String>.from(categoryTab['categories']);
        categoryLayout = categoryTab['categoryLayout'];
        categoriesIcons = List<String>.from(categoryTab['images']);
      }

      /// apply App Caching if isCaching is enable
      if (!kIsWeb) {
        await Services().widget.onLoadedAppConfig(langCode, (configCache) {
          appConfig = configCache;
        });
      }
      isLoading = false;

      printLog('[Debug] Finish Load AppConfig');

      notifyListeners();

      return appConfig;
    } catch (err, trace) {
      printLog(trace);
      isLoading = false;
      message = err.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> loadCurrency() async {
    /// Load the Rate for Product Currency
    final rates = await Services().api.getCurrencyRate();
    if (rates != null) {
      currencyRate = rates;
    }
  }

  void updateProductListLayout(layout) {
    productListLayout = layout;
    notifyListeners();
  }
}
