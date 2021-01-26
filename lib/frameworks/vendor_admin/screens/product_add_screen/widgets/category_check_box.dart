import 'package:flutter/material.dart';

import '../../../../../models/entities/category.dart';

class CategoryCheckBox extends StatelessWidget {
  final List<String> selectedCategoryIds;
  final Category category;
  final Function onTap;
  final Function(String) onCheckBoxTap;
  const CategoryCheckBox(
      {Key key,
      this.selectedCategoryIds,
      this.category,
      this.onTap,
      this.onCheckBoxTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 15.0),
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: selectedCategoryIds.contains(category.id),
              onChanged: (val) => onCheckBoxTap(category.id),
            ),
          ),
          const SizedBox(width: 5),
//          CircleAvatar(
//            radius: 15.0,
//            backgroundImage: NetworkImage(category.image),
//          ),
//          const SizedBox(width: 5),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Row(
                children: [
                  const SizedBox(width: 5),
                  Expanded(child: Text(category.name)),
                  if (onTap != null)
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16.0,
                    ),
                  const SizedBox(width: 5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
