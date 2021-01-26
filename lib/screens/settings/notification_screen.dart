import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import '../../generated/l10n.dart';
import '../../models/index.dart' show FStoreNotification;

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final LocalStorage storage = LocalStorage('fstore');
  List<FStoreNotification> _data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          S.of(context).listMessages,
          style: TextStyle(color: Theme.of(context).accentColor),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,
      ),
      body: FutureBuilder(
        initialData: false,
        future: storage.ready,
        builder: (BuildContext context, snapshot) {
          if (snapshot?.data == true) {
            _data = parseFromListJson(storage.getItem('notifications') as List);
            return _renderBody();
          } else {
            return Text(S.of(context).loading);
          }
        },
      ),
    );
  }

  Widget _renderBody() {
    if (_data == null || _data != null && _data.isEmpty) {
      return Center(
        child: Text(S.of(context).noData),
      );
    }

    return Container(
      color: Theme.of(context).backgroundColor,
      child: ListView.builder(
        itemCount: _data.length,
        itemBuilder: (context, index) {
          if (_data[index].date == null) {
            return Container();
          }
          return Padding(
            child: Dismissible(
              key: Key(_data[index].date),
              onDismissed: (direction) {
                removeItem(index);
              },
              background: Container(color: Colors.redAccent),
              child: Card(
                child: ListTile(
                  onTap: () {
                    _showAlert(context, _data[index], index);
                  },
                  title: Text(
                    _data[index].title,
                    style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w400),
                  ),
                  subtitle: Column(
                    children: <Widget>[
                      Padding(
                        child: Text(
                          _data[index].body,
                          maxLines: 2,
                          style: TextStyle(
                            color:
                                Theme.of(context).accentColor.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                      ),
                      Text(
                        getTime(
                          _data[index].date,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).accentColor.withOpacity(0.5),
                        ),
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                  leading: Icon(
                    Icons.notifications_none,
                    size: 30,
                    color: _data[index].seen ? Colors.grey : Colors.greenAccent,
                  ),
                  isThreeLine: true,
                ),
              ),
            ),
            padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
          );
        },
      ),
    );
  }

  String getTime(String time) {
    var now = DateTime.now();
    var date = DateTime.parse(time);
    if (now.difference(date).inDays > 0) {
      return S.of(context).daysAgo(now.difference(date).inDays.toString());
    }
    if (now.difference(date).inHours > 0) {
      return S.of(context).hoursAgo(now.difference(date).inHours.toString());
    }
    if (now.difference(date).inMinutes > 0) {
      return S
          .of(context)
          .minutesAgo(now.difference(date).inMinutes.toString());
    }
    return S.of(context).secondsAgo(now.difference(date).inSeconds.toString());
  }

  Future<void> removeItem(int index) async {
    try {
      final ready = await storage.ready;
      if (ready) {
        var list = storage.getItem('notifications');
        list ??= [];
        list.removeAt(index);
        await storage.setItem('notifications', list);
        setState(() {
          _data = list;
        });
      }
    } catch (err) {
//      print(err);
    }
  }

  Future<void> _showAlert(
      BuildContext context, FStoreNotification data, int index) async {
    await data.updateSeen(index);
    try {
      final ready = await storage.ready;
      if (ready) {
        var list = storage.getItem('notifications');
        list ??= [];
        setState(() {
          _data = list;
        });
      }
    } catch (err) {
//      print(err);
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Container(
          child: const Icon(
            Icons.notifications_none,
            color: Colors.greenAccent,
            size: 40,
          ),
          alignment: Alignment.topLeft,
        ),
        content: Container(
            height: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              children: <Widget>[
                Text(
                  data.title,
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20.0),
                Text(
                  data.body,
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 16),
                )
              ],
            )),
      ),
    );
  }
}

List<FStoreNotification> parseFromListJson(List listNotify) {
  return listNotify
      ?.map((item) => item == null
          ? null
          : FStoreNotification.fromLocalStorage(
              convert.jsonDecode(item) as Map<String, dynamic>))
      ?.toList();
}
