import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../models/entities/order.dart';
import '../../../../models/entities/user.dart';
import '../../services/vendor_admin.dart';

enum VendorAdminOrderListScreenModelState { loading, loaded }

class VendorAdminOrderListScreenModel extends ChangeNotifier {
  /// Service
  final _services = VendorAdminApi();

  /// State
  var state = VendorAdminOrderListScreenModelState.loaded;

  /// Your Other Variables Go Here
  String status;
  List<Order> orders = [];
  List<Order> searchedOrders = [];
  var _page = 1;
  final int _perPage = 10;
  User user;
  RefreshController orderController = RefreshController();
  final TextEditingController searchController = TextEditingController();

  /// Constructor
  VendorAdminOrderListScreenModel(this.user, this.orders);

  /// Update state
  void _updateState(state) {
    /// Use try/catch to ignore the dispose error in case of
    /// user immediately goes back after accessing a new route
    try {
      this.state = state;
      notifyListeners();
    } catch (e) {
      return;
    }
  }

  /// Your Defined Functions Go Here
  void updateStatusOption(String status) {
    this.status = status;
    _updateState(VendorAdminOrderListScreenModelState.loaded);
  }

  Future<void> getVendorOrders() async {
    _updateState(VendorAdminOrderListScreenModelState.loading);
    _page = 1;
    orders = await _services.getVendorAdminOrders(
        cookie: user.cookie, page: _page, status: status, perPage: _perPage);
    orderController.loadComplete();
    _updateState(VendorAdminOrderListScreenModelState.loaded);
  }

  Future<void> loadMoreVendorOrders() async {
    _page++;
    var list = await _services.getVendorAdminOrders(
        cookie: user.cookie, page: _page, status: status, perPage: _perPage);
    if (list.isEmpty) {
      orderController.loadNoData();
    } else {
      orderController.loadComplete();
      orders.addAll(list);
    }
    _updateState(VendorAdminOrderListScreenModelState.loaded);
  }

  void searchVendorOrders() {
    EasyDebounce.cancel('searchProduct');
    EasyDebounce.debounce(
        'searchVendorOrders', const Duration(milliseconds: 500), () async {
      _updateState(VendorAdminOrderListScreenModelState.loading);
      if (searchController.text != '') {
        searchedOrders.clear();
        searchedOrders = await _services.getVendorAdminOrders(
            cookie: user.cookie,
            page: 1,
            search: searchController.text,
            perPage: _perPage);
      } else {
        searchedOrders.clear();
      }
      _updateState(VendorAdminOrderListScreenModelState.loaded);
    });
  }

  Future<void> updateOrder(Order order, String status,
      {String customerNote}) async {
    _updateState(VendorAdminOrderListScreenModelState.loading);
    await _services.updateOrder(order.id,
        status: status, customerNote: customerNote, token: user.cookie);
    await getVendorOrders();
    _updateState(VendorAdminOrderListScreenModelState.loaded);
  }
}
