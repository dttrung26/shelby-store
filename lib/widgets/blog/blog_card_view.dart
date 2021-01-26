import 'package:flutter/material.dart';

import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show BlogNews;
import '../../widgets/blog/detailed_blog/blog_view.dart';

class BlogCard extends StatelessWidget {
  final BlogNews item;
  final width;
  final marginRight;
  final kSize size;
  final height;

  BlogCard(
      {this.item,
      this.width,
      this.size = kSize.medium,
      this.height,
      this.marginRight = 10.0});

  Widget getImageFeature(onTapProduct) {
    return GestureDetector(
      onTap: onTapProduct,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        child: Tools.image(
          url: item.imageFeature,
          width: width,
          height: height ?? width * 0.5,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void onTapProduct(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) => getDetailBlog(item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = Tools.isTablet(MediaQuery.of(context));
    var titleFontSize = isTablet ? 20.0 : 14.0;

    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: marginRight),
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  getImageFeature(() => onTapProduct(context)),
                ],
              ),
              Container(
                width: width,
                padding: const EdgeInsets.only(
                    top: 10, left: 8, right: 8, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.date == ''
                          ? S.of(context).loading
                          : Tools.formatDateString(item.date),
                      style: TextStyle(
                        color: theme.accentColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
