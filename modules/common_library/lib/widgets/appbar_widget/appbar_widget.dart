import 'package:flutter/material.dart';

class AppbarWidget extends AppBar {
  AppbarWidget.normal(
    BuildContext context, {
    Key key,
    String title,
  }) : super(
          key: key,
          backgroundColor: Theme.of(context).backgroundColor,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).accentColor,
              size: 24,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            title ?? ' ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).accentColor,
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: IconButton(
                onPressed: () {
                  // showMessage();
                },
                icon: const Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );

  AppbarWidget.story(
    BuildContext context, {
    Key key,
    String title,
    Function onSave,
    Widget icon,
    Function onDelete,
    Function onClose,
  }) : super(
          key: key,
          backgroundColor: Theme.of(context).backgroundColor,
          leading: IconButton(
            icon: icon ??
                Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).accentColor,
                  size: 24,
                ),
            onPressed: () {
              onClose?.call();
              Navigator.pop(context);
            },
          ),
          title: Text(
            title ?? ' ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).accentColor,
            ),
          ),
          actions: <Widget>[
            if (onSave != null)
              FlatButton(
                onPressed: () {
                  onSave();
                  Navigator.pop(context);
                },
                child: Text(
                  'Save',
                  style: TextStyle(
                      fontSize: 16, color: Theme.of(context).primaryColor),
                ),
              ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                ),
              ),
            const SizedBox(width: 20)
          ],
        );
}
