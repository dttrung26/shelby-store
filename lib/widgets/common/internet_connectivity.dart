import 'dart:async';
import 'dart:io' show InternetAddress, SocketException;

import 'package:connectivity/connectivity.dart';

import '../../common/constants.dart';

class MyConnectivity {
  MyConnectivity._internal();
  static final MyConnectivity _instance = MyConnectivity._internal();
  static MyConnectivity get instance => _instance;

  Connectivity connectivity = Connectivity();

  StreamController controller = StreamController.broadcast();
  Stream get myStream => controller.stream;
  bool isShow = false;
  bool isOnline = false;

  Future<void> initialise() async {
    var result = await connectivity.checkConnectivity();
    await _checkStatus(result);
    connectivity.onConnectivityChanged.listen(_checkStatus);
  }

  Future<void> _checkStatus(ConnectivityResult result) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        printLog('[MyConnectivity] online');
        isOnline = true;
      } else {
        printLog('[MyConnectivity] offline');
        isOnline = false;
      }
    } on SocketException catch (_) {
      isOnline = false;
    }
    controller.sink.add({result: isOnline});
  }

  bool isIssue(dynamic onData) =>
      onData.keys.toList()[0] == ConnectivityResult.none;

  void disposeStream() => controller.close();

  static void checking() {
    if (!MyConnectivity.instance.isOnline && !kIsWeb) {
      //   throw Exception(
      //       'There is an issue with the connection between mobile and the server, please make sure the internet is working fine');
    }
  }
}
