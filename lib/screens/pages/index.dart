import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/tools.dart';
import '../../models/app_model.dart';
import '../custom/smartchat.dart';

class StaticPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool showChat;

  StaticPage({this.data, this.showChat});

  @override
  _StateStaticPage createState() => _StateStaticPage();
}

class _StateStaticPage extends State<StaticPage> {
  Widget buildContainer(Map<String, dynamic> json, width, height) {
    return Container(
      height: (json['height'] ?? 1.0) * height,
      child: Stack(
        children: <Widget>[
          if (json['image'] != null)
            Align(
              alignment: Alignment(
                  double.parse('${json['image']['align']['x'] ?? 1.0}'),
                  double.parse('${json['image']['align']['y'] ?? 1.0}')),
              child: Container(
                width: (json['image']['width'] ?? 1.0) * width,
                height: (json['image']['height'] ?? 1.0) * height,
                child: Image.network(
                  json['image']['url'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (json['header'] != null)
            Align(
              alignment: Alignment(
                  double.parse('${json['header']['align']['x'] ?? 1.0}'),
                  double.parse('${json['header']['align']['y'] ?? 1.0}')),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    color: json['header']['background'] != null
                        ? HexColor(json['header']['background'])
                        : null,
                    padding: EdgeInsets.symmetric(
                        horizontal: double.parse(
                            '${json['header']['padding']['horizontal'] ?? 0.0}'),
                        vertical: double.parse(
                            '${json['header']['padding']['vertical'] ?? 0.0}')),
                    child: Text(
                      '${json['header']['text']}',
                      style: TextStyle(
                          color: json['header']['color'] != null
                              ? HexColor(json['header']['color'])
                              : null,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (json['header']['subHeader'] != null)
                    const SizedBox(
                      height: 5,
                    ),
                  if (json['header']['subHeader'] != null)
                    Text(json['header']['subHeader'])
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final design = Map<String, dynamic>.from(widget.data);
    final showChat = widget.showChat ?? false;

    return Scaffold(
      floatingActionButton: showChat
          ? SmartChat(
              margin: EdgeInsets.only(
                right: Provider.of<AppModel>(context, listen: false).langCode ==
                        'ar'
                    ? 30.0
                    : 0.0,
              ),
            )
          : Container(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                if (design['background'] != null)
                  Container(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    color: HexColor(design['background']).withOpacity(0.2),
                    child: Container(),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (design['container'] != null)
                      buildContainer(design['container'], constraints.maxWidth,
                          constraints.maxHeight),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (design['subHeader'] != null)
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: Text(
                                design['subHeader'],
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          if (design['description'] != null)
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: Text(
                                design['description'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            )
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
