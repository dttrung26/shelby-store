import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../generated/l10n.dart';
import '../../../models/entities/index.dart';
import '../../../widgets/common/expansion_info.dart';

class ProductDescription extends StatelessWidget {
  final Product product;

  ProductDescription({this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 15),
        ExpansionInfo(
          expand: true,
          title: S.of(context).description,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: HtmlWidget(
                product.description ?? '',
                textStyle: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
