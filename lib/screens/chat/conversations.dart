import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/user_model.dart';
import '../../screens/base.dart';
import 'chat_screen.dart';

final _fireStore = FirebaseFirestore.instance;

class ListChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 22,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          S.of(context).chatListScreen,
          style: TextStyle(color: Theme.of(context).accentColor),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ChatItemsStream(),
      ),
    );
  }
}

class ChatItemsStream extends StatefulWidget {
  @override
  _ChatItemsStreamState createState() => _ChatItemsStreamState();
}

class _ChatItemsStreamState extends BaseScreen<ChatItemsStream> {
  List<String> documents = [];

  @override
  void afterFirstLayout(BuildContext context) async {
    final userModel = Provider.of<UserModel>(context, listen: false);

    final items = [];
    await _fireStore
        .collection('chatRooms')
        .orderBy('createdAt', descending: true)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        if (document.id.contains(userModel.user.email + '-') ||
            document.id.contains('-' + userModel.user.email)) {
          items.add(document.id);
        }
      });
    });
    setState(() {
      documents = [...items];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(documents.length, (index) {
          return ChatItem(
            documentId: documents[index],
          );
        }),
      ),
    );
  }
}

class ChatItem extends StatelessWidget {
  final String documentId;

  ChatItem({this.documentId});

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

    return FutureBuilder<DocumentSnapshot>(
      future: _fireStore.collection('chatRooms').doc(documentId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
          case ConnectionState.done:
            if (!snapshot.hasData) return Container();
        }

        var users =
            List<Map<dynamic, dynamic>>.from(snapshot.data.data()['users']);
        final receiver = users.firstWhere(
            (o) => o['email'] != userModel.user.email,
            orElse: () => null);
        final timeDif = DateTime.now()
            .difference(DateTime.parse(snapshot.data.data()['createdAt']));

        final me = users.firstWhere((o) => o['email'] == userModel.user.email,
            orElse: () => null);
        final unread = me['unread'] ?? 0;

        return GestureDetector(
            onTap: () {
              _fireStore.collection('chatRooms').doc(documentId).update({
                'isSeenByAdmin': true,
                'userTyping': false,
                'adminTyping': false
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                      senderUser: userModel.user,
                      receiverName: receiver['name'],
                      receiverEmail: receiver['email']),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Card(
                color: Theme.of(context).bottomAppBarColor,
                elevation: 1.5,
                child: ListTile(
                  contentPadding: const EdgeInsets.only(
                      top: 10, bottom: 10, left: 20.0, right: 10.0),
                  trailing: unread > 0
                      ? Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(10)),
                          child: Center(
                            child: Text(
                              '$unread',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.white),
                            ),
                          ),
                        )
                      : null,
                  leading: Tools.getCachedAvatar(
                      'https://api.hello-avatar.com/adorables/100/${receiver['email']}.png'),
                  title: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 7,
                        child: Text(
                          receiver['name'],
                          style: const TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          '${timeago.format(DateTime.now().subtract(timeDif), locale: 'en')}',
                          style: DefaultTextStyle.of(context).style.copyWith(
                              fontStyle: FontStyle.italic, fontSize: 10.0),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  subtitle: snapshot.data.data()['userTyping']
                      ? Text(
                          '${receiver['email'].toString().split('@').first} is typing ...',
                          style: DefaultTextStyle.of(context).style.copyWith(
                              fontStyle: FontStyle.italic, fontSize: 12.0),
                          overflow: TextOverflow.fade,
                        )
                      : Text(
                          '${snapshot.data.data()['lastestMessage']}',
                          style: DefaultTextStyle.of(context).style,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                  dense: true,
                  enabled: snapshot.data.data()['isSeenByAdmin'],
                ),
              ),
            ));
      },
    );
  }
}
