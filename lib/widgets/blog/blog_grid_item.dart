import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/constants.dart' show RouteList;
import '../../common/tools.dart';
import '../../models/entities/blog.dart';
import '../../routes/flux_navigate.dart';

class BlogGridItem extends StatelessWidget {
  final Blog blog;

  const BlogGridItem({@required this.blog});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat(DateFormat.YEAR_MONTH_DAY);
    final createAt =
        dateFormat.format(DateTime.tryParse(blog.date) ?? DateTime.now());

    return InkWell(
      onTap: () => FluxNavigate.pushNamed(
        RouteList.detailBlog,
        arguments: blog,
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 6.0,
          right: 16.0,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Tools.image(
                url: blog.imageFeature,
                size: kSize.medium,
                isVideo:
                    Videos.getVideoLink(blog.content) == null ? false : true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    blog.title ?? '',
                    maxLines: 2,
                    style: const TextStyle(fontSize: 15.0),
                  ),
                  if (blog.date != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                        createAt,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
