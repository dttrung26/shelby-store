import 'package:flutter/material.dart';

import '../../../../../generated/l10n.dart';

class SaleStatsWidget extends StatelessWidget {
  final title;
  final amount;
  final profitPercentage;
  final color;
  final gradient;

  const SaleStatsWidget(
      {Key key,
      @required this.title,
      @required this.amount,
      this.color,
      this.gradient,
      @required this.profitPercentage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(top: 20.0, right: 20.0, bottom: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: color ?? Theme.of(context).primaryColorLight,
          gradient: gradient,
        ),
        height: 120,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: gradient != null
                          ? Colors.white
                          : Theme.of(context).accentColor,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    amount,
                    style: Theme.of(context).textTheme.headline4.copyWith(
                          fontWeight: FontWeight.w600,
                          color: gradient != null
                              ? Colors.white
                              : Theme.of(context).accentColor,
                        ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          profitPercentage > 0.0
                              ? Icons.trending_up_outlined
                              : Icons.trending_down_outlined,
                          color: gradient != null
                              ? Colors.white
                              : profitPercentage > 0.0
                                  ? Colors.green
                                  : Colors.red,
                          size: 20.0,
                        ),
                        const SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          '${profitPercentage > 0.0 ? '+' : ''}$profitPercentage%',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            color: gradient != null
                                ? Colors.white
                                : profitPercentage > 0.0
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (gradient == null)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  height: 10,
                  width: 20,
                  decoration: BoxDecoration(
                    color: title == S.of(context).earnings
                        ? Colors.red
                        : Colors.blue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
