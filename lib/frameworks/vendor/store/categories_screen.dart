import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';

import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart' show AppModel, Category, CategoryModel;
import '../../../routes/flux_navigate.dart';
import '../../../screens/index.dart'
    show
        CardCategories,
        ColumnCategories,
        GridCategory,
        SideMenuCategories,
        SideMenuSubCategories,
        SmartChat,
        SubCategories;
import '../../../widgets/cardlist/index.dart';
import 'store_screen.dart';

class VendorCategoriesScreen extends StatefulWidget {
  final String layout;
  final List<dynamic> categories;
  final List<dynamic> images;
  final bool showChat;

  VendorCategoriesScreen(
      {Key key = const Key('category'),
      this.layout,
      this.categories,
      this.images,
      this.showChat})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CategoriesScreenState();
  }
}

class CategoriesScreenState extends State<VendorCategoriesScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  final FocusNode _focus = FocusNode();
  String searchText;
  var textController = TextEditingController();

  Animation<double> animation;
  AnimationController controller;
  bool _isSelectedCategoriesTab = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    animation = Tween<double>(begin: 0, end: 60).animate(controller);
    animation.addListener(() {
      setState(() {});
    });

    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focus.hasFocus && animation.value == 0) {
      controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final category = Provider.of<CategoryModel>(context);
    final showChat = widget.showChat ?? false;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 8),
        child: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0,
          centerTitle: true,
          title: FittedBox(
            fit: BoxFit.cover,
            child: Container(
              width: 250,
              child: CupertinoSlidingSegmentedControl<int>(
                backgroundColor: Theme.of(context).primaryColorLight,
                thumbColor: Theme.of(context).backgroundColor,
                children: {
                  0: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      S.of(context).stores.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  1: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      S.of(context).categories.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                },
                onValueChanged: (value) {
                  setState(() {
                    _isSelectedCategoriesTab = value == 1;
                  });
                },
                groupValue: _isSelectedCategoriesTab ? 1 : 0,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () async {
                  var location = Location();

                  /// ask location permission
                  var isGranted = await location.hasPermission();
                  if (!isGranted) {
                    isGranted = await location.requestPermission();
                    if (!isGranted) {
                      return;
                    }
                  }

                  /// ask location service
                  isGranted = await location.serviceEnabled();
                  if (!isGranted) {
                    isGranted = await location.requestService();
                    if (!isGranted) {
                      return;
                    }
                  }

                  unawaited(FluxNavigate.pushNamed(RouteList.map));
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Icon(
                    Icons.place,
                    size: 26,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
      body: Center(
        child: ListenableProvider.value(
          value: category,
          child: Consumer<CategoryModel>(builder: (context, value, child) {
            if (value.isLoading) {
              return kLoadingWidget(context);
            }

            if (value.categories == null && _isSelectedCategoriesTab) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                child: Text(S.of(context).dataEmpty),
              );
            }

            var categories = value.categories;
            return [
              GridCategory.type,
              ColumnCategories.type,
              SideMenuCategories.type,
              SubCategories.type,
              SideMenuSubCategories.type
            ].contains(widget.layout)
                ? Column(
                    children: <Widget>[
                      Expanded(
                        child: _isSelectedCategoriesTab
                            ? renderCategories(categories)
                            : StoreScreen(),
                      )
                    ],
                  )
                : !_isSelectedCategoriesTab
                    ? StoreScreen()
                    : ListView(
                        children: <Widget>[renderCategories(categories)],
                      );
          }),
        ),
      ),
    );
  }

  Widget renderCategories(List<Category> categories) {
    switch (widget.layout) {
      case CardCategories.type:
        return CardCategories(categories);
      case ColumnCategories.type:
        return ColumnCategories(categories);
      case SubCategories.type:
        return SubCategories(categories);
      case SideMenuCategories.type:
        return SideMenuCategories(categories);
      case SideMenuSubCategories.type:
        return SideMenuSubCategories(categories);
      case HorizonMenu.type:
        return HorizonMenu(categories);
      case GridCategory.type:
        return GridCategory(categories);
      default:
        return HorizonMenu(categories);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _focus.dispose();
    super.dispose();
  }
}
