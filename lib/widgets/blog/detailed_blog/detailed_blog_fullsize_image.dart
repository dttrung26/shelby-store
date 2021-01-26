import 'dart:ui' as ui show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../common/tools.dart';
import '../../../models/index.dart' show BlogNews;

class FullImageType extends StatefulWidget {
  final BlogNews item;

  FullImageType({Key key, @required this.item}) : super(key: key);

  @override
  _FullImageTypeState createState() => _FullImageTypeState();
}

class _FullImageTypeState extends State<FullImageType> {
  ScrollController _scrollController;
  double _opacity = 0;
  bool isFBNativeBannerAdShown = false;
  bool isFBNativeAdShown = false;
  bool isFBBannerShown = false;

  @override
  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  void _scrollListener() {
    if (_scrollController.offset == 0 && _opacity == 1) {
      setState(() => _opacity = 0);
    } else if (_opacity == 0) {
      setState(() => _opacity = 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height,
          child: Tools.image(
            url: widget.item.imageFeature,
            fit: BoxFit.fitHeight,
            size: kSize.medium,
          ),
        ),
        Positioned.fill(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 600),
            opacity: _opacity,
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: 15,
                sigmaY: 15,
              ),
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.black87, Colors.black54, Colors.black45],
                stops: [0.1, 0.3, 0.5],
                begin: Alignment.bottomCenter,
                end: Alignment.center),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            actions: const <Widget>[],
            leading: IconButton(
                color: Colors.white.withOpacity(0.8),
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: Navigator.of(context).pop),
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.6,
                            left: 15,
                            right: 15,
                            bottom: 15),
                        child: Text(
                          widget.item.title,
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    Tools.formatDateString(widget.item.date),
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: HtmlWidget(
                          widget.item.content,
                          webView: true,
                          hyperlinkColor:
                              Theme.of(context).primaryColor.withOpacity(0.9),
                          textStyle:
                              Theme.of(context).textTheme.bodyText1.copyWith(
                                    fontSize: 14.0,
                                    height: 1.4,
                                    color: Colors.white,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
