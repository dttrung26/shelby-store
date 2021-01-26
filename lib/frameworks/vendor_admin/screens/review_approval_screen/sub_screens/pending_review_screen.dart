import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../models/review_pending_screen_model.dart';
import '../widgets/review_item.dart';
import '../widgets/review_loading_item.dart';

class PendingReviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<VendorAdminReviewPendingScreenModel>(
      builder: (context, model, _) => Container(
        width: size.width,
        height: size.height,
        child: SmartRefresher(
          controller: model.pendingController,
          onRefresh: model.getPendingReviews,
          onLoading: model.loadMorePendingReviews,
          enablePullUp: true,
          child: ListView.builder(
            itemBuilder: (context, index) =>
                model.state == VendorAdminReviewPendingScreenModelState.loading
                    ? VendorAdminReviewLoadingItem()
                    : VendorAdminReviewItem(
                        review: model.pendingReviews[index],
                      ),
            itemCount:
                model.state == VendorAdminReviewPendingScreenModelState.loading
                    ? 5
                    : model.pendingReviews.length,
          ),
        ),
      ),
    );
  }
}
