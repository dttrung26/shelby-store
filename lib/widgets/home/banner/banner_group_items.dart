import 'package:flutter/material.dart';

import '../../../common/tools.dart';
import '../../../widgets/home/banner/banner_items.dart';

/// The Banner Group type to display the image as multi columns
class BannerGroupItems extends StatelessWidget {
  final config;

  BannerGroupItems({this.config, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List items = config['items'];

    return Container(
      color: Theme.of(context).backgroundColor,
      padding: EdgeInsets.all(Tools.formatDouble(config['padding'] ?? 10.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          for (int i = 0; i < items.length; i++)
            Expanded(
              child: BannerImageItem(config: items[i]),
            ),
        ],
      ),
    );
  }
}
