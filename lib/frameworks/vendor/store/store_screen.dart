import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/vendor/store_model.dart';
import '../../../screens/base.dart';
import '../../../screens/search/widgets/search_box.dart';
import 'store_item.dart';

class StoreScreen extends StatefulWidget {
  @override
  _StoresState createState() => _StoresState();
}

class _StoresState extends BaseScreen<StoreScreen> {
  RefreshController _refreshController;
  String _currentName = '';

  StoreModel storeModel;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
  }

  @override
  void afterFirstLayout(BuildContext context) {
    storeModel = Provider.of<StoreModel>(context, listen: false);
    storeModel.loadStore();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: SearchBox(
            showCancelButton: true,
            onChanged: (val) {
              _currentName = val;
              storeModel.loadStore(name: _currentName);
            },
          ),
        ),
        Expanded(
          child: Consumer<StoreModel>(builder: (context, model, child) {
            if (model.stores == null) {
              return Container(
                height: MediaQuery.of(context).size.height - 150,
                child: Center(
                  child: kLoadingWidget(context),
                ),
              );
            }

            if (model.stores.isEmpty) {
              return Center(
                child: Text(S.of(context).dataEmpty),
              );
            }

            return SmartRefresher(
              enablePullDown: false,
              enablePullUp: !model.isEnd,
              controller: _refreshController,
              onLoading: () {
                model.loadStore(
                    name: _currentName,
                    onFinish: () {
                      _refreshController.loadComplete();
                    });
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: model.stores.length,
                itemBuilder: (_, index) => StoreItem(
                  store: model.stores[index],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
