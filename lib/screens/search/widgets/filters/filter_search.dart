import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../generated/l10n.dart';
import '../../../../models/entities/listing_location.dart';
import '../../../../models/index.dart'
    show
        Category,
        CategoryModel,
        FilterAttributeModel,
        FilterTag,
        FilterTagModel,
        SearchModel,
        SubAttribute;
import '../../../../models/listing/listing_location_model.dart';
import '../../../../screens/base.dart';
import '../../../../services/service_config.dart';
import 'filter_search_attributes.dart';
import 'filter_search_category.dart';
import 'filter_search_listing_location.dart';
import 'filter_search_tags.dart';

class FilterSearch extends StatefulWidget {
  final Function(Map<String, List>) onChange;

  FilterSearch({
    this.onChange,
    Key key,
  }) : super(key: key);

  @override
  _FilterSearchState createState() => _FilterSearchState();
}

class _FilterSearchState extends BaseScreen<FilterSearch> {
  final Map<String, List> _listResult = {};

//  final StreamController<double> _streamLocal = StreamController.broadcast();
  final _heightPopup = 500.0;
  String _slugAttribute = '';
  Timer _debounce;

  List<ListingLocation> listingLocations = [];

  List<FilterTag> get _listTag {
    if (_listResult['tags'] == null) _listResult['tags'] = const <FilterTag>[];
    return _listResult['tags'];
  }

  set _listTag(value) => _listResult['tags'] = value;

  List<Category> get _listCategory {
    if (_listResult['categories'] == null) {
      _listResult['categories'] = const <Category>[];
    }
    return _listResult['categories'];
  }

  set _listCategory(value) => _listResult['categories'] = value;

  List<SubAttribute> get _listAttribute {
    if (_listResult[_slugAttribute] == null) {
      _listResult[_slugAttribute] = const <SubAttribute>[];
    }
    return _listResult[_slugAttribute];
  }

  set _listAttribute(value) => _listResult[_slugAttribute] = value;

  @override
  void initState() {
    super.initState();
//    initDataFilter();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _slugAttribute = Provider.of<FilterAttributeModel>(context, listen: false)
            ?.lstProductAttribute
            ?.first
            ?.slug ??
        '';
  }

  @override
  void dispose() {
    //_streamLocal.close();
    super.dispose();
  }

  void initDataFilter() {
    _initTag();
    _initCategory();
    _initSubAttribute();
    _initListingLocation();
  }

  void _initListingLocation() {
    listingLocations =
        Provider.of<ListingLocationModel>(context, listen: false).locations;
  }

  void _initTag() {
    final tagID = Provider.of<SearchModel>(context, listen: false).tag;
    final listTag = Provider.of<FilterTagModel>(context, listen: false);
    if (listTag?.lstProductTag == null) {
      return;
    }
    _listTag = listTag.lstProductTag
        .where((element) => element.id.toString() == tagID)
        .toList();
  }

  void _initCategory() {
    final categoryID =
        Provider.of<SearchModel>(context, listen: false).category;
    final listCategory = Provider.of<CategoryModel>(context, listen: false);

    if (listCategory?.categories == null) {
      return;
    }

    _listCategory = listCategory.categories
        .where((element) => element.id.toString() == categoryID)
        .toList();
  }

  void _initSubAttribute() {
    final searchModel = Provider.of<SearchModel>(context, listen: false);
    if (searchModel.attribute.isNotEmpty) {
      _slugAttribute = searchModel.attribute;
    }
    final subAttribute = searchModel.attribute_term;
    final listSubAttribute =
        Provider.of<FilterAttributeModel>(context, listen: false);
    if (listSubAttribute.lstCurrentAttr == null) {
      return;
    }
    _listAttribute = listSubAttribute.lstCurrentAttr
        .where((element) => element.id.toString() == subAttribute)
        .toList();
  }

  void onChange() {
    if (_debounce?.isActive ?? false) {
      _debounce.cancel();
    }
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => widget.onChange?.call(_listResult),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: <Widget>[
//        Padding(
//          padding: const EdgeInsets.only(left: 10, top: 15, right: 5),
//          child: Text(
//            S.of(context).all,
//            style: TextStyle(
//              fontSize: 13,
//            ),
//          ),
//        ),
        FlatButton.icon(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          color: Theme.of(context).primaryColorLight,
          onPressed: _showFilter,
          icon: Icon(
            Icons.add,
            color: Theme.of(context).accentColor,
            size: 15,
          ),
          label: Text(
            S.of(context).filter,
            style: TextStyle(
              color: Theme.of(context).accentColor,
            ),
          ),
        ),
        if (_listTag.isNotEmpty) ...[
          const SizedBox(width: 6),
          ..._renderWidgetFilter(_listTag, isTag: true),
        ],
        if (_listCategory.isNotEmpty) ...[
          const SizedBox(width: 6),
          ..._renderWidgetFilter(_listCategory),
        ],
        if (listingLocations.isNotEmpty) ...[
          const SizedBox(width: 6),
          ..._renderWidgetFilter(listingLocations),
        ],
        if (_listAttribute.isNotEmpty) ...[
          const SizedBox(width: 6),
          ..._renderWidgetFilter(_listAttribute),
        ]
      ],
    );
  }

  List<Widget> _renderWidgetFilter(List listItem, {bool isTag = false}) {
    final tabLabel = isTag ? '#' : '';
    var _list = List<Widget>.generate(
      listItem.length,
      (int index) {
        return FlatButton(
          color: Theme.of(context).primaryColorLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onPressed: () {
            listItem.removeAt(index);
            onChange();
            setState(() {});
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '$tabLabel${listItem[index].name}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.cancel,
                color: Theme.of(context).primaryColor,
                size: 15,
              )
            ],
          ),
        );
      },
    );
    return _list.isNotEmpty ? _list : [];
  }

  Widget _renderContent(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: _heightPopup,
        padding: const EdgeInsets.symmetric(vertical: 15),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          boxShadow: kElevationToShadow[12],
          color: Theme.of(context).backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Container(
          color: Theme.of(context).backgroundColor,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FilterSearchTags(
                  onSelect: (tag, currentSlug) {
                    if (tag.isEmpty) {
                      _listResult.remove('tags');
                      return;
                    }
                    _listTag = tag;
                    setState(() {});
                  },
                  listSelected: _listTag,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 25,
                    bottom: 10,
                    left: 30,
                  ),
                  child: Text(
                    S.of(context).categories,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                FilterSearchCategory(
                  onSelect: (category, currentSlug) {
                    if (category.isEmpty) {
                      _listResult.remove('categories');
                      setState(() {});
                      return;
                    }
                    _listCategory = category;
                    setState(() {});
                  },
                  listSelected: _listCategory,
                ),
                if (Config().isListingType) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 25,
                      bottom: 10,
                      left: 30,
                    ),
                    child: Text(
                      S.of(context).location,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  FilterSearchListingLocation(
                    onSelect: (listingLocations, currentSlug) {
                      if (listingLocations.isEmpty) {
                        _listResult.remove('listingLocation');
                        return;
                      }
                      this.listingLocations = listingLocations;
                      _listResult['listingLocation'] = this.listingLocations;
                      setState(() {});
                    },
                    listSelected: listingLocations,
                  ),
                ],
                FilterSearchAttributes(
                  listSelected: _listAttribute,
                  slug: _slugAttribute,
                  onSelect: (attributes, currentSlug) {
                    if (attributes.isEmpty) {
                      _listResult.remove(_slugAttribute);
                      setState(() {});
                      return;
                    }
                    _slugAttribute = currentSlug;
                    _listAttribute = attributes;
                    _listResult.removeWhere((key, value) =>
                        !key.contains('categories') &&
                        !key.contains('tags') &&
                        key != currentSlug);
                    if (mounted) {
                      setState(() {});
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );

//    return GestureDetector(onPanStart: (DragStartDetails details) {
//      _initial = details.globalPosition.dy;
//    }, onPanUpdate: (DragUpdateDetails details) {
//      _currentDy = details.globalPosition.dy - _initial;
//      _streamLocal?.add(getPosition);
//    }, onPanEnd: (DragEndDetails details) {
//      if (getPosition < 0.4) {
//        Navigator.pop(context);
//      } else {
//        _streamLocal?.add(1);
//      }
//    }, child: Builder(
//      builder: (context) {
//        return Align(
//          alignment: Alignment.bottomCenter,
//          child: Container(
//            height: _heightPopup,
//            padding: const EdgeInsets.symmetric(vertical: 15),
//            width: MediaQuery.of(context).size.width,
//            decoration: BoxDecoration(
//              boxShadow: kElevationToShadow[12],
//              color: Theme.of(context).backgroundColor,
//              borderRadius: const BorderRadius.only(
//                topLeft: Radius.circular(20.0),
//                topRight: Radius.circular(20.0),
//              ),
//            ),
//            child: Material(
//              child: Container(
//                color: Theme.of(context).backgroundColor,
//                child: SingleChildScrollView(
//                  child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: <Widget>[
//                      FilterSearchTags(
//                        onSelect: (tag, currentSlug) {
//                          if (tag.isEmpty) {
//                            _listResult.remove('tags');
//                            return;
//                          }
//                          _listTag = tag;
//                          setState(() {});
//                        },
//                        listSelected: _listTag,
//                      ),
//                      Padding(
//                        padding: const EdgeInsets.only(
//                          top: 25,
//                          bottom: 10,
//                          left: 30,
//                        ),
//                        child: Text(
//                          S.of(context).categories,
//                          style: const TextStyle(
//                            fontWeight: FontWeight.bold,
//                            fontSize: 18,
//                          ),
//                        ),
//                      ),
//                      FilterSearchCategory(
//                        onSelect: (category, currentSlug) {
//                          if (category.isEmpty) {
//                            _listResult.remove('categories');
//                            return;
//                          }
//                          _listCategory = category;
//                          setState(() {});
//                        },
//                        listSelected: _listCategory,
//                      ),
//                      FilterSearchAttributes(
//                        listSelected: _listAttribute,
//                        slug: _slugAttribute,
//                        onSelect: (attributes, currentSlug) {
//                          if (attributes.isEmpty) {
//                            _listResult.remove(_slugAttribute);
//                            return;
//                          }
//                          _listAttribute = attributes;
//                          _slugAttribute = currentSlug;
//                          _listResult.removeWhere((key, value) =>
//                              !key.contains('categories') &&
//                              !key.contains('tags') &&
//                              !key.contains('$currentSlug'));
//                          if (mounted) {
//                            setState(() {});
//                          }
//                        },
//                      )
//                    ],
//                  ),
//                ),
//              ),
//            ),
//          ),
//        );
//      },
//    ));
  }

  void _showFilter() async {
    await showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topRight: Radius.circular(10.0),
          topLeft: Radius.circular(10.0),
        )),
        context: (context),
        builder: (_) => _renderContent(context));

//    await showGeneralDialog(
//      useRootNavigator: false,
//      transitionBuilder: (context, a1, a2, widget) {
//        return StreamBuilder<double>(
//            stream: _streamLocal.stream,
//            initialData: null,
//            builder: (context, snapshot) {
//              double _vitri = snapshot.data ?? a1.value;
//              _vitri = _vitri < 0
//                  ? 0
//                  : _vitri > 1
//                      ? 1
//                      : _vitri;
//              final curvedValue = Curves.linear.transform(1 - _vitri);
//              return Transform(
//                transform:
//                    Matrix4.translationValues(0.0, curvedValue * 300, 0.0),
//                child: widget,
//              );
//            });
//      },
//      transitionDuration: const Duration(milliseconds: 200),
//      barrierDismissible: true,
//      barrierLabel: '',
//      context: context,
//      pageBuilder: (BuildContext context, Animation animation,
//          Animation secondaryAnimation) {
//        return _renderContent(context);
//      },
//    );
    // handle filter
    onChange();
  }
}
