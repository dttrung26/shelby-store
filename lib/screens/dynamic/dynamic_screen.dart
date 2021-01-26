import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../models/app_model.dart';
import '../../models/point_model.dart';
import '../../models/user_model.dart';
import '../../screens/base.dart';
import '../../services/index.dart';
import '../../widgets/firebase/one_signal_wapper.dart';
import '../../widgets/home/background.dart';
import '../../widgets/home/fake_status_bar.dart';
import '../../widgets/home/index.dart';

class DynamicScreen extends StatefulWidget {
  final configs;

  const DynamicScreen({this.configs});

  @override
  State<StatefulWidget> createState() {
    return DynamicScreenState();
  }
}

class DynamicScreenState extends BaseScreen<DynamicScreen>
    with AutomaticKeepAliveClientMixin<DynamicScreen> {
  static BuildContext homeContext;

  static BuildContext loadingContext;

  @override
  bool get wantKeepAlive => true;

  StreamSubscription _sub;
  int itemId;

  @override
  void dispose() {
    printLog('[Home] dispose');
    _sub?.cancel();
    super.dispose();
  }

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    printLog('[Home] afterFirstLayout');

    Future.delayed(
        const Duration(seconds: 1),
        () => Utils.changeStatusBarColor(
            Provider.of<AppModel>(context, listen: false).themeMode));

    homeContext = context;

    if (OneSignalWapper.hasNotificationData &&
        OneSignalWapper.productIdArray.isNotEmpty) {
      showLoading(context);
    }

    final userModel = Provider.of<UserModel>(context, listen: false);

    if (userModel.user != null &&
        userModel.user.cookie != null &&
        kAdvanceConfig['EnableSyncCartFromWebsite']) {
      await Services()
          .widget
          .syncCartFromWebsite(userModel.user.cookie, context);
    }

    if (userModel.user != null && userModel.user.cookie != null) {
      await Provider.of<PointModel>(context, listen: false).getMyPoint(
          Provider.of<UserModel>(context, listen: false).user.cookie);
    }
  }

  // ignore: always_declare_return_types
  static showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        loadingContext = context;
        return Center(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(5.0)),
            padding: const EdgeInsets.all(50.0),
            child: kLoadingWidget(context),
          ),
        );
      },
    );
  }

  // ignore: always_declare_return_types
  static hideLoading() {
    Navigator.of(loadingContext).pop();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    printLog('[Dynamic Screen] build');
    return Consumer<AppModel>(
      builder: (context, value, child) {
        if (value.appConfig == null) {
          return kLoadingWidget(context);
        }
        bool isStickyHeader = value.appConfig['Setting'] != null
            ? (value.appConfig['Setting']['StickyHeader'] ?? false)
            : false;

        return Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          body: Stack(
            children: <Widget>[
              if (value.appConfig['Background'] != null)
                isStickyHeader
                    ? SafeArea(
                        child: HomeBackground(
                          config: value.appConfig['Background'],
                        ),
                      )
                    : HomeBackground(config: value.appConfig['Background']),
              HomeLayout(
                isPinAppBar: isStickyHeader,
                isShowAppbar:
                    widget.configs['HorizonLayout'][0]['layout'] == 'logo',
                configs: widget.configs,
                key: Key(value.langCode),
              ),
              const FakeStatusBar(),
            ],
          ),
        );
      },
    );
  }
}
