import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../common/tools.dart';
import '../../../models/config/category_icon_config.dart';
import '../../../models/entities/category.dart';
import '../../../models/product_model.dart';
import 'category_icon.dart';

const _defaultSeparateWidth = 24.0;

const _paddingList = 24.0;

class CategoryIcons extends StatelessWidget {
  final config;
  final int crossAxisCount;
  final Map<String, Category> categoryList;

  CategoryIcons({
    this.config,
    this.categoryList,
    this.crossAxisCount = 5,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final listItemData = List.from(config['items']);
    var numberItemOnScreen = config['columns'] ?? crossAxisCount;
    numberItemOnScreen = getValueForScreenType(
      context: context,
      mobile: numberItemOnScreen,
      tablet: numberItemOnScreen + 3,
      desktop: numberItemOnScreen + 8,
    );
    var row = (listItemData.length.toDouble() / numberItemOnScreen).ceil();
    final size = Tools.formatDouble(config['size']) ?? 1.0;
    final widthItem = (MediaQuery.of(context).size.width -
            _paddingList -
            (_defaultSeparateWidth * (numberItemOnScreen))) /
        numberItemOnScreen *
        size;

    var items = <Widget>[];

    for (var item in config['items']) {
      final itemData = CategoryIconConfig.fromJson(item);
      final id = itemData.id.toString();
      items.add(CategoryIcon(
        onTap: () {
          ProductModel.showList(
            config: item,
            context: context,
            products: item['data'] ?? [],
          );
        },
        borderWidth: Tools.formatDouble(config['border']),
        originalColor: item['originalColor'] ?? false,
        radius: Tools.formatDouble(config['radius']) ?? 0,
        iconSize: widthItem,
        name: categoryList[id] != null ? categoryList[id].name : '',
        categoryIconConfig: itemData,
        noBackground: config['noBackground'],
      ));
    }

    if (config['wrap'] == false && items.isNotEmpty) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(
          left: _paddingList,
          right: _paddingList,
          bottom: 6,
          top: 12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.expand((element) {
            return [
              element,
              ScreenTypeLayout(
                mobile: const SizedBox(width: _defaultSeparateWidth),
                tablet: const SizedBox(width: _defaultSeparateWidth + 12),
                desktop: const SizedBox(width: _defaultSeparateWidth + 24),
              ),
            ];
          }).toList()
            ..removeLast(),
        ),
      );
    }

    return Container(
      color: Theme.of(context).backgroundColor,
      child: Container(
        margin: const EdgeInsets.all(10.0),
        padding: const EdgeInsets.only(bottom: 15.0),
        width: MediaQuery.of(context).size.width - 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          boxShadow: [
            if (config['shadow'] != null)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: Tools.formatDouble(config['shadow'] ?? 15.0),
                offset: Offset(0, Tools.formatDouble(config['shadow'] ?? 10.0)),
              )
          ],
        ),
        child: Column(
          children: List.generate(row, (indexCol) {
            return Row(
              children: List.generate(numberItemOnScreen, (indexRow) {
                return Expanded(
                  child: numberItemOnScreen * indexCol + indexRow >=
                          items.length
                      ? const SizedBox()
                      : FittedBox(
                          fit: BoxFit.none,
                          child:
                              items[numberItemOnScreen * indexCol + indexRow],
                        ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}
