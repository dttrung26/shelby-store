import 'package:flutter/material.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../models/index.dart' show BlogNews;
import 'detailed_blog_fullsize_image.dart';
import 'detailed_blog_quarter_image.dart';

Widget getDetailPageView(List<BlogNews> blogs) {
  return PageView.builder(
    itemCount: blogs.length,
    itemBuilder: (context, position) {
      return getDetailScreen(blogs, position);
    },
  );
}

Widget getDetailScreen(List<BlogNews> blogs, index) {
  switch (kAdvanceConfig['DetailedBlogLayout']) {
    case kBlogLayout.fullSizeImageType:
      return FullImageType(item: blogs[index]);
//    case kBlogLayout.halfSizeImageType:
//      return HalfImageType(item: blogs[index]);
//
//    case kBlogLayout.oneQuarterImageType:
//      return OneQuarterImageType(item: blogs[index]);
    default:
      return OneQuarterImageType(item: blogs[index]);
  }
}

Widget getDetailBlog(BlogNews blog) {
  switch (kAdvanceConfig['DetailedBlogLayout']) {
    case kBlogLayout.fullSizeImageType:
      return FullImageType(
        item: blog,
      );
//    case kBlogLayout.halfSizeImageType:
//      return HalfImageType(item: blog);
//
//
//    case kBlogLayout.oneQuarterImageType:
//      return OneQuarterImageType(
//        item: blog,
//      );
    default:
      return OneQuarterImageType(item: blog);
  }
}

double _buildBlogWidth(String type) {
  switch (type) {
    case 'twoColumn':
      return 16;
    case 'threeColumn':
      return 15;
    case 'fourColumn':
      return 13;
    case 'recentView':
      return 13;
    case 'saleOff':
      return 15;
    case 'card':
    default:
      return 13;
  }
}

class BlogNewsView extends StatelessWidget {
  final List<BlogNews> blogs;
  final int index;

  const BlogNewsView({this.blogs, this.index});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => getDetailPageView(blogs.sublist(index)),
          ),
        );
      },
      child: ListTile(
        leading: Container(
          width: 100,
          height: 100,
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          alignment: Alignment.center,
          child:
              Tools.image(url: blogs[index].imageFeature, size: kSize.medium),
        ),
        title: Text(blogs[index].title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Text(
            blogs[index].date,
            style: const TextStyle(fontSize: 12, color: Colors.black45),
          ),
        ),
        dense: false,
      ),
    );
  }
}

class BlogCardView extends StatelessWidget {
  final List<BlogNews> blogs;
  final int index;
  final String type;

  BlogCardView({this.blogs, this.index, this.type});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => getDetailPageView(blogs.sublist(index)),
          ),
        );
      },
      child: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(right: 0, left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(3.0),
                  child: Tools.image(
                    url: blogs[index].imageFeature,
                    width: screenWidth,
                    height: screenWidth * 0.25,
                    fit: BoxFit.cover,
                    size: kSize.medium,
                  ),
                ),

                const SizedBox(height: 10.0),
                Text(
                  blogs[index].title,
                  style: TextStyle(
                      fontSize: _buildBlogWidth(type),
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                  maxLines: 2,
                ),
                const SizedBox(height: 10.0),
                Text(
                  Tools.formatDateString(blogs[index].date),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).accentColor.withOpacity(0.5),
                  ),
                  maxLines: 2,
                ),
//
              ],
            ),
          ),
        ],
      ),
    );
  }
}
