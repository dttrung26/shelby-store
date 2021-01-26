import 'dart:convert' as convert;

import 'package:localstorage/localstorage.dart';

import '../../common/constants.dart';

class FStoreNotification {
  String body;
  String title;
  bool seen;
  String date;

  FStoreNotification.fromJsonFirebase(Map<String, dynamic> json) {
    try {
      final data = json['data'];
      final notification =
          data != null && data.keys.isNotEmpty && data['title'] != null
              ? data
              : json['notification'];
      body = notification['body'];
      title = notification['title'];
      seen = false;
      date = DateTime.now().toString();
    } catch (e) {
      printLog(e.toString());
    }
  }

  FStoreNotification.fromOneSignal(osNotification) {
    title = osNotification.payload.title ?? '';
    body = osNotification.payload.body ?? '';
    date = DateTime.now().toString();
    seen = false;
  }

  FStoreNotification.fromJsonFirebaseLocal(Map<String, dynamic> json) {
    try {
      final data = json['data'];
      final notification =
          data != null && data.keys.isNotEmpty ? data : json['notification'];

      body = notification['body'];
      title = notification['title'];
      seen = false;
      int time = notification['google.sent_time'] ?? ['from'];
      date = DateTime.fromMillisecondsSinceEpoch(time).toString();
    } catch (e) {
      printLog(e.toString());
    }
  }

  FStoreNotification.fromLocalStorage(Map<String, dynamic> json) {
    try {
      if ((json['body']?.isNotEmpty ?? false) &&
          (json['title']?.isNotEmpty ?? false)) {
        body = json['body'];
        title = json['title'];
        date = json['date'] != null
            ? (DateTime.parse(json['date'])).toString()
            : '';
        seen = false;
      }
    } catch (e) {
      printLog(e.toString());
    }
  }

  FStoreNotification.from(this.body, this.title) {
    seen = false;
  }

  Map<String, dynamic> toJson() => {
        'body': body,
        'title': title,
        'seen': seen,
        'date': date,
      };

  Future<void> updateSeen(int index) async {
    final storage = LocalStorage('fstore');
    seen = true;
    try {
      final ready = await storage.ready;
      if (ready) {
        var list = storage.getItem('notifications');
        list ??= [];
        list[index] = convert.jsonEncode(toJson());
        await storage.setItem('notifications', list);
      }
    } catch (err) {
      printLog(err);
    }
  }

  Future<void> saveToLocal(String id) async {
    final storage = LocalStorage('fstore');

    try {
      final ready = await storage.ready;
      if (ready) {
        var list = storage.getItem('notifications');
        var old = storage.getItem('message-id').toString();
        if (id != null) {
          if (old.isNotEmpty && id != 'null') {
            if (old == id) return;
            await storage.setItem('message-id', id);
          } else {
            await storage.setItem('message-id', id);
          }
        }
        list ??= [];
        list.insert(0, convert.jsonEncode(toJson()));
        await storage.setItem('notifications', list);
      }
    } catch (err) {
      printLog(err);
    }
  }
}
