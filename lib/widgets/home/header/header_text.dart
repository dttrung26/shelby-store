import 'package:flutter/material.dart';

import '../../../common/constants.dart';
import '../../../common/tools.dart';
import 'header_type.dart';

class HeaderText extends StatelessWidget {
  final config;

  HeaderText({this.config, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: config['height'] != null
          ? MediaQuery.of(context).size.height * config['height']
          : 100,
      padding: EdgeInsets.only(
          top: Tools.formatDouble(config['padding'] ?? 20.0),
          left: Tools.formatDouble(config['padding'] ?? 20.0),
          right: Tools.formatDouble(config['padding'] ?? 15.0),
          bottom: 10.0),
      width: MediaQuery.of(context).size.width,
      child: SafeArea(
        bottom: false,
        top: config['isSafeArea'] == true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: HeaderType(config: config),
            ),
            if (config['showSearch'] == true)
              IconButton(
                icon: const Icon(Icons.search),
                iconSize: 24.0,
                onPressed: () {
                  Navigator.of(context).pushNamed(RouteList.homeSearch);
                },
              )
          ],
        ),
      ),
    );
  }
}
