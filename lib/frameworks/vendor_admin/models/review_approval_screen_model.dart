import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../models/entities/review.dart';
import '../../../models/entities/user.dart';
import '../services/vendor_admin.dart';

enum VendorAdminReviewApprovalScreenModelState { loading, loaded, loadMore }

class VendorAdminReviewApprovalScreenModel extends ChangeNotifier {
  /// Service
  final _services = VendorAdminApi();

  /// State
  var state = VendorAdminReviewApprovalScreenModelState.loaded;

  /// Your Other Variables Go Here
  List<Review> approvedReviews = [];
  RefreshController approvedController =
      RefreshController(initialRefresh: false);
  int _approvedReviewsPage = 1;
  User user;

  /// Constructor
  VendorAdminReviewApprovalScreenModel(this.user) {
    getApprovedReviews();
  }

  /// Update state
  void _updateState(state) {
    this.state = state;
    notifyListeners();
  }

  /// Your Defined Functions Go Here
  Future<void> getApprovedReviews() async {
    if (state == VendorAdminReviewApprovalScreenModelState.loading ||
        state == VendorAdminReviewApprovalScreenModelState.loadMore) {
      return;
    }
    approvedController.loadComplete();
    _updateState(VendorAdminReviewApprovalScreenModelState.loading);
    _approvedReviewsPage = 1;
    approvedReviews.clear();
    var list = await _services.getVendorReviews(
        cookie: user.cookie,
        status: 'approved',
        perPage: 10,
        page: _approvedReviewsPage);
    approvedReviews.addAll(list);
    approvedController.refreshCompleted();
    _updateState(VendorAdminReviewApprovalScreenModelState.loaded);
  }

  Future<void> loadMoreApprovedReviews() async {
    if (state == VendorAdminReviewApprovalScreenModelState.loading ||
        state == VendorAdminReviewApprovalScreenModelState.loadMore) {
      return;
    }
    _updateState(VendorAdminReviewApprovalScreenModelState.loadMore);
    _approvedReviewsPage++;
    var list = await _services.getVendorReviews(
        cookie: user.cookie,
        status: 'approved',
        perPage: 10,
        page: _approvedReviewsPage);
    if (list.isEmpty) {
      approvedController.loadNoData();
      _updateState(VendorAdminReviewApprovalScreenModelState.loaded);
      return;
    }
    approvedReviews.addAll(list);
    approvedController.loadComplete();
    _updateState(VendorAdminReviewApprovalScreenModelState.loaded);
  }

  Future<void> updateReviewState(Review review) async {
    await _services
        .updateReviewStatus(
            cookie: user.cookie,
            reviewId: review.id,
            isApproved: review.isApproved != 1)
        .then((value) => getApprovedReviews());
  }
}
