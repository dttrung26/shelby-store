import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'common/config.dart';
import 'common/constants.dart';
import 'generated/l10n.dart';
import 'models/app_model.dart';
import 'models/category_model.dart';
import 'models/entities/category.dart';
import 'models/product_model.dart';
import 'models/user_model.dart';
import 'services/service_config.dart';
import 'tabbar.dart';
import 'widgets/layout/adaptive.dart';

class MenuBar extends StatefulWidget {
  MenuBar();

  @override
  _MenuBarState createState() => _MenuBarState();
}

class _MenuBarState extends State<MenuBar> {
  void pushNavigation(String name) {
    eventBus.fire(const EventCloseNativeDrawer());
    return MainTabControlDelegate.getInstance()
        .changeTab(name.replaceFirst('/', ''));
  }

  @override
  Widget build(BuildContext context) {
    printLog('[MenuBar] build');
    var drawer = Provider.of<AppModel>(context, listen: false).drawer;

    return Column(
      key: drawer['key'] != null ? Key(drawer['key']) : null,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 50),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (drawer['logo'] != null)
                    Container(
                      height: 38,
                      margin:
                          const EdgeInsets.only(bottom: 10, top: 10, left: 5),
                      child: imageContainer(drawer['logo']),
                    ),
                  const Divider(),
                  ...List.generate(drawer['items'].length, (index) {
                    return drawerItem(drawer['items'][index]);
                  }),
                  isDisplayDesktop(context)
                      ? const SizedBox(height: 300)
                      : const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget imageContainer(String link) {
    if (link.contains('http://') || link.contains('https://')) {
      return Image.network(
        link,
        fit: BoxFit.cover,
      );
    }
    return Image.asset(
      link,
      fit: BoxFit.cover,
    );
  }

  Widget drawerItem(item) {
    // final isTablet = Tools.isTablet(MediaQuery.of(context));

    if (item['show'] == false) return const SizedBox();

    final isListing = Config().isListingType;

    switch (item['type']) {
      case 'home':
        {
          return ListTile(
            leading: Icon(
              isListing ? Icons.home : Icons.shopping_basket,
              size: 20,
            ),
            title: Text(
              isListing ? S.of(context).home : S.of(context).shop,
            ),
            onTap: () {
              pushNavigation(RouteList.home);
            },
          );
        }
      case 'categories':
        {
          return ListTile(
            leading: const Icon(Icons.category, size: 20),
            title: Text(S.of(context).categories),
            onTap: () => pushNavigation(
                Provider.of<AppModel>(context, listen: false).vendorType ==
                        VendorType.single
                    ? RouteList.category
                    : RouteList.vendorCategory),
          );
        }
      case 'cart':
        {
          if (Config().isListingType) {
            return Container();
          }
          return ListTile(
            leading: const Icon(Icons.shopping_cart, size: 20),
            title: Text(S.of(context).cart),
            onTap: () => pushNavigation(RouteList.cart),
          );
        }
      case 'profile':
        {
          return ListTile(
            leading: const Icon(Icons.person, size: 20),
            title: Text(S.of(context).settings),
            onTap: () => pushNavigation(RouteList.profile),
          );
        }
      case 'web':
        {
          return kIsWeb || isDisplayDesktop(context)
              ? Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.list,
                        size: 20,
                      ),
                      title: Text(S.of(context).category),
                      onTap: () {
                        pushNavigation(RouteList.category);
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.search,
                        size: 20,
                      ),
                      title: Text(S.of(context).search),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings, size: 20),
                      title: Text(S.of(context).settings),
                      onTap: () {
                        if (kIsWeb) {
                        } else {
                          Navigator.of(context).pushNamed(RouteList.profile);
                        }
                      },
                    )
                  ],
                )
              : const SizedBox();
        }
      case 'blog':
        {
          return ListTile(
            leading: const Icon(FontAwesomeIcons.wordpress, size: 20),
            title: Text(S.of(context).blog),
            onTap: () => pushNavigation(RouteList.blogs),
          );
        }
      case 'login':
        {
          return ListenableProvider.value(
            value: Provider.of<UserModel>(context, listen: false),
            child: Consumer<UserModel>(builder: (context, userModel, _) {
              final loggedIn = userModel.loggedIn;
              return ListTile(
                leading: const Icon(Icons.exit_to_app, size: 20),
                title: loggedIn
                    ? Text(S.of(context).logout)
                    : Text(S.of(context).login),
                onTap: () {
                  if (loggedIn) {
                    Provider.of<UserModel>(context, listen: false).logout();
                    if (kLoginSetting['IsRequiredLogin'] ?? false) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        RouteList.login,
                        (route) => false,
                      );
                    } else {
                      pushNavigation(RouteList.dashboard);
                    }
                  } else {
                    pushNavigation(RouteList.login);
                  }
                },
              );
            }),
          );
        }
      case 'category':
        {
          return buildListCategory();
        }
      default:
        return Container();
    }
  }

  Widget buildListCategory() {
    final categories = Provider.of<CategoryModel>(context).categories;
    var widgets = <Widget>[];

    if (categories != null) {
      var list = categories.where((item) => item.parent == '0').toList();
      for (var i = 0; i < list.length; i++) {
        final currentCategory = list[i];
        var childCategories =
            categories.where((o) => o.parent == currentCategory.id).toList();
        widgets.add(Container(
          color: i.isOdd
              ? Theme.of(context).backgroundColor
              : Theme.of(context).primaryColorLight,

          /// Check to add only parent link category
          child: childCategories.isEmpty
              ? InkWell(
                  onTap: () {
                    ProductModel.showList(
                      context: context,
                      cateId: currentCategory.id,
                      cateName: currentCategory.name,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 20,
                      bottom: 12,
                      left: 16,
                      top: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(currentCategory.name.toUpperCase())),
                        const SizedBox(width: 24),
                        currentCategory.totalProduct == null
                            ? const Icon(Icons.chevron_right)
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  S
                                      .of(context)
                                      .nItems(currentCategory.totalProduct),
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                )
              : ExpansionTile(
                  title: Padding(
                    padding: const EdgeInsets.only(left: 0.0, top: 0),
                    child: Text(
                      currentCategory.name.toUpperCase(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  children:
                      getChildren(categories, currentCategory, childCategories),
                ),
        ));
      }
    }

    return ExpansionTile(
      initiallyExpanded: true,
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      tilePadding: const EdgeInsets.only(left: 16, right: 8),
      title: Text(
        S.of(context).byCategory.toUpperCase(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).accentColor.withOpacity(0.5),
        ),
      ),
      children: widgets,
    );
  }

  List getChildren(List<Category> categories, Category currentCategory,
      List<Category> childCategories,
      {double paddingOffset = 0.0}) {
    var list = <Widget>[];

    list.add(
      ListTile(
        leading: Padding(
          child: Text(S.of(context).seeAll),
          padding: EdgeInsets.only(left: 20 + paddingOffset),
        ),
        trailing: Text(
          S.of(context).nItems(currentCategory.totalProduct),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 12,
          ),
        ),
        onTap: () {
          ProductModel.showList(
            context: context,
            cateId: currentCategory.id,
            cateName: currentCategory.name,
          );
        },
      ),
    );
    for (var i in childCategories) {
      var newChildren = categories.where((cat) => cat.parent == i.id).toList();
      if (newChildren.isNotEmpty) {
        list.add(
          ExpansionTile(
            title: Padding(
              padding: EdgeInsets.only(left: 20.0 + paddingOffset),
              child: Text(
                i.name.toUpperCase(),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            children: getChildren(
              categories,
              i,
              newChildren,
              paddingOffset: paddingOffset + 10,
            ),
          ),
        );
      } else {
        list.add(
          ListTile(
            leading: Padding(
              child: Text(i.name),
              padding: EdgeInsets.only(left: 20 + paddingOffset),
            ),
            trailing: Text(
              S.of(context).nItems(i.totalProduct),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 12,
              ),
            ),
            onTap: () {
              ProductModel.showList(
                  context: context, cateId: i.id, cateName: i.name);
            },
          ),
        );
      }
    }
    return list;
  }
}
