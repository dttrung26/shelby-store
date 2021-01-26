import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'app.dart';
import 'common/constants.dart';
import 'common/packages.dart' show StoryWidget;
import 'common/tools.dart';
import 'generated/l10n.dart';
import 'menu.dart';
import 'models/app_model.dart';
import 'models/cart/cart_model.dart';
import 'models/index.dart';
import 'models/search_model.dart';
import 'route.dart';
import 'screens/base.dart';
import 'screens/index.dart'
    show
        CartScreen,
        PostScreen,
        CategoriesScreen,
        WishListScreen,
        HomeScreen,
        NotificationScreen,
        StaticSite,
        WebViewScreen,
        DynamicScreen;
import 'screens/pages/index.dart';
import 'screens/settings/settings_screen.dart';
import 'services/index.dart';
import 'widgets/blog/slider_list.dart';
import 'widgets/common/auto_hide_keyboard.dart';
import 'widgets/flux_image.dart';
import 'widgets/icons/feather.dart';
import 'widgets/layout/adaptive.dart';
import 'widgets/layout/main_layout.dart';

const int tabCount = 3;
const int turnsToRotateRight = 1;
const int turnsToRotateLeft = 3;

typedef TabKey = GlobalKey<NavigatorState> Function();

class MainTabControlDelegate {
  int index;
  Function(String nameTab) changeTab;
  Function(int index) tabAnimateTo;
  TabKey tabKey;

  static MainTabControlDelegate _instance;

  static MainTabControlDelegate getInstance() {
    return _instance ??= MainTabControlDelegate._();
  }

  MainTabControlDelegate._();
}

class MainTabs extends StatefulWidget {
  MainTabs({Key key}) : super(key: key);

  @override
  MainTabsState createState() => MainTabsState();
}

class MainTabsState extends BaseScreen<MainTabs>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey(debugLabel: 'Dashboard');
  final List<Widget> _tabView = [];
  final navigators = <int, GlobalKey<NavigatorState>>{};

  Map saveIndexTab = {};

  firebase_auth.User loggedInUser;

  TabController tabController;

  bool isFirstLoad = false;
  bool isShowCustomDrawer = false;
  int currentIndex = 0;

  StreamSubscription _subOpenNativeDrawer;
  StreamSubscription _subCloseNativeDrawer;
  StreamSubscription _subOpenCustomDrawer;
  StreamSubscription _subCloseCustomDrawer;

  bool get isDesktopDisplay => isDisplayDesktop(context);

  @override
  void afterFirstLayout(BuildContext context) {
    _loadTabBar(context);
  }

  @override
  void initState() {
    printLog('[Dashboard] init');
    if (!kIsWeb) {
      _getCurrentUser();
    }
    _setupListenEvent();
    MainTabControlDelegate.getInstance().changeTab = _changeTab;
    MainTabControlDelegate.getInstance().tabKey =
        () => navigators[tabController.index];
    MainTabControlDelegate.getInstance().tabAnimateTo = (int index) {
      tabController?.animateTo(index);
    };
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    isShowCustomDrawer = isDesktopDisplay;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    tabController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _subOpenNativeDrawer?.cancel();
    _subCloseNativeDrawer?.cancel();
    _subOpenCustomDrawer?.cancel();
    _subCloseCustomDrawer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // went to Background
    }
    if (state == AppLifecycleState.resumed) {
      // came back to Foreground
      final appModel = Provider.of<AppModel>(context, listen: false);
      if (appModel.deeplink?.isNotEmpty ?? false) {
        if (appModel.deeplink['screen'] == 'NotificationScreen') {
          appModel.deeplink = null;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotificationScreen()),
          );
        }
      }
    }

    super.didChangeAppLifecycleState(state);
  }

  Map get appSetting => Provider.of<AppModel>(context).appConfig['Setting'];

  Color get colorTabBar => appSetting['ColorTabbar'] != null
      ? HexColor(appSetting['ColorTabbar'])
      : null;

  List get tabData => List.from(
      Provider.of<AppModel>(context, listen: false).appConfig['TabBar']);

  @override
  Widget build(BuildContext context) {
    printLog('[tabbar] ============== tabbar.dart DASHBOARD ==============');
    printLog(
        '[Resolution Screen]: ${MediaQuery.of(context).size.width} x ${MediaQuery.of(context).size.height}');
    // Utils.setStatusBarWhiteForeground(true);

    if (_tabView.isEmpty) {
      return Container(
        color: Colors.white,
      );
    }

    final media = MediaQuery.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        key: _scaffoldKey,
        // Disable opening the drawer with a swipe gesture.
        drawerEnableOpenDragGesture: false,
        backgroundColor: Theme.of(context).backgroundColor,
        resizeToAvoidBottomPadding: false,
        body: CupertinoTheme(
          data: CupertinoThemeData(
            primaryColor: Theme.of(context).accentColor,
            barBackgroundColor: Theme.of(context).backgroundColor,
            textTheme: CupertinoTextThemeData(
              navTitleTextStyle: Theme.of(context).textTheme.headline5,
              navLargeTitleTextStyle:
                  Theme.of(context).textTheme.headline4.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
            ),
          ),
          child: WillPopScope(
            onWillPop: _handleWillPopScopeRoot,
            child: MainLayout(
              menu: MenuBar(),
              content: MediaQuery(
                data: isDesktopDisplay
                    ? media.copyWith(
                        size: Size(
                        media.size.width - kSizeLeftMenu,
                        media.size.height,
                      ))
                    : media,
                child: ListenableProvider.value(
                  value: tabController,
                  child: Consumer<TabController>(
                      builder: (context, controller, child) {
                    return Stack(
                      fit: StackFit.expand,
                      children: List.generate(
                        _tabView.length,
                        (index) {
                          final active = controller.index == index;
                          return Offstage(
                            offstage: !active,
                            child: TickerMode(
                              child: _tabView[index],
                              enabled: active,
                            ),
                          );
                        },
                      ).toList(),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
        drawer: isDesktopDisplay ? null : Drawer(child: MenuBar()),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget tabView(Map<String, dynamic> data) {
    switch (data['layout']) {
      case 'category':
        return CategoriesScreen(
          key: const Key('category'),
          layout: data['categoryLayout'],
          showChat: data['showChat'],
          showSearch: data['showSearch'] ?? true,
        );
      case 'search':
        {
          return AutoHideKeyboard(
            child: ChangeNotifierProvider<SearchModel>(
              create: (context) => SearchModel(),
              child: Services().widget.renderSearchScreen(
                    context,
                    showChat: data['showChat'],
                  ),
            ),
          );
        }

      case 'cart':
        return CartScreen(showChat: data['showChat']);
      case 'profile':
        return ListenableProvider.value(
          value: Provider.of<UserModel>(context),
          child: Consumer<UserModel>(builder: (context, model, child) {
            return SettingScreen(
              settings: data['settings'],
              background: data['background'],
              showChat: data['showChat'],
              user: model.user,
            );
          }),
        );
      // return UserScreen(
      //   settings: data['settings'],
      //   background: data['background'],
      //   showChat: data['showChat'],
      // );
      case 'blog':
        return HorizontalSliderList(config: data);
      case 'wishlist':
        return WishListScreen(canPop: false, showChat: data['showChat']);
      case 'page':
        return WebViewScreen(
            title: data['title'], url: data['url'], showChat: data['showChat']);
      case 'html':
        return StaticSite(data: data['data'], showChat: data['showChat']);
      case 'static':
        return StaticPage(data: data['data'], showChat: data['showChat']);
      case 'postScreen':
        return PostScreen(
          pageId: int.parse(data['pageId'].toString()),
          pageTitle: data['pageTitle'],
          isLocatedInTabbar: true,
          showChat: data['showChat'],
        );

      /// Story Screen
      case 'story':
        return StoryWidget(
          config: data,
          isFullScreen: true,
          onTapStoryText: (cfg) {
            Utils.onTapNavigateOptions(context: context, config: cfg);
          },
        );

      /// vendor screens
      case 'vendors':
        return Services().widget.renderVendorCategoriesScreen(data);

      case 'map':
        return Services().widget.renderMapScreen();

      case 'vendorDashboard':
        return Services().widget.renderVendorDashBoard();

      case 'dynamic':
        return DynamicScreen(configs: data['configs']);

      /// Default Home Screen
      default:
        return const HomeScreen();
    }
  }

  Widget _buildBottomBar() {
    final labelSize =
        tabData.any((element) => element['label'] != null) ? 8 : 0;
    return Container(
      color: colorTabBar ?? Theme.of(context).backgroundColor,
      child: SafeArea(
        top: false,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutQuint,
          height: isShowCustomDrawer ? 0 : null,
          constraints: BoxConstraints(
            maxHeight: kBottomNavigationBarHeight -
                getValueForScreenType(
                  context: context,
                  mobile: 15,
                  tablet: 5,
                  desktop: 0,
                ) +
                labelSize,
          ),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.black12, width: 0.5),
            ),
          ),
          width: screenSize.width,
          child: !isBigScreen(context)
              ? SizedBox(
                  child: _buildTabBar(),
                  width: MediaQuery.of(context).size.width,
                )
              : Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Spacer(),
                      Expanded(
                        flex: 6,
                        child: _buildTabBar(),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    var totalCart = Provider.of<CartModel>(context).totalCartQuantity;

    final colorIcon = appSetting['TabBarIconColor'] != null
        ? HexColor(appSetting['TabBarIconColor'])
        : Theme.of(context).accentColor;

    final activeColorIcon = appSetting['ActiveTabBarIconColor'] != null
        ? HexColor(appSetting['ActiveTabBarIconColor'])
        : Theme.of(context).primaryColor;

    Widget buildTab(item) {
      Widget icon = Builder(
        builder: (ctx) {
          return !item['icon'].contains('/')
              ? Icon(
                  featherIcons[item['icon']],
                  color: IconTheme.of(ctx).color,
                  size: 22,
                )
              : FluxImage(
                  imageUrl: item['icon'],
                  color: IconTheme.of(ctx).color,
                  width: 24,
                );
        },
      );

      if (item['layout'] == 'cart') {
        icon = Stack(
          children: <Widget>[
            Container(
              width: 30,
              height: 25,
              padding: const EdgeInsets.only(right: 6.0, top: 4),
              child: icon,
            ),
            if (totalCart > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    totalCart.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isDesktopDisplay ? 14 : 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
          ],
        );
      }

      return Tab(
        text: item['label'],
        iconMargin: EdgeInsets.zero,
        icon: icon,
      );
    }

    return TabBar(
      controller: tabController,
      onTap: (index) {
        if (currentIndex == index) {
          navigators[tabController.index]
              .currentState
              .popUntil((r) => r.isFirst);
        }
        currentIndex = index;
        Future.delayed(
          const Duration(milliseconds: 200),
          () => Utils.changeStatusBarColor(
              Provider.of<AppModel>(context, listen: false).themeMode),
        );
        if (!kIsWeb) {
          final flutterWebViewPlugin = FlutterWebviewPlugin();
          if ('cart' == tabData[index]['layout']) {
            flutterWebViewPlugin.show();
          } else {
            flutterWebViewPlugin.hide();
          }
        }
      },
      tabs: tabData.map(buildTab).toList(),
      isScrollable: false,
      labelColor: activeColorIcon,
      unselectedLabelColor: colorIcon,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorColor:
          colorTabBar == null ? Theme.of(context).primaryColor : Colors.white,
    );
  }

  void _changeTab(String nameTab) {
    if (saveIndexTab[nameTab] != null) {
      tabController?.animateTo(saveIndexTab[nameTab]);
    } else {
      Navigator.of(App.fluxStoreNavigatorKey.currentContext)
          .pushNamed('/$nameTab');
    }
  }

  void _loadTabBar(context) {
    for (var i = 0; i < tabData.length; i++) {
      var _dataOfTab = Map<String, dynamic>.from(tabData[i]);
      saveIndexTab[_dataOfTab['layout']] = i;
      navigators[i] = GlobalKey<NavigatorState>();
      _tabView.add(Navigator(
        key: navigators[i],
        onGenerateRoute: (RouteSettings settings) {
          if (settings.name == Navigator.defaultRouteName) {
            return MaterialPageRoute(
              builder: (context) => tabView(_dataOfTab),
              settings: settings,
            );
          }
          return Routes.getRouteGenerate(settings);
        },
      ));
    }
    setState(() {
      tabController = TabController(length: _tabView.length, vsync: this);
    });

    if (MainTabControlDelegate.getInstance().index != null) {
      tabController.animateTo(MainTabControlDelegate.getInstance().index);
    } else {
      MainTabControlDelegate.getInstance().index = 0;
    }

    // Load the Design from FluxBuilder
    tabController.addListener(() {
      eventBus.fire('tab_${tabController.index}');
      MainTabControlDelegate.getInstance().index = tabController.index;
    });
  }

  void _setupListenEvent() {
    _subOpenNativeDrawer = eventBus.on<EventOpenNativeDrawer>().listen((event) {
      if (!_scaffoldKey.currentState.isDrawerOpen) {
        _scaffoldKey.currentState.openDrawer();
      }
    });
    _subCloseNativeDrawer =
        eventBus.on<EventCloseNativeDrawer>().listen((event) {
      if (_scaffoldKey.currentState.isDrawerOpen) {
        _scaffoldKey.currentState.openEndDrawer();
      }
    });
    _subOpenCustomDrawer = eventBus.on<EventOpenCustomDrawer>().listen((event) {
      setState(() {
        isShowCustomDrawer = true;
      });
    });
    _subCloseCustomDrawer =
        eventBus.on<EventCloseCustomDrawer>().listen((event) {
      setState(() {
        isShowCustomDrawer = false;
      });
    });
  }

  Future<bool> _handleWillPopScopeRoot() {
    // Check pop navigator current tab
    final currentNavigator = navigators[tabController.index];
    if (currentNavigator.currentState.canPop()) {
      currentNavigator.currentState.pop();
      return Future.value(false);
    }
    // Check pop root navigator
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return Future.value(false);
    }
    if (tabController.index != 0) {
      tabController.animateTo(0);
      return Future.value(false);
    } else {
      return showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(S.of(context).areYouSure),
              content: Text(S.of(context).doYouWantToExitApp),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(S.of(context).no),
                ),
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(S.of(context).yes),
                ),
              ],
            ),
          ) ??
          false;
    }
  }

  Future<void> _getCurrentUser() async {
    try {
      //Provider.of<UserModel>(context).getUser();
      final user = await _auth.currentUser;
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
      }
    } catch (e) {
      printLog('[tabbar] getCurrentUser error ${e.toString()}');
    }
  }
}
