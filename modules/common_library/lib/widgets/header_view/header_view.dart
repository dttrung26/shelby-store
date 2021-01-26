import 'package:flutter/material.dart';

class HeaderView extends StatelessWidget {
  final String headerText;
  final VoidCallback callback;
  final bool showSeeAll;

  HeaderView({
    this.headerText,
    this.showSeeAll = false,
    Key key,
    this.callback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width,
      color: Theme.of(context).backgroundColor,
      child: Container(
        width: screenSize.width / (2 / (screenSize.height / screenSize.width)),
        margin: const EdgeInsets.only(top: 20.0),
        padding: const EdgeInsets.only(
            left: 15.0, top: 20.0, right: 15.0, bottom: 15.0),
        child: Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: <Widget>[
            Expanded(
              child: Text(
                headerText ?? '',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
