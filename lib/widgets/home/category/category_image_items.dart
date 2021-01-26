import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/category_model.dart';
import '../../../models/product_model.dart';

/// The category icon circle list
class CategoryItem extends StatelessWidget {
  final config;
  final products;
  final width;

  CategoryItem({this.config, this.products, this.width});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final itemWidth = (width ?? screenSize.width) / 3;
    final categoryList = Provider.of<CategoryModel>(context).categoryList;
    final id = config['category'].toString();
    final name = categoryList[id] != null ? categoryList[id].name : '';
    final image = categoryList[id] != null ? categoryList[id].image : '';
    final total = categoryList[id] != null ? categoryList[id].totalProduct : '';

    final imageWidget = config['image'] != null
        ? config['image'].toString().contains('http')
            ? Image.network(config['image'], fit: BoxFit.fitWidth)
            : Image.asset(
                config['image'],
                fit: BoxFit.fitWidth,
              )
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 5.0),
      child: GestureDetector(
        onTap: () => ProductModel.showList(config: config, context: context),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: HexColor(
                '5F' + kNameToHex['grey'],
              ),
              width: 0.5,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          ),
          width: itemWidth,
          height: 140.0,
          margin: const EdgeInsets.only(left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  width: itemWidth,
                  height: itemWidth * 0.45,
                  child: imageWidget ??
                      Tools.image(
                        url: image,
                        fit: BoxFit.cover,
                        isResize: true,
                        size: kSize.small,
                      ),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5.0),
                        topRight: Radius.circular(5.0)),
                  ),
                ),
              ),
              if (config['showText'] == true) const SizedBox(height: 6),
              if (config['showText'] == true)
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 2),
                        Text(
                          config['name'] ?? name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          config['description'] ??
                              S.of(context).totalProducts('$total'),
                          style: const TextStyle(
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// List of Category Items
class CategoryImages extends StatelessWidget {
  final config;

  CategoryImages({this.config, Key key}) : super(key: key);

  List<Widget> listItem({width}) {
    var items = <Widget>[];
    for (var item in config['items']) {
      items.add(CategoryItem(
        config: item,
        width: width,
      ));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth / 10;
        final heightList = itemWidth + 22;
        return config['wrap']
            ? Wrap(
                children: listItem(width: constraints.maxWidth),
                alignment: WrapAlignment.center,
              )
            : Container(
                height: heightList + 80,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: listItem(width: constraints.maxWidth),
                  ),
                ),
              );
      },
    );
  }
}
