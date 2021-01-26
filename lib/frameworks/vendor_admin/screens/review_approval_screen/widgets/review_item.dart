import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../generated/l10n.dart';
import '../../../../../models/entities/review.dart';
import '../../../../../widgets/common/start_rating.dart';
import '../../../models/review_approval_screen_model.dart';
import '../../../models/review_pending_screen_model.dart';

class VendorAdminReviewItem extends StatelessWidget {
  final Review review;

  const VendorAdminReviewItem({Key key, this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    void _showModalBottomSheet() {
      final model = Provider.of<VendorAdminReviewApprovalScreenModel>(context,
          listen: false);
      final model2 = Provider.of<VendorAdminReviewPendingScreenModel>(context,
          listen: false);
      showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => CupertinoActionSheet(
                actions: [
                  CupertinoActionSheetAction(
                      onPressed: () {
                        if (review.isApproved == 1) {
                          model
                              .updateReviewState(review)
                              .then((value) => model2.getPendingReviews());
                        }
                        if (review.isApproved == 0) {
                          model2
                              .updateReviewState(review)
                              .then((value) => model.getApprovedReviews());
                        }
                        Navigator.pop(context);
                      },
                      child: Text(review.isApproved == 1
                          ? S.of(context).pending
                          : S.of(context).approve))
                ],
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(S.of(context).cancel),
                  isDefaultAction: true,
                ),
              ));
    }

    void _showReviewContent() {
      showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => Container(
                color: Theme.of(context).canvasColor,
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            review.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const Expanded(
                              child: SizedBox(
                            width: 1.0,
                          )),
                          Text(
                            review.createdAt.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        review.review,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ));
    }

    return Container(
      width: size.width,
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 20),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: Colors.grey.withOpacity(0.5))),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(
                review.name,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              )),
              Expanded(
                  child: Row(
                children: [
                  const Expanded(
                      child: SizedBox(
                    width: 1,
                  )),
                  Text(
                    review.createdAt.toString(),
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ))
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                flex: 1,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Center(
                    child: Icon(
                      FontAwesomeIcons.user,
                      size: 30.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 4,
                child: InkWell(
                  onTap: _showReviewContent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.email,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey),
                      ),
                      Text(
                        review.review,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            width: size.width,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(child: Text(S.of(context).rating)),
              Expanded(
                child: Row(
                  children: [
                    const Expanded(child: SizedBox(width: 10)),
                    SmoothStarRating(
                      rating: review.rating,
                      label: Container(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 1,
            width: size.width,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Expanded(
                child: SizedBox(
                  width: 1,
                ),
              ),
              InkWell(
                onTap: _showModalBottomSheet,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 15.0),
                  child: Center(
                    child: Text(S.of(context).change.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .caption
                            .copyWith(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
