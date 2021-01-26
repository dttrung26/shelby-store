import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../generated/l10n.dart';
import '../../colors_config/theme.dart';
import '../../common_widgets/common_scaffold.dart';
import '../../models/product_list_screen_model.dart';
import '../product_add_screen/product_add_screen.dart';
import 'widgets/loading_widget.dart';
import 'widgets/product_list_card_widget.dart';

class VendorAdminProductListScreen extends StatefulWidget {
  @override
  _VendorAdminProductListScreenState createState() =>
      _VendorAdminProductListScreenState();
}

class _VendorAdminProductListScreenState
    extends State<VendorAdminProductListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<VendorAdminProductListScreenModel>(context, listen: false)
          .getVendorProductList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final _textStyle = Theme.of(context).accentTextTheme.bodyText1.copyWith(
          color: Theme.of(context).accentColor,
        );
    final model = Provider.of<VendorAdminProductListScreenModel>(context);
    return CommonScaffold(
      onRefresh: model.getVendorProductList,
      controller: model.controller,
      title: S.of(context).products,
      trailing: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () => Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => ChangeNotifierProvider.value(
              value: model,
              child: VendorAdminProductAddScreen(
                onCallBack: model.getVendorProductList,
              ),
            ),
          ),
        ),
      ),
      child: [
        Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5.0,
                  vertical: 4,
                ),
                height: 40,
                margin: const EdgeInsets.only(bottom: 6, left: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Theme.of(context).primaryColorLight,
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.search,
                      color: Theme.of(context).accentColor.withOpacity(0.7),
                    ),
                    Expanded(
                      child: TextField(
                        controller: model.searchController,
                        focusNode: model.searchFocusNode,
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: (val) => model.searchProduct(),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: model.clearSearchResults,
                            icon: const Icon(
                              Icons.cancel,
                              size: 18,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(5.0),
                          isDense: true,
                          fillColor: ColorsConfig.searchBackgroundColor,
                          hintText: S.of(context).search,
                          hintStyle: _textStyle.copyWith(
                            color:
                                Theme.of(context).accentColor.withOpacity(0.5),
                          ),
                        ),
                        style: _textStyle.copyWith(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
        if (model.state == VendorAdminProductListScreenModelState.loading)
          ...List.generate(
              5, (index) => VendorAdminProductListCardLoadingWidget()),
        if (model.state == VendorAdminProductListScreenModelState.empty)
          Center(
            child: Text(S.of(context).noProduct),
          ),
        if (model.state == VendorAdminProductListScreenModelState.loaded &&
            model.lstSearchedVendorProduct.isNotEmpty)
          ...List.generate(
            model.lstSearchedVendorProduct.length,
            (index) {
              return VendorAdminProductListCardWidget(
                product: model.lstSearchedVendorProduct[index],
              );
            },
          ),
        if ((model.state == VendorAdminProductListScreenModelState.loaded ||
                model.state ==
                    VendorAdminProductListScreenModelState.loadMore) &&
            model.lstSearchedVendorProduct.isEmpty &&
            model.searchController.text.isEmpty)
          ...List.generate(
            model.lstVendorProduct.length,
            (index) {
              return VendorAdminProductListCardWidget(
                product: model.lstVendorProduct[index],
              );
            },
          ),
        if (model.state == VendorAdminProductListScreenModelState.loaded &&
            model.lstSearchedVendorProduct.isEmpty &&
            model.searchController.text.isNotEmpty)
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Text(S.of(context).noResultFound),
            ],
          ),
        const SizedBox(height: 100),
      ],
    );
  }
}
