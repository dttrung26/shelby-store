import 'package:flutter/material.dart';

Widget makeTestableWidget({
  Function(BuildContext) builder,
  MediaQueryData mediaQueryData,
}) {
  return MaterialApp(
    home: Scaffold(body: Builder(builder: builder)),
  );
}

Widget wrapWidget(Widget widget, NavigatorObserver observer) {
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
