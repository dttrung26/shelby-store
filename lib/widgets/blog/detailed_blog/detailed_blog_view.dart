import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../common/tools.dart';
import '../../../models/index.dart' show BlogNews;

class BlogDetail extends StatefulWidget {
  final BlogNews item;

  BlogDetail({Key key, @required this.item}) : super(key: key);

  @override
  _BlogCardState createState() => _BlogCardState();
}

class _BlogCardState extends State<BlogDetail> {
  @override
  Widget build(BuildContext context) {
    var item = widget.item;
    const bannerHigh = 180.0;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            leading: Center(
              child: GestureDetector(
                onTap: () => {Navigator.pop(context)},
                child: const Icon(Icons.arrow_back_ios,
                    color: Colors.black, size: 20),
              ),
            ),
            expandedHeight: bannerHigh,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: <Widget>[
                  Tools.image(
                      url: item.imageFeature,
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width,
                      size: kSize.medium),
                  Tools.image(
                      url: item.imageFeature,
                      fit: BoxFit.contain,
                      size: kSize.large),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          item.title,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 25,
                            color:
                                Theme.of(context).accentColor.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              item.date,
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .accentColor
                                    .withOpacity(0.45),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'by ${item.author}',
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .accentColor
                                    .withOpacity(0.45),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      HtmlWidget(
                        item.content,
                        webView: true,
                        hyperlinkColor:
                            Theme.of(context).primaryColor.withOpacity(0.9),
                        textStyle:
                            Theme.of(context).textTheme.bodyText1.copyWith(
                                  fontSize: 13.0,
                                  height: 1.4,
                                  color: Theme.of(context)
                                      .accentColor
                                      .withOpacity(0.9),
                                ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
