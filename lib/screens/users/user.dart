import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../settings/settings_screen.dart';

class UserScreen extends StatefulWidget {
  final String background;
  final List<dynamic> settings;
  final bool showChat;
  UserScreen({this.settings, this.background, this.showChat});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen>
    with AutomaticKeepAliveClientMixin<UserScreen> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userModel = Provider.of<UserModel>(context);

    return ListenableProvider.value(
      value: userModel,
      child: Consumer<UserModel>(
        builder: (context, value, child) {
          return SettingScreen(
            settings: widget.settings,
            background: widget.background,
            showChat: widget.showChat,
            user: value.user,
          );
        },
      ),
    );
  }
}
