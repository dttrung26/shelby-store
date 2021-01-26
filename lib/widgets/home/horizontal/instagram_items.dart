import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../widgets/home/header/header_view.dart';

class Instagram extends StatefulWidget {
  final String id;

  Instagram({Key key, @required this.id}) : super(key: key);

  @override
  _InstagramState createState() => _InstagramState();
}

class _InstagramState extends State<Instagram> {
  @override
  Widget build(BuildContext context) {
    var id = widget.id;

    return Scaffold(
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        backgroundColor: Theme.of(context).primaryColorLight,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: WebView(
        initialUrl: 'https://www.instagram.com/p/$id/',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}

class ImageInstagram {
  final List<String> images;
  final int count;
  final List<String> shortcodes;

  ImageInstagram({this.images, this.count, this.shortcodes});

  factory ImageInstagram.fromJson(Map<String, dynamic> json) {
    // ignore: omit_local_variable_types
    int count = max(
        json['graphql']['hashtag']['edge_hashtag_to_media']['edges'].length,
        14);
    var images = <String>[];
    var shortcodes = [];
    for (var i = 0; i < count; i++) {
      images.add(json['graphql']['hashtag']['edge_hashtag_to_media']['edges'][i]
          ['node']['thumbnail_src']);
      shortcodes.add(json['graphql']['hashtag']['edge_hashtag_to_media']
          ['edges'][i]['node']['shortcode']);
    }
    return ImageInstagram(images: images, count: count, shortcodes: shortcodes);
  }
}

class InstagramItems extends StatefulWidget {
  final config;

  InstagramItems({this.config, Key key}) : super(key: key);

  @override
  _InstagramItemsState createState() => _InstagramItemsState();
}

class _InstagramItemsState extends State<InstagramItems> {
  Future<ImageInstagram> _fetchImages;
  final _memoizer = AsyncMemoizer<ImageInstagram>();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _fetchImages = fetchImageOne(widget.config['tag']);
    });
  }

  Future<ImageInstagram> fetchImageOne(tag) =>
      _memoizer.runOnce(() => fetchImages(tag));

  Future<ImageInstagram> fetchImages(tag) async {
    final response =
        await http.get('https://www.instagram.com/explore/tags/$tag/?__a=1');
    return ImageInstagram.fromJson(json.decode(response.body));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        HeaderView(headerText: widget.config['name'] ?? '', showSeeAll: false),
        Padding(
          child: FutureBuilder<ImageInstagram>(
            future: _fetchImages,
            builder: (context, snaphost) {
              if (snaphost.hasData) {
                return Container(
                    height: 300,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          (snaphost.data.count ~/ 2).toInt(),
                          (index) {
                            return Column(
                              children: <Widget>[
                                GestureDetector(
                                  child: Container(
                                    height: 150,
                                    padding: const EdgeInsets.only(
                                        right: 15, bottom: 15),
                                    child: Tools.image(
                                      url: snaphost.data.images[index * 2],
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Instagram(
                                                id: snaphost.data
                                                    .shortcodes[index * 2])));
                                  },
                                ),
                                GestureDetector(
                                  excludeFromSemantics: true,
                                  child: Container(
                                    height: 150,
                                    padding: const EdgeInsets.only(
                                        right: 15, bottom: 15),
                                    child: Tools.image(
                                      url: snaphost.data.images[index * 2 + 1],
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Instagram(
                                            id: snaphost.data
                                                .shortcodes[index * 2 + 1]),
                                      ),
                                    );
                                  },
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ));
              } else {
                return kLoadingWidget(context);
              }
            },
          ),
          padding: const EdgeInsets.all(15.0),
        ),
      ],
    );
  }
}
