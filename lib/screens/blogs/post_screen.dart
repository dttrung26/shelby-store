import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../models/index.dart' show AppModel, BlogNews;
import '../../services/index.dart';
import '../custom/smartchat.dart';

class PostScreen extends StatefulWidget {
  final int pageId;
  final String pageTitle;
  final bool isLocatedInTabbar;
  final bool showChat;

  PostScreen(
      {this.pageId,
      this.pageTitle,
      this.isLocatedInTabbar = false,
      this.showChat});

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final Services _service = Services();
  Future<BlogNews> _getPage;
  final _memoizer = AsyncMemoizer<BlogNews>();

  @override
  void initState() {
    // only create the future once
    Future.delayed(Duration.zero, () {
      setState(() {
        _getPage = getPageById(widget.pageId);
      });
    });
    super.initState();
  }

  Future<BlogNews> getPageById(context) => _memoizer.runOnce(
        () => _service.api.getPageById(
          widget.pageId,
        ),
      );

  @override
  Widget build(BuildContext context) {
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
          : const SizedBox(),
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        title: Text(
          '${widget.pageTitle.toString()}',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        leading: widget.isLocatedInTabbar
            ? Container()
            : Center(
                child: GestureDetector(
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ),
      ),
      body: FutureBuilder<BlogNews>(
        future: _getPage,
        builder: (BuildContext context, AsyncSnapshot<BlogNews> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Scaffold(
                body: Container(
                  color: Theme.of(context).backgroundColor,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            case ConnectionState.done:
            default:
              if (snapshot.hasError || snapshot.data.id == null) {
                return Material(
                  child: Container(
                    color: Theme.of(context).backgroundColor,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          S.of(context).noPost,
                          style: const TextStyle(color: Colors.black),
                        ),
                        widget.isLocatedInTabbar
                            ? Container()
                            : FlatButton(
                                color: Theme.of(context).accentColor,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  S.of(context).goBackHomePage,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                      ],
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 0.0,
                ),
                child: PostView(
                  item: snapshot.data,
                ),
              );
          }
        },
      ),
    );
  }
}

class PostView extends StatelessWidget {
  final BlogNews item;

  PostView({this.item});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: HtmlWidget(
        item.content,
        webView: true,
        webViewJs: true,
        hyperlinkColor: Theme.of(context).primaryColor.withOpacity(0.9),
        textStyle: Theme.of(context).textTheme.subtitle1.copyWith(
              fontSize: 13.0,
              height: 1.4,
              color: Theme.of(context).accentColor,
            ),
      ),
    );
  }
}
