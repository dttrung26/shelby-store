import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../app.dart';
import '../../common/config.dart';
import '../../common/constants.dart';
import '../../models/index.dart' show FStoreNotification;
import '../../screens/home/home.dart';

class OneSignalWapper {
  static bool hasNotificationData = false;
  static List<String> productIdArray = [];
  static String categoryID = 'null';

  void init() {
    if (kOneSignalKey['appID'] != '' && kOneSignalKey['enable'] == true) {
      Future.delayed(Duration.zero, () async {
        var allowed =
            await OneSignal.shared.promptUserForPushNotificationPermission();
        if (isIos && allowed != null || !isIos) {
          OneSignal.shared.setNotificationOpenedHandler(
              (OSNotificationOpenedResult result) async {
            printLog(result.notification
                .jsonRepresentation()
                .replaceAll('\\n', '\n'));

            if (result.notification.payload.additionalData != null) {
              if (result.notification.payload.additionalData
                  .containsKey('products')) {
                hasNotificationData = true;
                var products = result
                    .notification.payload.additionalData['products']
                    .toString();
                productIdArray = products.split(',');
                if (result.notification.payload.additionalData
                    .containsKey('category')) {
                  categoryID = result
                      .notification.payload.additionalData['category']
                      .toString();
                }
              }
            }

            if (hasNotificationData &&
                productIdArray.isNotEmpty &&
                HomeScreenState.homeContext != null) {
              HomeScreenState.showLoading(
                  App.fluxStoreNavigatorKey.currentContext);
              await HomeScreenState.ShowNotificationOffer(
                  App.fluxStoreNavigatorKey.currentContext);
            }
          });
          await OneSignal.shared.init(
            kOneSignalKey['appID'],
            iOSSettings: {
              OSiOSSettings.autoPrompt: false,
              OSiOSSettings.inAppLaunchUrl: true
            },
          );
          await OneSignal.shared
              .setInFocusDisplayType(OSNotificationDisplayType.notification);

          OneSignal.shared
              .setNotificationReceivedHandler((OSNotification osNotification) {
            // print(osNotification.payload.body.toString());
            // print(osNotification.payload.notificationId);
            var a = FStoreNotification.fromOneSignal(osNotification);
            a.saveToLocal(
              osNotification.payload.notificationId ??
                  DateTime.now().toString(),
            );
          });
        }
      });
    }
  }

  /// Vendor Admin
  void setExternalId(String username) async {
    await OneSignal.shared.setExternalUserId(username);
  }
}
