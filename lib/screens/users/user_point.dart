import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show UserModel, UserPoints;
import '../../services/index.dart' show Config;

class UserPoint extends StatefulWidget {
  @override
  _StateUserPoint createState() => _StateUserPoint();
}

class _StateUserPoint extends State<UserPoint> {
  final dateWidth = 100;
  final pointWidth = 50;
  final borderWidth = 0.5;

  Future<UserPoints> getUserPoint() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final points = await http.get(
        '${Config().url}/wp-json/api/flutter_user/get_points/?insecure=cool&user_id=${userModel.user.id}');
    return UserPoints.fromJson(json.decode(points.body));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          brightness: Theme.of(context).brightness,
          backgroundColor: Theme.of(context).primaryColorLight,
          title: Text(
            S.of(context).myPoints,
            style: TextStyle(
              color: Theme.of(context).accentColor,
            ),
          ),
          leading: GestureDetector(
            child: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).accentColor,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: FutureBuilder<UserPoints>(
          future: getUserPoint(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Align(
                child: kLoadingWidget(context),
                alignment: Alignment.center,
              );
            }
            if (!snapshot.hasData) return Container();
            return Padding(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ListTile(
                      trailing: Text(
                        snapshot.data.points.toString(),
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                              fontSize: 35,
                            ),
                      ),
                      title: Text(
                        S.of(context).myPoints,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Divider(indent: 15.0, endIndent: 15.0),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        S.of(context).events,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        for (var event in snapshot.data.events)
                          ListTile(
                            trailing: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                event.points,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                              ),
                            ),
                            title: Text(event.description),
                            subtitle: Text(
                              event.date,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .accentColor
                                    .withOpacity(0.6),
                              ),
                            ),
                          )
                      ],
                    )
                  ],
                ),
              ),
              padding: const EdgeInsets.all(10),
            );
          },
        ));
  }
}
