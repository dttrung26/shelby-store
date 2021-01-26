import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/entities/listing_location.dart';
import '../../models/index.dart'
    show
        AppModel,
        Category,
        TagModel,
        CategoryModel,
        FilterAttributeModel,
        ProductModel;
import '../../models/listing/listing_location_model.dart';
import '../../services/service_config.dart';
import '../common/tree_view.dart';
import '../layout/adaptive.dart';
import 'category_item.dart';
import 'filter_option_item.dart';
import 'location_item.dart';

class BackdropMenu extends StatefulWidget {
  final Function onFilter;
  final String categoryId;
  final String tagId;
  final String listingLocationId;

  const BackdropMenu({
    Key key,
    this.onFilter,
    this.categoryId,
    this.tagId,
    this.listingLocationId,
  }) : super(key: key);

  @override
  _BackdropMenuState createState() => _BackdropMenuState();
}

class _BackdropMenuState extends State<BackdropMenu> {
  double mixPrice = 0.0;
  double maxPrice = kMaxPriceFilter / 2;
  String categoryId = '-1';
  String tagId = '-1';
  String currentSlug;
  String listingLocationId;
  int currentSelectedAttr = -1;

  @override
  void initState() {
    super.initState();
    categoryId = widget.categoryId;
    tagId = widget.tagId;
    listingLocationId = widget.listingLocationId;
  }

  @override
  Widget build(BuildContext context) {
    final category = Provider.of<CategoryModel>(context);
    final tag = Provider.of<TagModel>(context);
    final selectLayout = Provider.of<AppModel>(context).productListLayout;
    final currency = Provider.of<AppModel>(context).currency;
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    final filterAttr = Provider.of<FilterAttributeModel>(context);

    List<ListingLocation> locations;
    if (Config().isListingType && Config().typeName != 'mylisting') {
      locations =
          Provider.of<ListingLocationModel>(context, listen: false).locations;
      listingLocationId = Provider.of<ProductModel>(context).listingLocationId;
    }
    categoryId = Provider.of<ProductModel>(context).categoryId;

    Function _onFilter =
        (categoryId, tagId, {listingLocationId}) => widget.onFilter(
              minPrice: mixPrice,
              maxPrice: maxPrice,
              categoryId: categoryId,
              tagId: tagId,
              attribute: currentSlug,
              currentSelectedTerms: filterAttr.lstCurrentSelectedTerms,
              listingLocationId: listingLocationId ?? this.listingLocationId,
            );

    return ListenableProvider.value(
      value: category,
      child: Consumer<CategoryModel>(
        builder: (context, catModel, _) {
          if (catModel.isLoading) {
            printLog('Loading');
            return Center(child: Container(child: kLoadingWidget(context)));
          }

          if (catModel.categories != null) {
            final categories = catModel.categories
                .where((item) => item.parent == '0')
                .toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  isDisplayDesktop(context)
                      ? SizedBox(
                          height: 100,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              const SizedBox(width: 20),
                              GestureDetector(
                                child: const Icon(Icons.arrow_back_ios,
                                    size: 22, color: Colors.white70),
                                onTap: () {
                                  if (isDisplayDesktop(context)) {
                                    eventBus
                                        .fire(const EventOpenCustomDrawer());
                                  }
                                  Navigator.of(context).pop();
                                },
                              ),
                              const SizedBox(width: 20),
                              Text(
                                S.of(context).products,
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      S.of(context).layout.toUpperCase(),
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Wrap(
                    children: <Widget>[
                      const SizedBox(width: 8),
                      for (var item in kProductListLayout)
                        Tooltip(
                          message: item['layout'],
                          child: GestureDetector(
                            onTap: () =>
                                Provider.of<AppModel>(context, listen: false)
                                    .updateProductListLayout(item['layout']),
                            child: Container(
                              width: 50,
                              height: 46,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Image.asset(
                                  item['image'],
                                  color: selectLayout == item['layout']
                                      ? Theme.of(context).accentColor
                                      : Colors.white.withOpacity(0.3),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: selectLayout == item['layout']
                                      ? Theme.of(context).backgroundColor
                                      : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(9.0)),
                            ),
                          ),
                        )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 30),
                    child: Text(
                      S.of(context).byCategory.toUpperCase(),
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                      decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(3.0)),
                      child: TreeView(
                        parentList: [
                          for (var item in categories)
                            Parent(
                              parent: CategoryItem(
                                item,
                                hasChild:
                                    hasChildren(catModel.categories, item.id),
                                isSelected: item.id == categoryId,
                                onTap: (category) => _onFilter(category, tagId),
                              ),
                              childList: ChildList(
                                children: [
                                  Parent(
                                    parent: CategoryItem(
                                      item,
                                      isLast: true,
                                      isParent: true,
                                      isSelected: item.id == categoryId,
                                      onTap: (category) =>
                                          _onFilter(category, tagId),
                                    ),
                                    childList: ChildList(
                                      children: const [],
                                    ),
                                  ),
                                  for (var category in getSubCategories(
                                      catModel.categories, item.id))
                                    Parent(
                                        parent: CategoryItem(
                                          category,
                                          isLast: true,
                                          isSelected: category.id == categoryId,
                                          onTap: (category) =>
                                              _onFilter(category, tagId),
                                        ),
                                        childList: ChildList(
                                          children: const [],
                                        ))
                                ],
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                  if (Config().isListingType)
                    Padding(
                      padding: const EdgeInsets.only(left: 15, top: 30),
                      child: Text(
                        S.of(context).location.toUpperCase(),
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  if (Config().isListingType)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: Container(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                        decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(3.0)),
                        child: Column(
                          children: List.generate(
                            locations.length,
                            (index) => LocationItem(
                              locations[index],
                              isSelected:
                                  locations[index].id == listingLocationId,
                              onTap: () {
                                _onFilter(categoryId, tagId,
                                    listingLocationId: locations[index].id);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (!Config().isListingType) ...[
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        S.of(context).byPrice.toUpperCase(),
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          Tools.getCurrencyFormatted(mixPrice, currencyRate,
                              currency: currency),
                          style: Theme.of(context).textTheme.headline6.copyWith(
                                color: Colors.white,
                              ),
                        ),
                        const Text(
                          ' - ',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Text(
                          Tools.getCurrencyFormatted(maxPrice, currencyRate,
                              currency: currency),
                          style: Theme.of(context).textTheme.headline6.copyWith(
                                color: Colors.white,
                              ),
                        )
                      ],
                    ),
                    SliderTheme(
                      data: const SliderThemeData(
                        activeTrackColor: Color(kSliderActiveColor),
                        inactiveTrackColor: Color(kSliderInactiveColor),
                        activeTickMarkColor: Colors.white70,
                        inactiveTickMarkColor: Colors.white,
                        overlayColor: Colors.white12,
                        thumbColor: Color(kSliderActiveColor),
                        showValueIndicator: ShowValueIndicator.always,
                      ),
                      child: RangeSlider(
                        min: 0.0,
                        max: kMaxPriceFilter,
                        divisions: kFilterDivision,
                        values: RangeValues(mixPrice, maxPrice),
                        onChanged: (RangeValues values) {
                          setState(() {
                            mixPrice = values.start;
                            maxPrice = values.end;
                          });
                        },
                      ),
                    ),
                    ListenableProvider.value(
                      value: filterAttr,
                      child: Consumer<FilterAttributeModel>(
                        builder: (context, value, child) {
                          if (value.lstProductAttribute != null) {
                            var list = List<Widget>.generate(
                              value.lstProductAttribute.length,
                              (index) {
                                return FilterOptionItem(
                                  enabled: !value.isLoading,
                                  onTap: () {
                                    currentSelectedAttr = index;

                                    currentSlug =
                                        value.lstProductAttribute[index].slug;
                                    value.getAttr(
                                        id: value
                                            .lstProductAttribute[index].id);
                                  },
                                  title: value.lstProductAttribute[index].name
                                      .toUpperCase(),
                                  isValid: currentSelectedAttr != -1,
                                  selected: currentSelectedAttr == index,
                                );
                              },
                            );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 30),
                                  child: Text(
                                    S.of(context).attributes.toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                    left: 10.0,
                                  ),
                                  constraints: const BoxConstraints(
                                    maxHeight: 200,
                                  ),
                                  child: GridView.count(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    crossAxisCount: 2,
                                    children: list,
                                  ),
                                ),
                                value.isLoading
                                    ? Center(
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            top: 10.0,
                                          ),
                                          width: 25.0,
                                          height: 25.0,
                                          child:
                                              const CircularProgressIndicator(
                                                  strokeWidth: 2.0),
                                        ),
                                      )
                                    : Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        child: currentSelectedAttr == -1
                                            ? Container()
                                            : Wrap(
                                                children: List.generate(
                                                  value.lstCurrentAttr.length,
                                                  (index) {
                                                    return Container(
                                                      margin: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 5),
                                                      child: FilterChip(
                                                        label: Text(value
                                                            .lstCurrentAttr[
                                                                index]
                                                            .name),
                                                        selected: value
                                                                .lstCurrentSelectedTerms[
                                                            index],
                                                        onSelected: (val) {
                                                          value
                                                              .updateAttributeSelectedItem(
                                                                  index, val);
                                                        },
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                      ),
                              ],
                            );
                          }
                          return Container();
                        },
                      ),
                    ),
                  ],
                ]
                  ..add(
                    ListenableProvider.value(
                      value: tag,
                      child: Consumer<TagModel>(
                        builder: (context, TagModel tagModel, _) {
                          if (tagModel.tagList?.isEmpty ?? true) {
                            return const SizedBox();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: tagModel.isLoading
                                ? [
                                    Center(
                                      child: Container(
                                        child: kLoadingWidget(context),
                                      ),
                                    )
                                  ]
                                : [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 15,
                                        top: 30,
                                      ),
                                      child: Text(
                                        S.of(context).byTag.toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(
                                        left: 10.0,
                                      ),
                                      constraints: const BoxConstraints(
                                        maxHeight: 200,
                                      ),
                                      child: GridView.count(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        crossAxisCount: 2,
                                        children: List.generate(
                                          tagModel.tagList?.length ?? 0,
                                          (index) {
                                            final selected = tagId ==
                                                tagModel.tagList[index].id
                                                    .toString();
                                            return FilterOptionItem(
                                              enabled: !tagModel.isLoading,
                                              selected: selected,
                                              isValid: tagId != '-1',
                                              title: tagModel
                                                  .tagList[index].name
                                                  .toUpperCase(),
                                              onTap: () {
                                                setState(() {
                                                  if (selected) {
                                                    tagId = null;
                                                  } else {
                                                    tagId = tagModel
                                                        .tagList[index].id
                                                        .toString();
                                                  }
                                                });
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                          );
                        },
                      ),
                    ),
                  )
                  ..addAll([
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        top: 30,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ButtonTheme(
                              height: 50,
                              child: RaisedButton(
                                elevation: 0.0,
                                color: Colors.white70,
                                onPressed: () => _onFilter(categoryId, tagId),
                                child: Text(
                                  S.of(context).apply,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 70),
                  ]),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  bool hasChildren(categories, id) {
    return categories.where((o) => o.parent == id).toList().length > 0;
  }

  List<Category> getSubCategories(categories, id) {
    return categories.where((o) => o.parent == id).toList();
  }
}
