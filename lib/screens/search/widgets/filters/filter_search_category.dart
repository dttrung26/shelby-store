import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/constants.dart';
import '../../../../models/index.dart' show Category, CategoryModel;

class FilterSearchCategory extends StatefulWidget {
  final Function(List<Category>, String) onSelect;
  final List<Category> listSelected;

  FilterSearchCategory({
    this.onSelect,
    this.listSelected,
  });

  @override
  _FilterSearchCategoryState createState() => _FilterSearchCategoryState();
}

class _FilterSearchCategoryState extends State<FilterSearchCategory> {
  List<Category> _listSelect = [];

  bool checkAttributeSelected(String name) {
    return _listSelect.any((element) => name == element.name);
  }

  void _onTapCategory(Category _category) {
    var _isFound = checkAttributeSelected(_category.name);

    _listSelect?.clear();
    if (!_isFound) {
      _listSelect.add(_category);
    }

    widget.onSelect(_listSelect, 'categories');
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _listSelect = widget.listSelected.toList();
  }

  @override
  Widget build(BuildContext context) {
    var Categories = Provider.of<CategoryModel>(context);

    Color getColorSelectTextButton(bool isSelected) =>
        isSelected ? Colors.white : Theme.of(context).accentColor;

    Color getColorSelectBackgroundButton(bool isSelected) => isSelected
        ? Theme.of(context).primaryColor
        : Theme.of(context).primaryColorLight;

    return ListenableProvider.value(
      value: Categories,
      child: Consumer<CategoryModel>(builder: (context, value, child) {
        if (value.isLoading) {
          return Center(child: kLoadingWidget(context));
        }
        return Container(
          height: 80,
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(width: 30),
                  ...List.generate(
                    value.categories.length,
                    (int index) {
                      if (value.categories[index].parent == '0') {
                        return GestureDetector(
                          onTap: () {
                            _onTapCategory(value.categories[index]);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 15),
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 20,
                            ),
                            child: Text(
                              '${value.categories[index].name}',
                              style: TextStyle(
                                fontSize: 17,
                                color: getColorSelectTextButton(
                                  checkAttributeSelected(
                                    value.categories[index].name,
                                  ),
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            decoration: BoxDecoration(
                              color: getColorSelectBackgroundButton(
                                checkAttributeSelected(
                                  value.categories[index].name,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
