part of '../config.dart';

// TODO 3.5 - Firebase Dynamic Link Setting 🔗
/// Ref: https://support.inspireui.com/help-center/articles/3/25/18/firebase-dynamic-link
const firebaseDynamicLinkConfig = {
  'isEnabled': true,
  // Domain is the domain name for your product.
  // Let’s assume here that your product domain is “example.com”.
  // Then you have to mention the domain name as : https://example.page.link.
  'uriPrefix': 'https://fluxstoreinspireui.page.link',
  //The link your app will open
  'link': 'https://mstore.io/',
  //----------* Android Setting *----------//
  'androidPackageName': 'com.inspireui.fluxstore',
  'androidAppMinimumVersion': 1,
  //----------* iOS Setting *----------//
  'iOSBundleId': 'com.inspireui.mstore.flutter',
  'iOSAppMinimumVersion': '1.0.1',
  'iOSAppStoreId': '1469772800'
};
