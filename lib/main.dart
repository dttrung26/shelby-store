import 'dart:io' show HttpClient;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'app.dart';
import 'common/config.dart';
import 'common/constants.dart';
import 'frameworks/vendor_admin/vendor_admin_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GestureBinding.instance.resamplingEnabled = true;

  Provider.debugCheckInvalidValueType = null;
  printLog('[main] ============== main.dart START ==============');

  if (!kIsWeb) {
    /// enable network traffic logging
    HttpClient.enableTimelineLogging = true;

    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );
  }

  //Initialize Firebase due to version 0.5.0+ requires to
  if (!isWindow) await Firebase.initializeApp();
  printLog('[main] Initialize Firebase successfully');

  if (serverConfig['type'] == 'vendorAdmin') {
    return runApp(const VendorAdminApp());
  }

  ResponsiveSizingConfig.instance.setCustomBreakpoints(const ScreenBreakpoints(
    desktop: 900,
    tablet: 600,
    watch: 100,
  ));
  runApp(App());
}
