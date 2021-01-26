import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../../models/index.dart' show Product;
import '../../widgets/product/product_card_view.dart';

class ListCard extends StatelessWidget {
  final List<Product> data;
  final String id;
  final width;

  ListCard({this.data, this.id, this.width});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double _width = kIsWeb ? width / 2 : width;

        return Container(
          height: _width * 0.4 + 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            key: ObjectKey(id),
            itemBuilder: (context, index) {
              return ProductCard(item: data[index], width: _width * 0.35);
            },
            itemCount: data.length,
          ),
        );
      },
    );
  }
}
