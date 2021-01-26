import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/app_model.dart';
import '../custom/smartchat.dart';

class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;
  final bool showChat;

  WebViewScreen({this.title, @required this.url, this.showChat});

  @override
  _StateWebViewScreen createState() => _StateWebViewScreen();
}

class _StateWebViewScreen extends State<WebViewScreen> {
  WebViewController _controller;

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
          : Container(),
      appBar: AppBar(
        title: Text(widget.title ?? ''),
        actions: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: () async {
                if (await _controller.canGoBack()) {
                  await _controller.goBack();
                } else {
                  Tools.showSnackBar(Scaffold.of(context),
                      Text(S.of(context).noBackHistoryItem));
                  return;
                }
              },
              child: const Icon(Icons.arrow_back_ios),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: () async {
                if (await _controller.canGoForward()) {
                  await _controller.goForward();
                } else {
                  Tools.showSnackBar(
                      Scaffold.of(context), S.of(context).noForwardHistoryItem);
                  return;
                }
              },
              child: const Icon(Icons.arrow_forward_ios),
            ),
          )
        ],
      ),
      body: isMacOS || isWindow || isFuchsia
          ? Center(
              child: Text(S.of(context).thisPlatformNotSupportWebview),
            )
          : WebView(
              javascriptMode: JavascriptMode.unrestricted,
              initialUrl: widget.url,
              onWebViewCreated: (WebViewController controller) {
                _controller = controller;
              },
            ),
    );
  }
}
