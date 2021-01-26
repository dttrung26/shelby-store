import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../models/entities/sale_stats.dart';

class SaleStatsChart extends StatelessWidget {
  final SaleStats saleStats;

  const SaleStatsChart({Key key, this.saleStats}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var grossSaleData;
    var earningsData;

    grossSaleData = [
      SaleSeries('Week 1', 0, charts.ColorUtil.fromDartColor(Colors.blue)),
      SaleSeries('Week 2', 0, charts.ColorUtil.fromDartColor(Colors.blue)),
      SaleSeries('Week 3', 0, charts.ColorUtil.fromDartColor(Colors.blue)),
      SaleSeries('Week 4', 0, charts.ColorUtil.fromDartColor(Colors.blue)),
      SaleSeries('Week 5', 0, charts.ColorUtil.fromDartColor(Colors.blue)),
    ];

    earningsData = [
      SaleSeries('Week 1', 0, charts.ColorUtil.fromDartColor(Colors.red)),
      SaleSeries('Week 2', 0, charts.ColorUtil.fromDartColor(Colors.red)),
      SaleSeries('Week 3', 0, charts.ColorUtil.fromDartColor(Colors.red)),
      SaleSeries('Week 4', 0, charts.ColorUtil.fromDartColor(Colors.red)),
      SaleSeries('Week 5', 0, charts.ColorUtil.fromDartColor(Colors.red)),
    ];

    if (saleStats != null) {
      grossSaleData = [
        SaleSeries('Week 1', saleStats.grossSales?.week1 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.blue)),
        SaleSeries('Week 2', saleStats.grossSales?.week2 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.blue)),
        SaleSeries('Week 3', saleStats.grossSales?.week3 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.blue)),
        SaleSeries('Week 4', saleStats.grossSales?.week4 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.blue)),
        SaleSeries('Week 5', saleStats.grossSales?.week5 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.blue)),
      ];

      earningsData = [
        SaleSeries('Week 1', saleStats.earnings?.week1 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.red)),
        SaleSeries('Week 2', saleStats.earnings?.week2 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.red)),
        SaleSeries('Week 3', saleStats.earnings?.week3 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.red)),
        SaleSeries('Week 4', saleStats.earnings?.week4 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.red)),
        SaleSeries('Week 5', saleStats.earnings?.week5 ?? 0.0,
            charts.ColorUtil.fromDartColor(Colors.red)),
      ];
    }

    final series = <charts.Series<SaleSeries, String>>[
      charts.Series(
        id: 'Gross Sales',
        data: grossSaleData,
        domainFn: (SaleSeries series, _) => series.week,
        measureFn: (SaleSeries series, _) => series.sale,
        colorFn: (SaleSeries series, _) => charts.Color.transparent,
      ),
      charts.Series(
        id: 'Gross Sales',
        data: grossSaleData,
        domainFn: (SaleSeries series, _) => series.week,
        measureFn: (SaleSeries series, _) => series.sale,
        colorFn: (SaleSeries series, _) => series.color,
      ),
      charts.Series(
        id: 'Earnings',
        data: earningsData,
        domainFn: (SaleSeries series, _) => series.week,
        measureFn: (SaleSeries series, _) => series.sale,
        colorFn: (SaleSeries series, _) => series.color,
      ),
      charts.Series(
        id: 'Earnings',
        data: earningsData,
        domainFn: (SaleSeries series, _) => series.week,
        measureFn: (SaleSeries series, _) => series.sale,
        colorFn: (SaleSeries series, _) => charts.Color.transparent,
      ),
    ];

    final simpleCurrencyFormatter =
        charts.BasicNumericTickFormatterSpec.fromNumberFormat(
            NumberFormat.compactSimpleCurrency(decimalDigits: 0));
    return Container(
      height: 260,
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9.0),
        color: Theme.of(context).primaryColorLight,
      ),
      child: charts.BarChart(
        series,
        animate: true,
        primaryMeasureAxis: charts.NumericAxisSpec(
          tickFormatterSpec: simpleCurrencyFormatter,
        ),
      ),
    );
  }
}
