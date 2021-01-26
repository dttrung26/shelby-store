import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/entities/index.dart';
import '../../../models/index.dart';
import '../../../widgets/common/start_rating.dart';
import '../../../widgets/product/heart_button.dart';
import '../screens/detail/index.dart';

class ListingCardView extends StatelessWidget {
  final Product item;
  final width;
  final height;
  final String layout;
  final kSize size;
  final bool showCart;
  final bool showHeart;
  final bool disableTap;

  ListingCardView(
      {this.item,
      this.width,
      this.height,
      this.layout,
      this.size = kSize.medium,
      this.showHeart = false,
      this.disableTap = false,
      this.showCart = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = Tools.isTablet(MediaQuery.of(context));
    var titleFontSize = isTablet ? 20.0 : 14.0;
    var starSize = isTablet ? 20.0 : 12.0;
    var subTitleFontSize = isTablet ? 16.0 : 11.0;
    var distanceFontSize = isTablet ? 16.0 : 12.0;
    const paddingListItem = EdgeInsets.symmetric(vertical: 10.0);

    if (item == null) return Container();

    void onTapProduct() {
      Provider.of<RecentModel>(context, listen: false).addRecentProduct(item);
      if (item.imageFeature == '') return;
      Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute<void>(
        builder: (BuildContext context) => ListingDetail(product: item),
      ));
    }

    var hasTagLine = item?.tagLine != null;
    var hasPrice = isNotBlank(item.priceRange) &&
        item.priceRange != '\$\$' &&
        item.priceRange != null;
    var hasRating = item.averageRating != null && item.averageRating != 0;
    var hasName = isNotBlank(item.name);
    var hasDistance = item.distance != null;

    var widgets = <Widget>[];

    if (hasName) {
      widgets.add(Column(children: [
        Text(
          item.name,
          style: TextStyle(fontSize: titleFontSize),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6)
      ]));
    }
    if (hasDistance) {
      widgets.add(Text(item.distance,
          style: TextStyle(fontSize: distanceFontSize), maxLines: 1));
    }
    if (hasTagLine) {
      widgets.add(Column(
        children: <Widget>[
          Text(
            item.tagLine + '...',
            style: TextStyle(
                fontSize: subTitleFontSize, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 6),
        ],
      ));
    }
    if (item.price != null && item.regularPrice != null) {
      widgets.add(Row(
        children: <Widget>[
          const SizedBox(
            width: 2,
          ),
          Text(Tools.getCurrencyFormatted(item.regularPrice, null),
              style: TextStyle(color: theme.accentColor, fontSize: 12)),
          const Text(' - '),
          Text(Tools.getCurrencyFormatted(item.price, null),
              style: TextStyle(color: theme.accentColor, fontSize: 12))
        ],
      ));
    }
    if (item.price == null && item.regularPrice != null) {
      widgets.add(Row(
        children: <Widget>[
          Icon(
            Icons.monetization_on,
            size: 14,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(
            width: 2,
          ),
          Text(Tools.getCurrencyFormatted(item.regularPrice, null),
              style: TextStyle(color: theme.accentColor, fontSize: 12)),
        ],
      ));
    }

    if (item.price != null && item.regularPrice == null) {
      widgets.add(Row(
        children: <Widget>[
          Icon(
            Icons.monetization_on,
            size: 14,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(
            width: 2,
          ),
          Text(Tools.getCurrencyFormatted(item.price, null),
              style: TextStyle(color: theme.accentColor, fontSize: 12))
        ],
      ));
    }
//    if (hasPrice && layout != 'horizonItem') {
//      widgets.add(
//        Column(
//          children: <Widget>[
//            Text(
//              Tools.getCurrecyFormatted(item.listing.priceRange),
//              style: Theme.of(context)
//                  .textTheme
//                  .headline
//                  .copyWith(fontSize: priceFontSize, color: theme.hintColor),
//            ),
//            SizedBox(height: 8),
//          ],
//        ),
//      );
//    }
    if (hasRating) {
      widgets.add(Row(
        children: <Widget>[
          hasRating
              ? SmoothStarRating(
                  allowHalfRating: true,
                  starCount: 5,
                  rating: item.averageRating ?? 0.0,
                  size: starSize,
                  color: theme.primaryColor,
                  borderColor: theme.primaryColor,
                  spacing: 0.0,
                  label: Container(),
                )
              : Container(child: null),
          if (item.totalReview != null)
            if (item.totalReview > 0)
              Text(
                '(${item.totalReview})',
                style: TextStyle(
                    fontSize: 12, color: Theme.of(context).accentColor),
              ),
        ],
      ));
    }

    if (layout == 'list') {
      return InkWell(
        onTap: onTapProduct,
        child: Container(
          color: Theme.of(context).cardColor,
          padding: paddingListItem,
          child: Row(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3.0),
                    child: Tools.image(
                      url: item.imageFeature ?? '',
                      width: width,
                      size: size,
                      height: height ?? width * 1.2,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (showHeart)
                    Positioned(
                      top: -7,
                      right: -7,
                      child: HeartButton(
                        product: item,
                        size: 18,
                        color: Colors.white,
                      ),
                    )
                ],
              ),
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: height,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[...widgets],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () =>
          disableTap == null || disableTap == false ? onTapProduct() : {},
      child: Stack(
        children: <Widget>[
          Container(
            color: Theme.of(context).cardColor,
            margin: const EdgeInsets.only(right: 10.0),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3.0),
                    child: Stack(
                      children: <Widget>[
                        Tools.image(
                          url: item.imageFeature ?? '',
                          width: width,
                          size: kSize.medium,
                          isResize: true,
                          height: height ?? width * 1.2,
                          fit: BoxFit.cover,
                        ),
                        if (item.featured == 'on')
                          Container(
                            margin: const EdgeInsets.only(top: 4, left: 4),
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .backgroundColor
                                  .withOpacity(0.7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(
                                  Icons.stars,
                                  size: 10,
                                  color: Colors.pink,
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  S.of(context).featured,
                                  style: const TextStyle(fontSize: 9),
                                )
                              ],
                            ),
                          ),
                        if (disableTap)
                          Positioned(
                            right: 5,
                            top: 5,
                            child: CircleAvatar(
                              backgroundColor: Colors.white54,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.open_in_new,
                                  size: 18,
                                ),
                                onPressed: onTapProduct,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                  Container(
                      width: width,
                      alignment: Alignment.topLeft,
                      padding:
                          const EdgeInsets.only(top: 7, bottom: 10, left: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(
                            height: 5,
                          ),
                          if (isNotBlank(item.categoryName))
                            Text(
                              item.categoryName.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          const SizedBox(
                            height: 2,
                          ),
                          if (isNotBlank(item.categoryName))
                            const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  HtmlUnescape().convert(item.name),
                                  style: TextStyle(
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              item.verified ?? false
                                  ? Icon(
                                      Icons.verified_user,
                                      size: 18,
                                      color: Theme.of(context).accentColor,
                                    )
                                  : Container()
                            ],
                          ),
                          const SizedBox(height: 6),
                          item.tagLine != null
                              ? Text(
                                  '${item.tagLine}',
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: subTitleFontSize,
                                  ),
                                )
                              : Container(),
                          const SizedBox(height: 6),
                          if (item.price != null && item.regularPrice != null)
                            Row(
                              children: <Widget>[
//                                  Icon(
//                                    Icons.monetization_on,
//                                    size: 14,
//                                    color: Theme.of(context).primaryColor,
//                                  ),
//                                  SizedBox(
//                                    width: 2,
//                                  ),
                                Text(
                                    Tools.getCurrencyFormatted(
                                        item.regularPrice, null),
                                    style: TextStyle(
                                        color: theme.accentColor,
                                        fontSize: 12)),
                                const Text(' - '),
                                Text(
                                    Tools.getCurrencyFormatted(
                                        item.price, null),
                                    style: TextStyle(
                                        color: theme.accentColor, fontSize: 12))
                              ],
                            ),
                          if (item.price == null && item.regularPrice != null)
                            Row(
                              children: <Widget>[
//                                  Icon(
//                                    Icons.monetization_on,
//                                    size: 14,
//                                    color: Theme.of(context).primaryColor,
//                                  ),
//                                  SizedBox(
//                                    width: 2,
//                                  ),
                                Text(
                                    Tools.getCurrencyFormatted(
                                        item.regularPrice, null),
                                    style: TextStyle(
                                        color: theme.accentColor,
                                        fontSize: 12)),
                              ],
                            ),
                          if (item.price != null && item.regularPrice == null)
                            Row(
                              children: <Widget>[
//                                  Icon(
//                                    Icons.monetization_on,
//                                    size: 14,
//                                    color: Theme.of(context).primaryColor,
//                                  ),
//                                  SizedBox(
//                                    width: 2,
//                                  ),
                                Text(
                                    Tools.getCurrencyFormatted(
                                        item.price, null),
                                    style: TextStyle(
                                        color: theme.accentColor, fontSize: 12))
                              ],
                            ),
                          if (hasPrice) const SizedBox(height: 3),
                          Row(
                            children: <Widget>[
                              (item.averageRating != null &&
                                      item.averageRating != 0.0)
                                  ? SmoothStarRating(
                                      allowHalfRating: true,
                                      starCount: 5,
                                      rating: item.averageRating ?? 0.0,
                                      size: starSize,
                                      color: theme.primaryColor,
                                      borderColor: theme.primaryColor,
                                      spacing: 0.0,
                                      label: Container(),
                                    )
                                  : Container(),
                              if (item.totalReview != 0)
                                Text(
                                  ' (${item.totalReview}) ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline1
                                      .copyWith(
                                          fontSize: 12,
                                          color: Theme.of(context).accentColor),
                                ),
                            ],
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
          if (showHeart && !item.isEmptyProduct())
            Positioned(
              top: 0,
              right: 0,
              child: HeartButton(product: item, size: 18),
            )
        ],
      ),
    );
  }
}
