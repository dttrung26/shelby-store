import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/app_model.dart';

class LanguageScreen extends StatefulWidget {
  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final GlobalKey<ScaffoldState> _scaffordKey = GlobalKey<ScaffoldState>();

  void _showLoading(String language) {
    final snackBar = SnackBar(
      content: Text(
        S.of(context).languageSuccess,
        style: const TextStyle(
          fontSize: 15,
        ),
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: Theme.of(context).primaryColor,
      action: SnackBarAction(
        label: language,
        onPressed: () {},
      ),
    );
    // ignore: deprecated_member_use
    _scaffordKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    var list = <Widget>[];
    List<Map<String, dynamic>> languages = Utils.getLanguagesList(context);
    for (var i = 0; i < languages.length; i++) {
      list.add(
        ListTile(
          leading: Image.asset(
            languages[i]['icon'],
            width: 30,
            height: 20,
            fit: BoxFit.cover,
          ),
          title: Text(languages[i]['name']),
          onTap: () async {
            await Provider.of<AppModel>(context, listen: false)
                .changeLanguage(languages[i]['code'], context);
            setState(() {});
            _showLoading(languages[i]['text']);
          },
        ),
      );
      if (i < languages.length - 1) {
        list.add(
          Divider(
            color: Theme.of(context).primaryColorLight,
            height: 1.0,
            indent: 75,
            //endIndent: 20,
          ),
        );
      }
    }
    return Scaffold(
      key: _scaffordKey,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          S.of(context).language,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        leading: Center(
          child: GestureDetector(
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onTap: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...list,
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
