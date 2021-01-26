import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../generated/l10n.dart';
import '../../../vendor_admin/common_widgets/common_scaffold.dart';
import '../../models/authentication_model.dart';
import '../../models/main_screen_model.dart';
import 'widgets/sale_stats_chart.dart';
import 'widgets/sale_stats_widget.dart';
import 'widgets/vendor_order_list.dart';

class VendorAdminMainScreen extends StatelessWidget {
  final bool isFromMv;

  const VendorAdminMainScreen({Key key, this.isFromMv = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final user =
        Provider.of<VendorAdminAuthenticationModel>(context, listen: false)
            .user;
    final mainModel = Provider.of<VendorAdminMainScreenModel>(context);

    return CommonScaffold(
      title: S.of(context).dashboard,
      leading: isFromMv
          ? FlatButton.icon(
              padding: EdgeInsets.zero,
              label: Text(
                S.of(context).home,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              icon: Icon(
                Icons.arrow_back_ios_outlined,
                size: 15,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            )
          : null,
      child: [
        const SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            const SizedBox(width: 15),
            Text(
              '${S.of(context).welcome} ${user?.name ?? ''}!',
              style: Theme.of(context).textTheme.headline6.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Expanded(
                child: SizedBox(
              width: 1,
            )),
            CircleAvatar(
              backgroundColor: const Color(0xFF808191),
              radius: 20,
              backgroundImage: user.picture != null && user.picture.isNotEmpty
                  ? NetworkImage(user.picture)
                  : null,
            ),
            const SizedBox(width: 15),
          ],
        ),
        const SizedBox(
          height: 20.0,
        ),
        Row(
          children: [
            const SizedBox(width: 15),
            SaleStatsWidget(
              gradient: const LinearGradient(
                  begin: Alignment(-1, -1),
                  end: Alignment(1, 1),
                  tileMode: TileMode.clamp,
                  colors: [
                    Color(0xFF1FF7FD),
                    Color(0xFFB33BF6),
                    Color(0xFFFF844B),
                    // Color(0xFFFF844B),
                  ],
                  stops: [
                    -0.4,
                    0.4,
                    1.0,
                  ]),
              title: S.of(context).earnings,
              amount: '${mainModel.saleStats?.earnings?.month ?? 0.0}',
              profitPercentage:
                  mainModel.saleStats?.earnings?.profitPercentage ?? 0.0,
            ),
            const SizedBox(width: 10),
            SaleStatsWidget(
              title: S.of(context).grossSales,
              amount: '${mainModel.saleStats?.grossSales?.month ?? 0.0}',
              profitPercentage:
                  mainModel.saleStats?.grossSales?.profitPercentage ?? 0.0,
            ),
            const SizedBox(width: 15),
          ],
        ),
        const SizedBox(
          height: 20.0,
        ),
        SaleStatsChart(saleStats: mainModel.saleStats),
        const SizedBox(
          height: 20.0,
        ),
        VendorOrderList(
          orders: mainModel.orders,
          maxOrder: 10,
          saleStats: mainModel.saleStats,
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}
