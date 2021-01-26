import 'package:firebase_messaging/firebase_messaging.dart';
import '../../common/constants.dart';

abstract class FirebaseCloudMessagagingAbs {
  void init();
  FirebaseCloudMessagingDelegate delegate;
}

abstract class FirebaseCloudMessagingDelegate {
  Future<void> onMessage(Map<String, dynamic> message);
  Future<void> onResume(Map<String, dynamic> message);
  Future<void> onLaunch(Map<String, dynamic> message);
}

class FirebaseCloudMessagagingWapper extends FirebaseCloudMessagagingAbs {
  FirebaseMessaging _firebaseMessaging;

  @override
  void init() {
    _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.getToken().then((token) async {
      printLog('[FCM]--> token: [ $token ]');
    });
    firebaseCloudMessagingListeners();
  }

  void firebaseCloudMessagingListeners() {
    if (isIos) {
      iOSPermission();
    }

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) => delegate?.onMessage(message),
      onResume: (Map<String, dynamic> message) => delegate?.onResume(message),
      onLaunch: (Map<String, dynamic> message) => delegate?.onLaunch(message),
    );
  }

  void iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});
  }
}
