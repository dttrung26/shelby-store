import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';

import '../../app.dart';
import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show AppModel, User, UserModel, WishListModel;
import '../../routes/flux_navigate.dart';
import '../../services/index.dart';
import '../../widgets/common/webview.dart';
import '../custom/smartchat.dart';
import '../index.dart';
import '../users/user_point.dart';
import 'currencies_screen.dart';
import 'language_screen.dart';
import 'notification_screen.dart';

class SettingScreen extends StatefulWidget {
  final List<dynamic> settings;
  final String background;
  final User user;
  final VoidCallback onLogout;
  final bool showChat;

  SettingScreen({
    this.user,
    this.onLogout,
    this.settings,
    this.background,
    this.showChat,
  });

  @override
  _SettingScreenState createState() {
    return _SettingScreenState();
  }
}

class _SettingScreenState extends State<SettingScreen>
    with
        TickerProviderStateMixin,
        WidgetsBindingObserver,
        AutomaticKeepAliveClientMixin<SettingScreen> {
  @override
  bool get wantKeepAlive => true;

  final bannerHigh = 150.0;
  bool enabledNotification = true;
  final RateMyApp _rateMyApp = RateMyApp(
      // rate app on store
      minDays: 7,
      minLaunches: 10,
      remindDays: 7,
      remindLaunches: 10,
      googlePlayIdentifier: kStoreIdentifier['android'],
      appStoreIdentifier: kStoreIdentifier['ios']);

  void showRateMyApp() {
    _rateMyApp.showRateDialog(
      context,
      title: S.of(context).rateTheApp,
      // The dialog title.
      message: S.of(context).rateThisAppDescription,
      // The dialog message.
      rateButton: S.of(context).rate.toUpperCase(),
      // The dialog 'rate' button text.
      noButton: S.of(context).noThanks.toUpperCase(),
      // The dialog 'no' button text.
      laterButton: S.of(context).maybeLater.toUpperCase(),
      // The dialog 'later' button text.
      listener: (button) {
        // The button click listener (useful if you want to cancel the click event).
        switch (button) {
          case RateMyAppDialogButton.rate:
            break;
          case RateMyAppDialogButton.later:
            break;
          case RateMyAppDialogButton.no:
            break;
        }

        return true; // Return false if you want to cancel the click event.
      },
      // Set to false if you want to show the native Apple app rating dialog on iOS.
      dialogStyle: const DialogStyle(),
      // Custom dialog styles.
      // Called when the user dismissed the dialog (either by taping outside or by pressing the 'back' button).
      // actionsBuilder: (_) => [], // This one allows you to use your own buttons.
    );
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await checkNotificationPermission();
    });
    _rateMyApp.init().then((_) {
      // state of rating the app
      if (_rateMyApp.shouldOpenDialog) {
        showRateMyApp();
      }
    });
  }

  // @override
  // void dispose() {
  //   Utils.setStatusBarWhiteForeground(false);
  //   super.dispose();
  // }

  Future<void> checkNotificationPermission() async {
    if (!isAndroid || isIos) {
      return;
    }

    try {
      await NotificationPermissions.getNotificationPermissionStatus()
          .then((status) {
        if (mounted) {
          setState(() {
            enabledNotification = status == PermissionStatus.granted;
          });
        }
      });
    } catch (err) {
      printLog('[Settings Screen] : ${err.toString()}');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkNotificationPermission();
    }
  }

  /// Render the Admin Vendor Menu
  Widget renderVendorAdmin() {
    if (!(widget.user != null ? widget.user.isVender ?? false : false)) {
      return Container();
    }

    return Card(
      color: Theme.of(context).backgroundColor,
      margin: const EdgeInsets.only(bottom: 2.0),
      elevation: 0,
      child: ListTile(
        onTap: () {
          final langCode =
              Provider.of<AppModel>(context, listen: false).langCode;

          if (unsupportedLanguages.contains(langCode)) {
            final snackBar = SnackBar(
              content: Text(
                  S.of(context).thisFeatureDoesNotSupportTheCurrentLanguage),
              duration: const Duration(seconds: 1),
            );
            // ignore: deprecated_member_use
            Scaffold.of(context).showSnackBar(snackBar);
            return;
          }
          FluxNavigate.push(
            MaterialPageRoute(
              builder: (context) =>
                  Services().widget.getAdminVendorScreen(context, widget.user),
            ),
            forceRootNavigator: true,
          );
        },
        leading: Icon(
          Icons.dashboard,
          size: 24,
          color: Theme.of(context).accentColor,
        ),
        title: Text(
          S.of(context).vendorAdmin,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Theme.of(context).accentColor,
        ),
      ),
    );
  }

  /// Render the custom profile link via Webview
  /// Example show some special profile on the woocommerce site: wallet, wishlist...
  Widget renderWebViewProfile() {
    if (widget.user == null) {
      return Container();
    }

    var base64Str = Utils.encodeCookie(widget.user.cookie);
    var profileURL = '${serverConfig['url']}/my-account?cookie=$base64Str';

    return Card(
      color: Theme.of(context).backgroundColor,
      margin: const EdgeInsets.only(bottom: 2.0),
      elevation: 0,
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebView(
                  url: profileURL, title: S.of(context).updateUserInfor),
            ),
          );
        },
        leading: Icon(
          CupertinoIcons.profile_circled,
          size: 24,
          color: Theme.of(context).accentColor,
        ),
        title: Text(
          S.of(context).updateUserInfor,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Theme.of(context).accentColor,
          size: 18,
        ),
      ),
    );
  }

  Widget renderItem(value) {
    IconData icon;
    String title;
    Widget trailing;
    Function() onTap;
    var isMultiVendor = kFluxStoreMV.contains(serverConfig['type']);
    switch (value) {
      case 'products':
        {
          if (!(widget.user != null ? widget.user.isVender ?? false : false)) {
            return Container();
          }
          trailing = const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: kGrey600,
          );
          title = S.of(context).myProducts;
          icon = CupertinoIcons.cube_box;
          onTap = () => Navigator.pushNamed(context, RouteList.productSell);
          break;
        }

      case 'chat':
        {
          if (widget.user == null || Config().isListingType || !isMultiVendor) {
            return Container();
          }
          trailing = const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: kGrey600,
          );
          title = S.of(context).conversations;
          icon = CupertinoIcons.chat_bubble_2;
          onTap = () => Navigator.pushNamed(context, RouteList.listChat);
          break;
        }
      case 'wishlist':
        {
          final wishListCount =
              Provider.of<WishListModel>(context, listen: false)
                  .products
                  .length;
          trailing = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (wishListCount > 0)
                Text(
                  '$wishListCount ${S.of(context).items}',
                  style: TextStyle(
                      fontSize: 14, color: Theme.of(context).primaryColor),
                ),
              const SizedBox(width: 5),
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600)
            ],
          );

          title = S.of(context).myWishList;
          icon = CupertinoIcons.heart;
          onTap = () => Navigator.pushNamed(context, '/wishlist');
          break;
        }
      case 'notifications':
        {
          return Column(
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 2.0),
                elevation: 0,
                child: SwitchListTile(
                  secondary: Icon(
                    CupertinoIcons.bell,
                    color: Theme.of(context).accentColor,
                    size: 24,
                  ),
                  value: enabledNotification,
                  activeColor: const Color(0xFF0066B4),
                  onChanged: (bool value) {
                    if (value) {
                      NotificationPermissions.requestNotificationPermissions(
                        iosSettings: const NotificationSettingsIos(
                            sound: true, badge: true, alert: true),
                      ).then((_) {
                        checkNotificationPermission();
                      });
                    }
                    setState(() {
                      enabledNotification = value;
                    });
                  },
                  title: Text(
                    S.of(context).getNotification,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const Divider(
                color: Colors.black12,
                height: 1.0,
                indent: 75,
                //endIndent: 20,
              ),
              if (enabledNotification)
                Card(
                  margin: const EdgeInsets.only(bottom: 2.0),
                  elevation: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationScreen()),
                      );
                    },
                    child: ListTile(
                      leading: Icon(
                        CupertinoIcons.list_bullet,
                        size: 22,
                        color: Theme.of(context).accentColor,
                      ),
                      title: Text(S.of(context).listMessages),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: kGrey600,
                      ),
                    ),
                  ),
                ),
              if (enabledNotification)
                const Divider(
                  color: Colors.black12,
                  height: 1.0,
                  indent: 75,
                  //endIndent: 20,
                ),
            ],
          );
        }
      case 'language':
        {
          icon = CupertinoIcons.globe;
          title = S.of(context).language;
          trailing = const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: kGrey600,
          );
          onTap = () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LanguageScreen()),
              );
          break;
        }
      case 'currencies':
        {
          icon = CupertinoIcons.money_dollar_circle;
          title = S.of(context).currencies;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CurrenciesScreen()),
              );
          break;
        }
      case 'darkTheme':
        {
          return Column(
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 2.0),
                elevation: 0,
                child: SwitchListTile(
                  secondary: Icon(
                    Provider.of<AppModel>(context).darkTheme
                        ? CupertinoIcons.sun_min
                        : CupertinoIcons.moon,
                    color: Theme.of(context).accentColor,
                    size: 24,
                  ),
                  value: Provider.of<AppModel>(context).darkTheme,
                  activeColor: const Color(0xFF0066B4),
                  onChanged: (bool value) {
                    if (value) {
                      Provider.of<AppModel>(context, listen: false)
                          .updateTheme(true);
                    } else {
                      Provider.of<AppModel>(context, listen: false)
                          .updateTheme(false);
                    }
                  },
                  title: Text(
                    S.of(context).darkTheme,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const Divider(
                color: Colors.black12,
                height: 1.0,
                indent: 75,
                //endIndent: 20,
              ),
            ],
          );
        }
      case 'order':
        {
          if (widget.user == null) {
            return Container();
          }
          icon = CupertinoIcons.time;
          title = S.of(context).orderHistory;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
//          onTap = () => Navigator.pushNamed(context, '/orders');
          onTap = () => Navigator.of(context, rootNavigator: true)
              .push(MaterialPageRoute(builder: (context) => OrderList()));
          break;
        }
      case 'point':
        {
          if (!(kAdvanceConfig['EnablePointReward'] == true &&
              widget.user != null)) {
            return const SizedBox();
          }
          icon = CupertinoIcons.bag_badge_plus;
          title = S.of(context).myPoints;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserPoint(),
                ),
              );
          break;
        }
      case 'rating':
        {
//          if (!kAdvanceConfig['EnableRating'] ||
//              (kStoreIdentifier['disable'] ?? false)) {
//            return const SizedBox();
//          }
          icon = CupertinoIcons.star;
          title = S.of(context).rateTheApp;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = showRateMyApp;
          // _rateMyApp.showRateDialog(context).then((v) => setState(() {}));
          break;
        }
      case 'privacy':
        {
          icon = CupertinoIcons.doc_text;
          title = S.of(context).agreeWithPrivacy;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = () {
            if (kIsWeb) {
              return Tools.launchURL(SettingConstants.privacyAndTermUrl);
            }
            return FluxNavigate.push(
              MaterialPageRoute(
                builder: (context) => WebView(
                    url: SettingConstants.privacyAndTermUrl,
                    title: 'Privacy & Terms'),
              ),
              forceRootNavigator: true,
            );
          };
          break;
        }
      case 'about':
        {
          icon = CupertinoIcons.info;
          title = S.of(context).aboutUs;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = () {
            if (kIsWeb) {
              return Tools.launchURL(SettingConstants.aboutUsUrl);
            }
            return FluxNavigate.push(
              MaterialPageRoute(
                builder: (context) => WebView(
                    url: SettingConstants.aboutUsUrl,
                    title: S.of(context).aboutUs),
              ),
              forceRootNavigator: true,
            );
          };
          break;
        }
      default:
        {
          icon = Icons.error;
          title = S.of(context).dataEmpty;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = () {};
          break;
        }
    }

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 2.0),
          elevation: 0,
          child: ListTile(
            leading: Icon(
              icon,
              color: Theme.of(context).accentColor,
              size: 24,
            ),
            title: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            trailing: trailing,
            onTap: onTap,
          ),
        ),
        const Divider(
          color: Colors.black12,
          height: 1.0,
          indent: 75,
          //endIndent: 20,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Utils.setStatusBarWhiteForeground(false);
    super.build(context);

    var loggedIn = Provider.of<UserModel>(context).loggedIn;
    final screenSize = MediaQuery.of(context).size;
    var settings = widget.settings ?? kDefaultSettings;
    var background = widget.background ?? kProfileBackground;
    final showChat = widget.showChat ?? false;
    const textStyle = TextStyle(fontSize: 16);

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      floatingActionButton: showChat
          ? SmartChat(
              margin: EdgeInsets.only(
                right: Provider.of<AppModel>(context, listen: false).langCode ==
                        'ar'
                    ? 30.0
                    : 0.0,
              ),
            )
          : Container(),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Theme.of(context).primaryColor,
            leading: IconButton(
              icon: const Icon(
                Icons.blur_on,
                color: Colors.white70,
              ),
              onPressed: () {
                eventBus.fire('drawer');
                Scaffold.of(context).openDrawer();
              },
            ),
            expandedHeight: bannerHigh,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(S.of(context).settings,
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600)),
              background: Image.network(
                background,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                Container(
                  width: screenSize.width,
                  child: Container(
                    width: screenSize.width /
                        (2 / (screenSize.height / screenSize.width)),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 10.0),
                          if (widget.user != null && widget.user.name != null)
                            ListTile(
                              leading:
                                  (widget.user.picture?.isNotEmpty ?? false)
                                      ? CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(widget.user.picture),
                                        )
                                      : const Icon(Icons.face),
                              title: Text(
                                widget.user.name.replaceAll('fluxstore', ''),
                                style: textStyle,
                              ),
                            ),
                          if (widget.user != null && widget.user.email != null)
                            ListTile(
                              leading: const Icon(Icons.email),
                              title: Text(
                                widget.user.email,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          if (widget.user != null)
                            Card(
                              color: Theme.of(context).backgroundColor,
                              margin: const EdgeInsets.only(bottom: 2.0),
                              elevation: 0,
                              child: ListTile(
                                leading: Icon(
                                  Icons.portrait,
                                  color: Theme.of(context).accentColor,
                                  size: 25,
                                ),
                                title: Text(
                                  S.of(context).updateUserInfor,
                                  style: const TextStyle(fontSize: 15),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: kGrey600,
                                ),
                                onTap: () {
                                  FluxNavigate.pushNamed(
                                    RouteList.updateUser,
                                    forceRootNavigator: true,
                                  );
                                },
                              ),
                            ),
                          if (widget.user == null)
                            Card(
                              color: Theme.of(context).backgroundColor,
                              margin: const EdgeInsets.only(bottom: 2.0),
                              elevation: 0,
                              child: ListTile(
                                onTap: () {
                                  if (!loggedIn) {
                                    Navigator.of(
                                      App.fluxStoreNavigatorKey.currentContext,
                                    ).pushNamed(RouteList.login);
                                    return;
                                  }
                                  Provider.of<UserModel>(context, listen: false)
                                      .logout();
                                  if (kLoginSetting['IsRequiredLogin'] ??
                                      false) {
                                    Navigator.of(
                                      App.fluxStoreNavigatorKey.currentContext,
                                    ).pushNamedAndRemoveUntil(
                                      RouteList.login,
                                      (route) => false,
                                    );
                                  }
                                },
                                leading: const Icon(Icons.person),
                                title: Text(
                                  loggedIn
                                      ? S.of(context).logout
                                      : S.of(context).login,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 18, color: kGrey600),
                              ),
                            ),
                          if (widget.user != null)
                            Card(
                              color: Theme.of(context).backgroundColor,
                              margin: const EdgeInsets.only(bottom: 2.0),
                              elevation: 0,
                              child: ListTile(
                                onTap: () {
                                  Provider.of<UserModel>(context, listen: false)
                                      .logout();
                                  if (kLoginSetting['IsRequiredLogin'] ??
                                      false) {
                                    Navigator.of(App.fluxStoreNavigatorKey
                                            .currentContext)
                                        .pushNamedAndRemoveUntil(
                                      RouteList.login,
                                      (route) => false,
                                    );
                                  }
                                },
                                leading: Icon(
                                  Icons.logout,
                                  size: 20,
                                  color: Theme.of(context).accentColor,
                                ),

                                // Image.asset(
                                //   'assets/icons/profile/icon-logout.png',
                                //   width: 24,
                                //   color: Theme.of(context).accentColor,
                                // ),
                                title: Text(
                                  S.of(context).logout,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 18, color: kGrey600),
                              ),
                            ),
                          const SizedBox(height: 30.0),
                          Text(
                            S.of(context).generalSetting,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10.0),

                          /// render some extra menu for Vendor
                          if (widget.user != null &&
                              widget.user.isVender == true) ...[
                            renderVendorAdmin(),
                            Services().widget.renderVendorOrder(context),
                          ],

                          /// Render custom Wallet feature
                          // renderWebViewProfile(),

                          /// render some extra menu for Listing
                          if (widget.user != null &&
                              Config().isListingType) ...[
                            Services().widget.renderNewListing(context),
                            Services().widget.renderBookingHistory(context),
                          ],

                          const SizedBox(height: 10.0),
                          if (widget.user != null)
                            const Divider(
                              color: Colors.black12,
                              height: 1.0,
                              indent: 75,
                              //endIndent: 20,
                            ),

                          /// render list of dynamic menu
                          /// this could be manage from the Fluxbuilder
                          ...List.generate(
                            settings.length,
                            (index) {
                              return renderItem(settings[index]);
                            },
                          ),
                          const SizedBox(height: 100)
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
