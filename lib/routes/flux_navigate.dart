import 'package:flutter/material.dart';

import '../app.dart';
import '../common/config.dart';
import '../services/service_config.dart';
import '../tabbar.dart';

/// Push screen on TabBar
class FluxNavigate {
  static NavigatorState get _rootNavigator =>
      Navigator.of(App.fluxStoreNavigatorKey.currentContext);

  static NavigatorState get _tabNavigator => Navigator.of(
      MainTabControlDelegate.getInstance().tabKey().currentContext);

  static NavigatorState get _navigator => ((Config().isBuilder ?? false) ||
          (kAdvanceConfig['AlwaysShowTabBar'] ?? false))
      ? _tabNavigator
      : _rootNavigator;

  static Future pushNamed(
    String routeName, {
    Object arguments,
    bool forceRootNavigator = false,
  }) {
    if (forceRootNavigator) {
      return _rootNavigator.pushNamed(
        routeName,
        arguments: arguments,
      );
    }

    return _navigator.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  static Future pushReplacementNamed(String routeName) {
    return _navigator.pushReplacementNamed(routeName);
  }

  static Future<dynamic> push(Route<dynamic> route,
      {bool forceRootNavigator = false}) {
    if (forceRootNavigator) return _rootNavigator.push(route);
    return _navigator.push(route);
  }
}
