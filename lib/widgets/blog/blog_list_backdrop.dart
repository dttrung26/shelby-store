import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show BlogNews;
import 'blog_card_view.dart';

class BlogListBackdrop extends StatefulWidget {
  final List<BlogNews> blogs;
  final bool isFetching;
  final bool isEnd;
  final String errMsg;
  final width;
  final padding;
  final String layout;
  final Function onRefresh;
  final Function onLoadMore;

  BlogListBackdrop({
    this.isFetching = false,
    this.isEnd = true,
    this.errMsg,
    this.blogs,
    this.width,
    this.padding = 8.0,
    this.onRefresh,
    this.onLoadMore,
    this.layout = 'list',
  });

  @override
  _BlogListBackdropState createState() => _BlogListBackdropState();
}

class _BlogListBackdropState extends State<BlogListBackdrop> {
  RefreshController _refreshController;
  int _page = 1;

  List<BlogNews> emptyList = [
    BlogNews.empty(1),
    BlogNews.empty(2),
    BlogNews.empty(3),
    BlogNews.empty(4),
    BlogNews.empty(5),
    BlogNews.empty(6)
  ];

  @override
  void initState() {
    super.initState();

    /// if there are existing product from previous navigate we don't need to enable the refresh
    _refreshController = RefreshController(initialRefresh: false);
  }

  void _onRefresh() async {
    if (!widget.isFetching) {
      _page = 1;
      widget.onRefresh();
    }
  }

  void _onLoading() async {
    if (!widget.isFetching && !widget.isEnd) {
      _page = _page + 1;
      widget.onLoadMore(_page);
    }
  }

  @override
  void didUpdateWidget(BlogListBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isFetching == false && oldWidget.isFetching == true) {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = Tools.isTablet(MediaQuery.of(context));
    final widthScreen = widget.width ?? screenSize.width;
    var widthContent = 0.0;

    if (widget.layout == 'card') {
      widthContent = widthScreen - 15; //one column
    } else if (widget.layout == 'columns') {
      widthContent =
          isTablet ? widthScreen / 4 : (widthScreen / 3) - 14; //three columns
    } else {
      //layout is list
      widthContent =
          isTablet ? widthScreen / 3 : (widthScreen / 2) - 14; //two columns
    }

    final blogsList =
        (widget.blogs == null || widget.blogs.isEmpty) && widget.isFetching
            ? emptyList
            : widget.blogs;

//    if (widget.errMsg != null && widget.errMsg.isNotEmpty) {
//      return Center(
//          child: Text(widget.errMsg, style: TextStyle(color: kErrorRed)));
//    }

    if (blogsList == null || blogsList.isEmpty) {
      return Center(
        child: Text(S.of(context).noProduct,
            style: const TextStyle(color: Colors.black)),
      );
    }

    return SmartRefresher(
      header: MaterialClassicHeader(
          backgroundColor: Theme.of(context).primaryColor),
      enablePullDown: true,
      enablePullUp: !widget.isEnd,
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      footer: kCustomFooter(context),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 0.5,
        ),
        cacheExtent: 500.0,
        itemCount: blogsList.length,
        itemBuilder: (context, i) {
          return BlogCard(
            item: blogsList[i],
            width: widthContent,
            marginRight: widget.layout == 'card' ? 0.0 : 10.0,
          );
        },
      ),
    );
  }
}
