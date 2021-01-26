import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
//import 'package:webview_flutter/webview_flutter.dart' as _widget;

import '../../common/constants.dart';

class WebView extends StatefulWidget {
  final String url;
  final String title;

  WebView({Key key, this.title, @required this.url}) : super(key: key);

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: widget.url,
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
        title: Text(widget.title ?? ''),
      ),
      withZoom: true,
      withLocalStorage: true,
      hidden: true,
      initialChild: kLoadingWidget(context),
    );
//    return Scaffold(
//      backgroundColor: Theme.of(context).backgroundColor,
//      appBar: AppBar(
//        leading: IconButton(
//            icon: const Icon(Icons.arrow_back),
//            onPressed: () {
//              Navigator.of(context).pop();
//            }),
//        backgroundColor: Theme.of(context).backgroundColor,
//        elevation: 0.0,
//        title: Text(widget.title ?? ''),
//      ),
//      body: Stack(
//        children: <Widget>[
//          _widget.WebView(
//            initialUrl: widget.url,
//            onPageFinished: (_) {
//              setState(() {
//                isLoading = false;
//              });
//            },
//            javascriptMode: _widget.JavascriptMode.unrestricted,
//          ),
//          if (isLoading) kLoadingWidget(context),
//        ],
//      ),
//    );
  }
}
