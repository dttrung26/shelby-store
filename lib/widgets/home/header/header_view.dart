import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../common/countdown_timer.dart';

class HeaderView extends StatelessWidget {
  final String headerText;
  final VoidCallback callback;
  final bool showSeeAll;
  final bool showCountdown;
  final Duration countdownDuration;
  final double margin;

  HeaderView({
    this.headerText,
    this.showSeeAll = false,
    Key key,
    this.callback,
    this.margin = 10.0,
    this.showCountdown = false,
    this.countdownDuration = const Duration(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width,
      color: Theme.of(context).backgroundColor,
      child: Container(
        // width: screenSize.width / (2 / (screenSize.height / screenSize.width)),
        margin: EdgeInsets.only(top: margin),
        padding: EdgeInsets.only(
          left: 17.0,
          top: margin,
          right: 15.0,
          bottom: margin,
        ),
        child: Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headerText ?? '',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  if (showCountdown)
                    Row(
                      children: [
                        Text(
                          S.of(context).endsIn('').toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              .copyWith(
                                color: Theme.of(context)
                                    .accentColor
                                    .withOpacity(0.8),
                              )
                              .apply(fontSizeFactor: 0.6),
                        ),
                        CountDownTimer(countdownDuration),
                      ],
                    ),
                ],
              ),
            ),
            if (showSeeAll)
              InkResponse(
                onTap: callback,
                child: Text(
                  S.of(context).seeAll,
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .copyWith(color: Theme.of(context).primaryColor),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
