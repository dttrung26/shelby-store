import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../common/constants.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/app_model.dart';
import '../../../../screens/settings/language_screen.dart';
import '../../models/authentication_model.dart';
import 'widgets/setting_item.dart';

class VendorAdminSettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authModel =
        Provider.of<VendorAdminAuthenticationModel>(context, listen: false);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          S.of(context).settings,
          style: Theme.of(context).primaryTextTheme.headline5,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
        brightness: Theme.of(context).brightness,
      ),
      body: Container(
          width: size.width,
          height: size.height,
          child: Consumer<AppModel>(
            builder: (context, model, _) => SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  CircleAvatar(
                    radius: 50.0,
                    backgroundColor: Colors.grey,
                    backgroundImage:
                        NetworkImage(authModel.user.picture ?? kDefaultImage),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${authModel.user.firstName} ${authModel.user.lastName}',
                    style: Theme.of(context).primaryTextTheme.headline6,
                  ),
                  const SizedBox(height: 30),
                  VendorAdminSettingItem(
                    leadingIcon: FontAwesomeIcons.globe,
                    title: S.of(context).language,
                    actionIcon: Icons.arrow_forward_ios_outlined,
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => LanguageScreen()),
                    ),
                  ),
                  VendorAdminSettingItem(
                      leadingIcon: model.darkTheme
                          ? FontAwesomeIcons.moon
                          : FontAwesomeIcons.sun,
                      title: S.of(context).darkTheme,
                      isSwitchedOn: model.darkTheme,
                      onTap: () => model.updateTheme(!model.darkTheme)),
                  VendorAdminSettingItem(
                      leadingIcon: Icons.person,
                      title: S.of(context).logout,
                      onTap: authModel.logout),
                ],
              ),
            ),
          )),
    );
  }
}
