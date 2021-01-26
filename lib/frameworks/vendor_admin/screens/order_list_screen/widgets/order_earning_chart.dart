import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import '../../../../../generated/l10n.dart';

import '../../../../../models/entities/sale_stats.dart';

class VendorAdminOrderEarningChart extends StatelessWidget {
  final SaleStats saleStats;

  const VendorAdminOrderEarningChart({Key key, this.saleStats})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    var earningsData;

    if (saleStats != null) {
      earningsData = [
        SaleSeries('1', saleStats.earnings?.week1 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.lightBlueAccent)),
        SaleSeries('2', saleStats.earnings?.week2 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.lightBlueAccent)),
        SaleSeries('3', saleStats.earnings?.week3 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.lightBlueAccent)),
        SaleSeries('4', saleStats.earnings?.week4 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.lightBlueAccent)),
        SaleSeries('5', saleStats.earnings?.week5 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.lightBlueAccent)),
      ];
      var max = 0;
      for (var i = 0; i < earningsData.length; i++) {
        if (earningsData[i].sale > earningsData[max].sale) {
          max = i;
        }
      }

      earningsData[max].color =
          charts.ColorUtil.fromDartColor(Colors.blueAccent);
    }

    final series = <charts.Series<SaleSeries, String>>[
      charts.Series(
        id: 'Earnings',
        data: earningsData,
        domainFn: (SaleSeries series, _) => series.week,
        measureFn: (SaleSeries series, _) => series.sale,
        colorFn: (SaleSeries series, _) => series.color,
        labelAccessorFn: (SaleSeries series, _) =>
            series.sale.toStringAsFixed(1),
      ),
    ];

    return Container(
      height: 200,
      width: 50,
      padding: const EdgeInsets.symmetric(horizontal: 80.0),
      child: Column(
        children: [
          Flexible(
            child: charts.BarChart(
              series,
              animate: true,
              domainAxis: const charts.OrdinalAxisSpec(
                showAxisLine: false,
                renderSpec: charts.NoneRenderSpec(),
              ),
              primaryMeasureAxis: const charts.NumericAxisSpec(
                  renderSpec: charts.NoneRenderSpec()),
              defaultRenderer: charts.BarRendererConfig(
                cornerStrategy: const charts.ConstCornerStrategy(5),
              ),
            ),
          ),
          Text(
            S.of(context).yourEarningsThisMonth,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (saleStats.earnings != null)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                saleStats.earnings.month.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 50.0,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
            ),
          if (saleStats.earnings == null)
            Text(
              S.of(context).noData,
              style: const TextStyle(
                fontSize: 50.0,
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
