import 'package:flutter/material.dart';
import 'package:inspireui/test/context_test.dart';
import 'package:inspireui/utils/screen_utils.dart';

Widget makeTestableWidget({
  Widget child,
  MediaQueryData mediaQueryData,
}) {
  return Builder(
    builder: (context) {
      return MaterialApp(
        home: Scaffold(body: child),
      );
    },
  );
}

Widget wrapWidget(Widget widget, NavigatorObserver observer) {
  ScreenUtil.init(MockBuildContext());

  return MaterialApp(
    home: widget,
    navigatorObservers: [observer],
  );
}

Widget widgetTestCanPop(Widget widget, NavigatorObserver observer) {
  return MaterialApp(
    initialRoute: '/ab/cc',
    routes: {
      '/ab/cc': (ct) => Scaffold(
            body: widget,
          ),
      '/ab': (ct) => const Scaffold(
            key: ValueKey('test_screen'),
            body: Center(),
          ),
    },
    navigatorObservers: [observer],
  );
}
