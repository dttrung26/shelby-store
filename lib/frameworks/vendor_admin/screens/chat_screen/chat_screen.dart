import 'dart:io' show File;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../common/constants.dart';
import '../../../../common/theme/colors.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/index.dart' show User;
import '../../../../screens/base.dart';
import '../../../../services/index.dart';
import 'chat_typing.dart';
import 'messages.dart';

final _fireStore = FirebaseFirestore.instance;
firebase_auth.User loggedInUser;

class ChatScreen extends StatefulWidget {
  final User senderUser;
  final String receiverEmail;
  final String receiverName;

  ChatScreen({this.senderUser, this.receiverEmail, this.receiverName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends BaseScreen<ChatScreen> {
  final messageTextController = TextEditingController();
  var uuid = Uuid();
  String messagesText = '';
  File imageFile;
  String imageUrl;
  String documentId;

  @override
  void afterFirstLayout(BuildContext context) async {
    try {
      final snapshot = await _fireStore
          .collection('chatRooms')
          .doc(widget.receiverEmail + '-' + widget.senderUser.email)
          .get();
      if (snapshot == null || !snapshot.exists) {
        setState(() {
          documentId = widget.senderUser.email + '-' + widget.receiverEmail;
        });
      } else {
        setState(() {
          documentId = widget.receiverEmail + '-' + widget.senderUser.email;
        });
      }

      //update unread
      final item =
          await _fireStore.collection('chatRooms').doc(documentId).get();
      if (item.exists) {
        List users = item.data()['users'];
        final obj = users.firstWhere((o) => o['email'] == widget.receiverEmail,
            orElse: () => null);

        await _fireStore.collection('chatRooms').doc(documentId).set({
          ...item.data(),
          'users': [
            {
              'email': widget.senderUser.email,
              'name': widget.senderUser.name,
              'unread': 0
            },
            {
              'email': widget.receiverEmail,
              'name': widget.receiverName,
              'unread': obj['unread']
            }
          ]
        }, SetOptions(merge: true));
      }

      //update chatwith
      await _fireStore
          .collection('users')
          .doc(widget.senderUser.email)
          .set({'chatWith': widget.receiverEmail}, SetOptions(merge: true));
    } catch (e) {
      printLog(e.toString());
    }
  }

  void sendMessage({imgUrl, text}) {
    _fireStore
        .collection('chatRooms')
        .doc(documentId)
        .collection('chatScreen')
        .add({
      'text': text ?? '',
      'sender': widget.senderUser.email,
      'createdAt': DateTime.now().toIso8601String(),
      'image': imgUrl ?? '',
    });
    final message =
        imgUrl != null ? widget.senderUser.name + ' has sent an image.' : text;
    _fireStore.collection('chatRooms').doc(documentId).get().then((snapshot) {
      var updates = {
        'userTyping': false,
        'adminTyping': false,
        'lastestMessage': message,
        'userEmail': widget.senderUser.email,
        'createdAt': DateTime.now().toIso8601String(),
        'isSeenByAdmin': true
      };
      var unread = 0;
      if (snapshot.exists) {
        List users = snapshot.data()['users'];
        final obj = users.firstWhere((o) => o['email'] == widget.receiverEmail,
            orElse: () => null);
        unread = obj['unread'];
      }
      updates['users'] = [
        {
          'email': widget.senderUser.email,
          'name': widget.senderUser.name,
          'unread': 0
        },
        {
          'email': widget.receiverEmail,
          'name': widget.receiverName,
          'unread': unread + 1
        }
      ];

      _fireStore
          .collection('chatRooms')
          .doc(documentId)
          .set(updates, SetOptions(merge: true));

      //push notification
      _fireStore
          .collection('users')
          .doc(widget.receiverEmail)
          .get()
          .then((snapshot) {
        if (snapshot.exists) {
          Map user = snapshot.data();
          if (user['chatWith'] != widget.senderUser.email) {
            Services()
                .api
                .pushNotification(
                    receiverEmail: widget.receiverEmail,
                    senderName: widget.senderUser.name,
                    message: message)
                .then((res) {})
                .catchError((err) {});
          }
        }
      }).catchError((e) {});
    }).catchError((e) {});
  }

  void updateTyping(bool status) {
    var document = _fireStore.collection('chatRooms').doc(documentId);
    document.update({'userTyping': status});
  }

  @override
  Widget build(BuildContext context) {
    if (documentId == null) {
      return Scaffold(
        body: Container(),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 22,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              //update chatwith
              _fireStore
                  .collection('users')
                  .doc(widget.senderUser.email)
                  .set({'chatWith': null}, SetOptions(merge: true));
              Navigator.of(context).pop();
            } else {
              Navigator.pushNamed(context, '/home');
            }
          },
        ),
        title: Text(
          '${widget.receiverName}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Scrollbar(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MessagesStream(
                documentId: documentId,
                senderEmail: widget.senderUser.email,
              ),
              TypingStream(
                isAdminLoggedIn: false,
                userEmail: widget.receiverEmail,
              ),
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: kTeal400, width: 2.0),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageTextController,
                        onChanged: (value) {
                          messagesText = value;
                          updateTyping(true);
                        },
                        onEditingComplete: () {
                          updateTyping(false);
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          hintText: S.of(context).typeYourMessage,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        messageTextController.clear();
                        if (messagesText.isNotEmpty) {
                          sendMessage(text: messagesText);
                        }
                        messagesText = '';
                      },
                      child: Text(
                        S.of(context).send,
                        style: const TextStyle(
                          color: kTeal400,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
