import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../models/entities/review.dart';
import '../../../models/entities/user.dart';
import '../services/vendor_admin.dart';

enum VendorAdminReviewPendingScreenModelState { loading, loaded, loadMore }

class VendorAdminReviewPendingScreenModel extends ChangeNotifier {
  /// Service
  final _services = VendorAdminApi();

  /// State
  var state = VendorAdminReviewPendingScreenModelState.loaded;

  /// Your Other Variables Go Here
  List<Review> pendingReviews = [];
  final pendingController = RefreshController();
  int _pendingReviewsPage = 1;
  User user;

  /// Constructor
  VendorAdminReviewPendingScreenModel(this.user) {
    getPendingReviews();
  }

  /// Update state
  void _updateState(state) {
    this.state = state;
    notifyListeners();
  }

  /// Your Defined Functions Go Here
  Future<void> getPendingReviews() async {
    if (state == VendorAdminReviewPendingScreenModelState.loading ||
        state == VendorAdminReviewPendingScreenModelState.loadMore) {
      return;
    }
    pendingController.loadComplete();
    _updateState(VendorAdminReviewPendingScreenModelState.loading);
    _pendingReviewsPage = 1;
    pendingReviews.clear();
    var list = await _services.getVendorReviews(
        cookie: user.cookie,
        status: 'pending',
        perPage: 10,
        page: _pendingReviewsPage);
    pendingReviews.addAll(list);
    pendingController.refreshCompleted();
    _updateState(VendorAdminReviewPendingScreenModelState.loaded);
  }

  Future<void> loadMorePendingReviews() async {
    if (state == VendorAdminReviewPendingScreenModelState.loading ||
        state == VendorAdminReviewPendingScreenModelState.loadMore) {
      return;
    }
    if (pendingController.footerMode?.value == LoadStatus.noMore) {
      return;
    }
    _updateState(VendorAdminReviewPendingScreenModelState.loadMore);
    _pendingReviewsPage++;
    var list = await _services.getVendorReviews(
        cookie: user.cookie,
        status: 'pending',
        perPage: 10,
        page: _pendingReviewsPage);
    if (list.isEmpty) {
      pendingController.loadNoData();
      _updateState(VendorAdminReviewPendingScreenModelState.loaded);
      return;
    }
    pendingReviews.addAll(list);
    pendingController.loadComplete();
    _updateState(VendorAdminReviewPendingScreenModelState.loaded);
  }

  Future<void> updateReviewState(Review review) async {
    await _services
        .updateReviewStatus(
            cookie: user.cookie,
            reviewId: review.id,
            isApproved: review.isApproved != 1)
        .then((value) => getPendingReviews());
  }
}
