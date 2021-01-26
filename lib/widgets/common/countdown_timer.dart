import 'package:flutter/material.dart';

class CountDownTimer extends StatelessWidget {
  final Duration countdownDuration;
  final VoidCallback onEnd;
  final Color color;
  final Color textColor;

  const CountDownTimer(
    this.countdownDuration, {
    Key key,
    this.onEnd,
    this.color,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const _size = 22.0;

    return TweenAnimationBuilder<Duration>(
      duration: countdownDuration,
      tween: Tween(begin: countdownDuration, end: Duration.zero),
      onEnd: () {
        /// Timer ended
        if (onEnd != null) {
          onEnd();
        }
      },
      builder: (BuildContext context, Duration value, Widget child) {
        if (value.inMilliseconds == 0) {
          return const SizedBox();
        }
        final seconds = value.inSeconds % 60;
        final minutes = value.inMinutes % 60;
        final hours = value.inHours;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [hours, ':', minutes, ':', seconds]
              .map(
                (item) => item == ':'
                    ? Container(
                        alignment: Alignment.center,
                        height: _size,
                        child: Text(
                          '$item',
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                            color: color ?? Theme.of(context).accentColor,
                          ),
                        ),
                      )
                    : Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 2.0,
                          vertical: 1.0,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: _size,
                          minHeight: _size,
                        ),
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: color ?? Theme.of(context).primaryColorLight,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '$item',
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                color:
                                    textColor ?? Theme.of(context).accentColor,
                              )
                              .apply(fontSizeFactor: 0.9),
                        ),
                      ),
              )
              .toList(),
        );
      },
    );
  }
}
