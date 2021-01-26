import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../generated/l10n.dart';
import '../../../colors_config/theme.dart';
import '../order_list_screen_model.dart';

class VendorAdminOrderSearch extends StatelessWidget {
  final Function updateOrdersInHomeScreen;
  final TextEditingController controller;
  final Function onSearchOrder;
  const VendorAdminOrderSearch({
    Key key,
    this.updateOrdersInHomeScreen,
    @required this.controller,
    this.onSearchOrder,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _textStyle = Theme.of(context)
        .accentTextTheme
        .bodyText1
        .copyWith(color: Colors.white);

    void _showFilterOptions(VendorAdminOrderListScreenModel model) {
      showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (subContext) => CupertinoActionSheet(
                actions: [
                  CupertinoActionSheetAction(
                      onPressed: () {
                        model.updateStatusOption(null);
                        model.getVendorOrders().then((value) =>
                            updateOrdersInHomeScreen(list: model.orders));
                        Navigator.of(subContext).pop();
                      },
                      child: Text(S.of(context).all)),
                  CupertinoActionSheetAction(
                      onPressed: () {
                        model.updateStatusOption('pending');
                        model.getVendorOrders();
                        Navigator.of(subContext).pop();
                      },
                      child: Text(S.of(context).orderStatusPending)),
                  CupertinoActionSheetAction(
                      onPressed: () {
                        model.updateStatusOption('refunded');
                        model.getVendorOrders();
                        Navigator.of(subContext).pop();
                      },
                      child: Text(S.of(context).orderStatusRefunded)),
                  CupertinoActionSheetAction(
                      onPressed: () {
                        model.updateStatusOption('completed');
                        model.getVendorOrders();
                        Navigator.of(subContext).pop();
                      },
                      child: Text(S.of(context).orderStatusCompleted)),
                  CupertinoActionSheetAction(
                      onPressed: () {
                        model.updateStatusOption('processing');
                        model.getVendorOrders();
                        Navigator.of(subContext).pop();
                      },
                      child: Text(S.of(context).orderStatusProcessing)),
                ],
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(subContext).pop(),
                  child: Text(S.of(context).cancel),
                  isDefaultAction: true,
                ),
              ));
    }

    return Consumer<VendorAdminOrderListScreenModel>(
      builder: (context, model, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: Column(
          children: [
            InkWell(
              onTap: () => _showFilterOptions(model),
              child: Container(
                decoration: BoxDecoration(
                  color: ColorsConfig.searchBackgroundColor,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(
                      model.status?.toUpperCase() ??
                          S.of(context).filter.toUpperCase(),
                      style: _textStyle,
                    )),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _textStyle.color,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 5.0,
                vertical: 1.0,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 0.5),
                borderRadius: BorderRadius.circular(20.0),
                color: ColorsConfig.searchBackgroundColor,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      textAlign: TextAlign.start,
                      controller: controller,
                      onChanged: (val) => onSearchOrder(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        isDense: true,
                        fillColor: ColorsConfig.searchBackgroundColor,
                        hintText: S.of(context).searchOrderId,
                        hintStyle: _textStyle,
                      ),
                      style: _textStyle,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
