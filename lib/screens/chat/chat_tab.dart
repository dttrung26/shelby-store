import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart' as config;
import '../../models/user_model.dart';
import '../index.dart' show LoginScreen;
import 'chat_screen.dart';
import 'conversations.dart';

class ChatTab extends StatefulWidget {
  @override
  _ChatTabState createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

    return ListenableProvider.value(
      value: userModel,
      child: Consumer<UserModel>(
        builder: (context, value, child) {
          if (value.user != null) {
            if (value.user.email == config.adminEmail) {
              return ListChatScreen();
            }
            return ChatScreen(
              senderUser: value.user,
              receiverEmail: config.adminEmail,
              receiverName: config.adminName,
            );
          }
          return LoginScreen();
        },
      ),
    );
  }
}
