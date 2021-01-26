import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import 'chat_screen/conversations.dart';
import 'main_screen/main_screen.dart';
import 'notification_screen/notification_screen.dart';
import 'product_list_screen/product_list_screen.dart';
import 'review_approval_screen/review_approval_screen.dart';
import 'setting_screen/setting_screen.dart';

class ScreenIndex extends StatefulWidget {
  final bool isFromMv;

  const ScreenIndex({Key key, this.isFromMv}) : super(key: key);

  @override
  _ScreenIndexState createState() => _ScreenIndexState();
}

class _ScreenIndexState extends State<ScreenIndex> {
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: Theme.of(context).primaryColor,
        inactiveColor: Theme.of(context).accentColor.withOpacity(0.4),
        currentIndex: pageIndex,
        onTap: (int newValue) {
          setState(() {
            pageIndex = newValue;
          });
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(
              CupertinoIcons.rectangle_grid_2x2_fill,
              size: 22,
            ),
            label: S.of(context).dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              CupertinoIcons.cube_fill,
              size: 22,
            ),
            label: S.of(context).products,
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              CupertinoIcons.bell_fill,
              size: 24,
            ),
            label: S.of(context).notifications,
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              CupertinoIcons.chat_bubble_text_fill,
              size: 22,
            ),
            label: S.of(context).reviews,
          ),
          BottomNavigationBarItem(
            icon: const Icon(
              CupertinoIcons.chat_bubble_text_fill,
              size: 22,
            ),
            label: S.of(context).chatListScreen,
          ),
          if (!widget.isFromMv)
            BottomNavigationBarItem(
              icon: const Icon(
                CupertinoIcons.square_list_fill,
                size: 22,
              ),
              label: S.of(context).settings,
            ),
        ],
      ),
      // ignore: missing_return
      tabBuilder: (BuildContext context, int index) {
        switch (index) {
          case 0:
            return VendorAdminMainScreen(isFromMv: widget.isFromMv);
          case 1:
            return VendorAdminProductListScreen();
          case 2:
            return VendorAdminNotificationScreen();
          case 3:
            return VendorAdminReviewApprovalScreen();
          case 4:
            return ListChatScreen();
          case 5:
            if (!widget.isFromMv) {
              return VendorAdminSettingScreen();
            }
            return Container();
        }
      },
    );
  }
}
