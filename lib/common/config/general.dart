part of '../config.dart';

/// Default app config, it's possible to set as URL
const kAppConfig = 'lib/config/config_en.json';

// TODO 3.3 - Shipping Address - Google Map Picker (optional) 🚢
/// Ref: https://support.inspireui.com/help-center/articles/3/25/16/google-map-address
/// The Google API Key to support Pick up the Address automatically
/// We recommend to generate both ios and android to restrict by bundle app id
/// The download package is remove these keys, please use your own key
const kGoogleAPIKey = {
  'android': 'AIzaSyDW3uXzZepWBPi-69BIYKyS-xo9NjFSFhQ',
  'ios': 'AIzaSyDW3uXzZepWBPi-69BIYKyS-xo9NjFSFhQ',
  'web': 'AIzaSyDW3uXzZepWBPi-69BIYKyS-xo9NjFSFhQ'
};

/// user for upgrader version of app, remove the comment from lib/app.dart to enable this feature
/// https://tppr.me/5PLpD
const kUpgradeURLConfig = {
  'android':
      'https://play.google.com/store/apps/details?id=com.inspireui.fluxstore',
  'ios': 'https://apps.apple.com/us/app/mstore-flutter/id1469772800'
};

// FIXME 3.1 - Change Rating Store ID ⭐️
/// Use for Rating app on store feature
/// make sure to replace the bundle ID by your own ID to prevent the app review reject
const kStoreIdentifier = {
  'disable': true,
  'android': 'com.inspireui.fluxstore',
  'ios': '1469772800'
};

const kAdvanceConfig = {
  /// TODO 3.2 - Default Languages 🇺🇸
  'DefaultLanguage': 'en',
  'DetailedBlogLayout': kBlogLayout.halfSizeImageType,
  'EnablePointReward': true,
  'hideOutOfStock': false,
  'EnableRating': true,
  'hideEmptyProductListRating': true,
  'EnableShipping': true,

  /// Enable search by SKU in search screen
  'EnableSkuSearch': true,

  /// Show stock Status on product List & Product Detail
  'showStockStatus': false,

  /// Gird count setting on Category screen
  'GridCount': 3,

  // TODO 2.2 - App Performance, Image Optimize (advanced) ⚡️
  /// set isCaching to true if you have upload the config file to mstore-api
  /// set kIsResizeImage to true if you have finished running Re-generate image plugin
  /// ref: https://support.inspireui.com/help-center/articles/3/8/19/app-performance
  'isCaching': false,
  'kIsResizeImage': false,

  // FIXME: 2.1 - Mutli-Currencies, Default Currency (optional) 💶
  /// Stripe payment only: set currencyCode and smallestUnitRate.
  /// All API requests expect amounts to be provided in a currency’s smallest unit.
  /// For example, to charge 10 USD, provide an amount value of 1000 (i.e., 1000 cents).
  /// Reference: https://stripe.com/docs/currencies#zero-decimal
  'DefaultCurrency': {
    'symbol': '\$',
    'decimalDigits': 2,
    'symbolBeforeTheNumber': true,
    'currency': 'USD',
    'currencyCode': 'usd',
    'smallestUnitRate': 100, // 100 cents = 1 usd
  },
  'Currencies': [
    {
      'symbol': '\$',
      'decimalDigits': 2,
      'symbolBeforeTheNumber': true,
      'currency': 'USD',
      'currencyCode': 'usd',
      'smallestUnitRate': 100, // 100 cents = 1 usd
    },
    {
      'symbol': 'đ',
      'decimalDigits': 2,
      'symbolBeforeTheNumber': false,
      'currency': 'VND',
      'currencyCode': 'VND',
    },
    {
      'symbol': '€',
      'decimalDigits': 2,
      'symbolBeforeTheNumber': true,
      'currency': 'EUR',
      'currencyCode': 'EUR',
    },
    {
      'symbol': '£',
      'decimalDigits': 2,
      'symbolBeforeTheNumber': true,
      'currency': 'Pound sterling',
      'currencyCode': 'gbp',
      'smallestUnitRate': 100, // 100 pennies = 1 pound
    },
    {
      'symbol': '\$',
      'decimalDigits': 2,
      'symbolBeforeTheNumber': true,
      'currency': 'ARS',
      'currencyCode': 'ARS',
    }
  ],

  // TODO 4.4 - Update Magento Config Product (optional) 📦
  /// Below config is used for Magento store
  'DefaultStoreViewCode': '',
  'EnableAttributesConfigurableProduct': ['color', 'size'],
  'EnableAttributesLabelConfigurableProduct': ['color', 'size'],

  /// if the woo commerce website supports multi languages
  /// set false if the website only have one language
  'isMultiLanguages': true,

  ///Review gets approved automatically on woocommerce admin without requiring administrator to approve.
  'EnableApprovedReview': false,

  /// Sync Cart from website and mobile
  'EnableSyncCartFromWebsite': false,
  'EnableSyncCartToWebsite': false,

  /// Disable shopping Cart due to Listing Users request
  'EnableShoppingCart': false,

  /// Enable firebase to support FCM, realtime chat for Fluxstore MV
  'EnableFirebase': true,

  /// ratio Product Image, default value is 1.2 = height / width
  'RatioProductImage': 1.2,

  /// Enable Coupon Code When checkout
  'EnableCouponCode': true,

  /// Enable to Show Coupon list.
  'ShowCouponList': true,

  /// Enable this will show all coupons in Coupon list.
  /// Disable will show only coupons which is restricted to the current user's email.
  'ShowAllCoupons': true,

  /// Show expired coupons in Coupon list.
  'ShowExpiredCoupons': true,
  'AlwaysShowTabBar': false,

  /// The radius to get vendors in map view for Fluxstore MV
  'QueryRadiusDistance': 10, //km
};

// FIXME 1.2 - Left Menu Setting ✅
/// this could be config via Fluxbuilder tool http://fluxbuilder.com/
const kDefaultDrawer = {
  'logo': 'assets/images/logo.png',
  'background': null,
  'items': [
    {'type': 'home', 'show': true},
    {'type': 'blog', 'show': true},
    {'type': 'categories', 'show': true},
    {'type': 'cart', 'show': true},
    {'type': 'profile', 'show': true},
    {'type': 'login', 'show': true},
    {'type': 'category', 'show': true},
  ]
};

// FIXME: 1.3 - Setting/User Profile Screens Menu ✅
/// you could order the position to change menu
/// this feature could be done via Fluxbuilder
const kDefaultSettings = [
  'products',
  'chat',
  'wishlist',
  'notifications',
  'language',
  'currencies',
  'darkTheme',
  'order',
  'point',
  'rating',
  'privacy',
  'about'
];

// TODO: 1.1 - Update Social Login Login  🧩
/// ref: https://support.inspireui.com/help-center/articles/3/25/15/social-login
const kLoginSetting = {
  'IsRequiredLogin': false,
  'showAppleLogin': true,
  'showFacebook': true,
  'showSMSLogin': true,
  'showGoogleLogin': true,
  'showPhoneNumberWhenRegister': false,
  'requirePhoneNumberWhenRegister': false,
};

// FIXME: 3.2 - Push Notification For OneSignal 🔔
/// Ref: https://support.inspireui.com/help-center/articles/3/8/14/push-notifications
const kOneSignalKey = {
  'enable': false,
  'appID': '8b45b6db-7421-45e1-85aa-75e597f62714',
};

/// TODO 1.4 - Default SMS Login Country
class LoginSMSConstants {
  static const String countryCodeDefault = 'VN';
  static const String dialCodeDefault = '+84';
  static const String nameDefault = 'Vietnam';
}

/// update default dark theme
/// advance color theme could be changed from common/styles.dart
const kDefaultDarkTheme = false;
