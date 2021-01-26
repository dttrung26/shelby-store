import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/app_model.dart';
import '../custom/smartchat.dart';

class StaticSite extends StatelessWidget {
  final String data;
  final bool showChat;

  StaticSite({this.data, this.showChat});

  @override
  Widget build(BuildContext context) {
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
      body: isMacOS || isWindow || isFuchsia
          ? Center(
              child: Text(S.of(context).thisPlatformNotSupportWebview),
            )
          : WebView(
              onWebViewCreated: (controller) async {
                await controller.loadUrl('data:text/html;base64,$data');
              },
            ),
    );
  }
}
