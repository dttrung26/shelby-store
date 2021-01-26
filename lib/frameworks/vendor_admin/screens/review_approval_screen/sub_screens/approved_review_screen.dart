import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../models/review_approval_screen_model.dart';
import '../widgets/review_item.dart';
import '../widgets/review_loading_item.dart';

class ApprovedReviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<VendorAdminReviewApprovalScreenModel>(
      builder: (context, model, _) => Container(
        width: size.width,
        height: size.height,
        child: SmartRefresher(
          controller: model.approvedController,
          onRefresh: model.getApprovedReviews,
          onLoading: model.loadMoreApprovedReviews,
          enablePullUp: true,
          child: ListView.builder(
            itemBuilder: (context, index) =>
                model.state == VendorAdminReviewApprovalScreenModelState.loading
                    ? VendorAdminReviewLoadingItem()
                    : VendorAdminReviewItem(
                        review: model.approvedReviews[index],
                      ),
            itemCount:
                model.state == VendorAdminReviewApprovalScreenModelState.loading
                    ? 5
                    : model.approvedReviews.length,
          ),
        ),
        // child: SingleChildScrollView(
        //   child: Column(
        //     children: List.generate(
        //         model.state == VendorAdminReviewApprovalScreenModelState.loading
        //             ? 5
        //             : model.approvedReviews.length,
        //         (index) => model.state ==
        //                 VendorAdminReviewApprovalScreenModelState.loading
        //             ? VendorAdminReviewLoadingItem()
        //             : VendorAdminReviewItem(
        //                 review: model.approvedReviews[index],
        //               )),
        //   ),
        // ),
      ),
    );
  }
}
