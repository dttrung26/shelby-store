import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../services/service_config.dart';
import 'header/header_view.dart';
import 'vertical/menu_layout.dart';
import 'vertical/pinterest_layout.dart';
import 'vertical/vertical_layout.dart';

class VerticalLayout extends StatelessWidget {
  final config;

  VerticalLayout({this.config, Key key}) : super(key: key);

  Widget renderLayout() {
    switch (config['layout']) {
      case 'menu':
        return MenuLayout(config: config);
      case 'pinterest':
        return PinterestLayout(config: config);
      default:
        return VerticalViewLayout(config: config);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        if (config['name'] != null)
          HeaderView(
            headerText: config['name'] ?? '',
            showSeeAll: !Config().isListingType,
            callback: () => ProductModel.showList(
              context: context,
              config: config,
            ),
          ),
        renderLayout()
      ],
    );
  }
}
