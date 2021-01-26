import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../common/constants.dart';
import '../services/index.dart';
import 'entities/order.dart';
import 'user_model.dart';

enum OrderListModelState { loading, loaded, loadMore }

class OrderListModel extends ChangeNotifier {
  /// Service
  final _services = Services();

  /// State
  var state = OrderListModelState.loaded;

  /// Your Other Variables Go Here
  RefreshController refreshController = RefreshController();
  List<Order> orders = [];
  int _page = 1;
  bool isEnd = false;
  UserModel userModel;

  /// Constructor
  OrderListModel(this.userModel) {
    getMyOrder();
  }

  /// Update state
  void _updateState(state) {
    this.state = state;
    notifyListeners();
  }

  /// Your Defined Functions Go Here

  Future<void> getMyOrder() async {
    if (state == OrderListModelState.loading ||
        state == OrderListModelState.loadMore) {
      return;
    }
    _updateState(OrderListModelState.loading);

    _page = 1;
    orders.clear();
    var list =
        await _services.api.getMyOrders(userModel: userModel, page: _page);
    isEnd = list.isEmpty || list.length < ApiPageSize;
    orders.addAll(list);
    refreshController.refreshCompleted();
    _updateState(OrderListModelState.loaded);
  }

  Future<void> loadMore() async {
    if (state == OrderListModelState.loading ||
        state == OrderListModelState.loadMore) {
      return;
    }
    _updateState(OrderListModelState.loadMore);

    _page++;
    var list =
        await _services.api.getMyOrders(userModel: userModel, page: _page);
    isEnd = list.isEmpty || list.length < ApiPageSize;
    if (list.isEmpty) {
      refreshController.loadNoData();
      _updateState(OrderListModelState.loaded);
      return;
    }

    orders.addAll(list);
    refreshController.loadComplete();

    _updateState(OrderListModelState.loaded);
  }
}
