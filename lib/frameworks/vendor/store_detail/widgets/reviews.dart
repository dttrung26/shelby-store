import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../../../../common/constants.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/index.dart' show Review;
import '../../../../screens/base.dart';
import '../../../../services/index.dart';

class Reviews extends StatefulWidget {
  final int storeId;

  Reviews({this.storeId});

  @override
  _ReviewsState createState() => _ReviewsState();
}

class _ReviewsState extends BaseScreen<Reviews> {
  List<Review> list = [];
  bool isFetching = true;

  @override
  void afterFirstLayout(BuildContext context) async {
    try {
      list = await Services().api.getReviewsStore(storeId: widget.storeId);
      setState(() {
        isFetching = false;
      });
    } catch (e) {
      setState(() {
        isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isFetching) return kLoadingWidget(context);
    if (!isFetching && list.isEmpty) {
      return Center(child: Text(S.of(context).noReviews));
    }

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 20.0),
          child: Wrap(
            children: <Widget>[
              for (var i = 0; i < list.length; i++)
                ReviewItem(
                  review: list[i],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReviewItem extends StatelessWidget {
  final Review review;

  ReviewItem({this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).accentColor.withOpacity(0.1), width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: ExtendedImage.network(
                  review.avatar,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  cache: true,
                  enableLoadState: false,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    review.name,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).accentColor),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  SmoothStarRating(
                      allowHalfRating: true,
                      starCount: 5,
                      rating: review.rating ?? 0.0,
                      size: 15,
                      color: Theme.of(context).primaryColor,
                      borderColor: Theme.of(context).primaryColor,
                      spacing: 0.0)
                ],
              )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            review.review,
            style:
                TextStyle(fontSize: 16, color: Theme.of(context).accentColor),
          ),
          const SizedBox(
            height: 8,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(DateFormat.yMMMMd('en_US').format(review.createdAt),
                style: TextStyle(
                    fontSize: 12, color: Theme.of(context).accentColor)),
          )
        ],
      ),
    );
  }
}
