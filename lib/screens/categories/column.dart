import 'package:flutter/material.dart';

import '../../models/index.dart' show Category, ProductModel;

class ColumnCategories extends StatefulWidget {
  static const String type = 'column';

  final List<Category> categories;

  ColumnCategories(this.categories);

  @override
  _ColumnCategoriesState createState() {
    return _ColumnCategoriesState();
  }
}

class _ColumnCategoriesState extends State<ColumnCategories> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: widget.categories.length,
      // physics: const NeverScrollableScrollPhysics(),
      // shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        return CategoryColumnItem(widget.categories[index]);
      },
    );
  }

  // EdgeInsets _edgeInsetsForIndex(int index) {
  //   if (index % 2 == 0) {
  //     return const EdgeInsets.only(
  //         top: 4.0, left: 8.0, right: 4.0, bottom: 4.0);
  //   } else {
  //     return const EdgeInsets.only(
  //         top: 4.0, left: 4.0, right: 8.0, bottom: 4.0);
  //   }
  // }
}

class CategoryColumnItem extends StatelessWidget {
  final Category category;

  CategoryColumnItem(this.category);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ProductModel.showList(
          context: context, cateId: category.id, cateName: category.name),
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(category.image), fit: BoxFit.cover),
            ),
          ),
          Container(
            color: const Color.fromRGBO(0, 0, 0, 0.4),
            child: Center(
              child: Text(
                category.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }
}
