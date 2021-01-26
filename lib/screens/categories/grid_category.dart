import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../models/index.dart' show Category, ProductModel, AppModel;
import '../../widgets/icons/feather.dart';

class GridCategory extends StatefulWidget {
  static const String type = 'grid';

  final List<Category> categories;

  GridCategory(this.categories);

  @override
  _StateGridCategory createState() => _StateGridCategory();
}

class _StateGridCategory extends State<GridCategory> {
  @override
  Widget build(BuildContext context) {
    var categories = widget.categories;
    var _icons = Provider.of<AppModel>(context, listen: true).categoriesIcons;
    var icons = _icons ?? kGridIconsCategories.values.toList();

    if (categories == null) {
      return Container(
        child: kLoadingWidget(context),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: <Widget>[
              for (int i = 0; i < categories.length; i++)
                GestureDetector(
                  child: Container(
                    width: constraints.maxWidth / kAdvanceConfig['GridCount'] -
                        20 * kAdvanceConfig['GridCount'],
                    margin: const EdgeInsets.all(20.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: !icons[i % icons.length].contains('/')
                                ? Icon(
                                    featherIcons[icons[i % icons.length]],
                                    color: Theme.of(context).accentColor,
                                  )
                                : (icons[i % icons.length].contains('http')
                                    ? Image.network(
                                        icons[i % icons.length],
                                        color: Theme.of(context).accentColor,
                                      )
                                    : Image.asset(
                                        icons[i % icons.length],
                                        color: Theme.of(context).accentColor,
                                      )),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            categories[i].name,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
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
                )
            ],
          ),
        );
      },
    );
  }
}
