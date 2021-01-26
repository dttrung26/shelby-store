import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

export 'package:flutter/cupertino.dart' show CupertinoNavigationBar;

class CommonScaffold extends StatelessWidget {
  final child;
  final title;
  final middle;
  final trailing;
  final leading;
  final navigationBar;
  final onRefresh;
  final controller;
  CommonScaffold({
    this.child,
    this.leading,
    this.middle,
    this.navigationBar,
    this.trailing,
    this.title,
    this.controller,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (navigationBar != null) {
      return Material(
        child: CupertinoPageScaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          navigationBar: navigationBar,
          child: child,
        ),
      );
    }

    if (onRefresh == null) {
      return Material(
        child: CupertinoPageScaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          child: CustomScrollView(
            controller: controller,
            cacheExtent: 2000.0,
            slivers: [
              CupertinoSliverNavigationBar(
                heroTag: 'key-$title',
                backgroundColor: Theme.of(context).backgroundColor,
                middle: middle,
                largeTitle: title != null
                    ? Text(
                        title,
                        style: TextStyle(color: Theme.of(context).accentColor),
                      )
                    : Container(),
                leading: leading,
                trailing: trailing,
                border: null,
              ),
              SliverList(
                delegate: SliverChildListDelegate(child),
              ),
            ],
          ),
        ),
      );
    }

    return Material(
      child: CupertinoPageScaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: CustomScrollView(
            controller: controller,
            cacheExtent: 2000.0,
            slivers: [
              CupertinoSliverNavigationBar(
                heroTag: 'key-$title',
                backgroundColor: Theme.of(context).backgroundColor,
                middle: middle,
                largeTitle: title != null
                    ? Text(
                        title,
                        style: TextStyle(color: Theme.of(context).accentColor),
                      )
                    : Container(),
                leading: leading,
                trailing: trailing,
                border: null,
              ),
              SliverList(
                delegate: SliverChildListDelegate(child),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
