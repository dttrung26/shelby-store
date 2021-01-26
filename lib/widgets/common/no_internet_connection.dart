import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import '../../generated/l10n.dart';

bool _isRefreshing = false;

class NoInternetConnection extends StatelessWidget {
  final Function onRefresh;

  const NoInternetConnection({
    Key key,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 220,
          child: FlareActor(
            'assets/images/no_internet.flr',
            animation: 'Untitled',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: Text(
            S.of(context).noInternetConnection,
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: ButtonTheme(
            height: 44,
            child: StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return _isRefreshing
                    ? Container(
                        padding: const EdgeInsets.all(8),
                        width: 48,
                        height: 48,
                        child: const CircularProgressIndicator(),
                      )
                    : RaisedButton(
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        elevation: 0.1,
                        onPressed: () async {
                          setState(() {
                            _isRefreshing = true;
                          });
                          await onRefresh();
                          setState(() {
                            _isRefreshing = false;
                          });
                        },
                        child: Text(
                          S.of(context).refresh.toUpperCase(),
                        ),
                      );
              },
            ),
          ),
        ),
      ],
    );
  }
}
