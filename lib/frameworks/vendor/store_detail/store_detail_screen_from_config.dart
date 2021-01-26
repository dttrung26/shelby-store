import 'package:flutter/material.dart';
import '../../../common/constants.dart';

import '../../../models/vendor/store_model.dart';
import '../../../services/index.dart';
import '../store_detail/store_detail_screen.dart';

class StoreDetailScreenFromConfig extends StatefulWidget {
  final storeId;

  const StoreDetailScreenFromConfig({Key key, this.storeId}) : super(key: key);
  @override
  _StoreDetailScreenFromConfigState createState() =>
      _StoreDetailScreenFromConfigState();
}

class _StoreDetailScreenFromConfigState
    extends State<StoreDetailScreenFromConfig> {
  final Services _services = Services();
  Store store;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      store = await _services.api.getStoreInfo(widget.storeId);
      if (store == null) {
        Navigator.pop(context);
        return;
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: kLoadingWidget(context),
      );
    }
    return StoreDetailScreen(
      store: store,
    );
  }
}
