import 'package:flutter/material.dart';
import 'package:inspireui/inspireui.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show Category, ProductModel;

class SideMenuSubCategories extends StatefulWidget {
  static const String type = 'sideMenuWithSub';

  final List<Category> categories;
  final Map<String, dynamic> icons;

  SideMenuSubCategories(this.categories, {this.icons});

  @override
  State<StatefulWidget> createState() => SideMenuSubCategoriesState();
}

class SideMenuSubCategoriesState extends State<SideMenuSubCategories> {
  int selectedIndex = 0;

  List<Category> getSubCategories(id) {
    return widget.categories.where((o) => o.parent == id).toList();
  }

  Map<String, dynamic> getListIcons() {
    var icons = <String, dynamic>{};
    for (var cat in widget.categories) {
      if (cat.image != null && cat.image.isNotEmpty) {
        icons[cat.id] = cat.image;
      }
    }
    return Map<String, dynamic>.from(icons);
  }

  List<Category> getListCategories() {
    var categories = <Category>[];
    for (var cat in widget.categories) {
      if (cat.parent == '0') {
        categories.add(cat);
      }
    }
    return categories;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.categories == null) {
      return Container(
        child: kLoadingWidget(context),
      );
    }

    var _categories = getListCategories();
    var _icons = getListIcons();

    if (_categories.isEmpty) {
      return const SizedBox();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: ListView.builder(
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: selectedIndex == index
                        ? theme.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 4.0,
                      left: 6,
                    ),
                    child: AnimatedDefaultTextStyle(
                      style: selectedIndex == index
                          ? TextStyle(
                              fontSize: 11,
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w600,
                            )
                          : TextStyle(
                              fontSize: 11,
                              color: theme.accentColor,
                            ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      duration: const Duration(milliseconds: 200),
                      child:
                          Text(_categories[index]?.name?.toUpperCase() ?? ''),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          flex: 7,
          child: GridSubCategory(
            getSubCategories(_categories[selectedIndex].id),
            parentCategory: _categories[selectedIndex],
            parentCategoryImage: kGridIconsCategories[
                    int.tryParse(_categories[selectedIndex].id) ?? -1] ??
                _icons[_categories[selectedIndex].id],
            icons: _icons,
          ),
        ),
      ],
    );
  }
}

class GridSubCategory extends StatefulWidget {
  final List<Category> categories;
  final Map<String, dynamic> icons;

  final Category parentCategory;
  final String parentCategoryImage;

  GridSubCategory(
    this.categories, {
    this.icons,
    this.parentCategory,
    this.parentCategoryImage,
  });

  @override
  _StateGridSubCategory createState() => _StateGridSubCategory();
}

class _StateGridSubCategory extends State<GridSubCategory> {
  @override
  Widget build(BuildContext context) {
    final categories = widget.categories;
    final icons = widget.icons;

    if (categories == null) {
      return Container(
        child: kLoadingWidget(context),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: List<Widget>.generate(
                categories.length,
                (i) {
                  final catId = int.tryParse(categories[i].id) ?? -1;
                  final String icon =
                      kGridIconsCategories[catId] ?? icons[categories[i].id];
                  final gridSize = (constraints.maxWidth - 16.0) /
                          kAdvanceConfig['GridCount'] -
                      8 * kAdvanceConfig['GridCount'];
                  return GestureDetector(
                    child: Container(
                      width: gridSize,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                width: gridSize,
                                height: gridSize,
                                child: _CategoryIcon(icon),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              categories[i].name.toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  .apply(fontSizeFactor: 0.9),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      ProductModel.showList(
                          context: context,
                          cateId: categories[i].id,
                          cateName: categories[i].name);
                    },
                  );
                },
              )..insertAll(
                  0,
                  [
                    if (widget.parentCategoryImage != null &&
                        widget.parentCategoryImage.isNotEmpty)
                      GestureDetector(
                        onTap: _seeAllProduct,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 150.0,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12.0)),
                                  child: _CategoryIcon(
                                    widget.parentCategoryImage,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if ((widget.parentCategoryImage != null &&
                            widget.parentCategoryImage.isNotEmpty) &&
                        (categories?.isEmpty ?? true))
                      Container(
                        margin: const EdgeInsets.only(top: 8.0),
                        padding: const EdgeInsets.all(4.0),
                        alignment: Alignment.centerRight,
                        child: InkResponse(
                          onTap: _seeAllProduct,
                          child: Text(
                            S.of(context).seeAll,
                            style: TextStyle(
                              fontSize: kIsWeb ? 18 : 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    if ((widget.parentCategoryImage == null ||
                            widget.parentCategoryImage.isEmpty) &&
                        (categories?.isEmpty ?? true))
                      Container(
                        height: constraints.maxHeight,
                        child: Center(
                          child: InkResponse(
                            onTap: _seeAllProduct,
                            child: Text(
                              S.of(context).seeAll,
                              style: TextStyle(
                                fontSize: kIsWeb ? 18 : 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ),
          ),
        );
      },
    );
  }

  void _seeAllProduct() {
    ProductModel.showList(
        context: context,
        cateId: widget.parentCategory.id,
        cateName: widget.parentCategory.name);
  }
}

class _CategoryIcon extends StatelessWidget {
  final String icon;
  final BoxFit fit;

  const _CategoryIcon(this.icon, {Key key, this.fit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return !icon.contains('/')
        ? Icon(
            featherIcons[icon],
            color: Theme.of(context).accentColor,
          )
        : (icon.contains('http')
            ? Image.network(icon, fit: fit)
            : Image.asset(icon, fit: fit));
  }
}
