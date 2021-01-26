import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/entities/blog.dart';
import '../../../models/index.dart' show BlogNews;
import '../../../screens/base.dart';
import '../../../services/service_config.dart';
import '../blog_card_view.dart';

class BlogListView extends StatefulWidget {
  final String id;
  BlogListView({this.id});

  @override
  _StateBlogListView createState() => _StateBlogListView();
}

class _StateBlogListView extends BaseScreen<BlogListView> {
  int page = 1;
  bool isEnd = false;
  bool firstLoading = true;
  List<BlogNews> blogs = [];

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  void afterFirstLayout(BuildContext context) async {
    await loadMore();
    setState(() {
      firstLoading = false;
    });
  }

  void onRefresh() async {
    var res = await Blog.getBlogs(
        url: Config().blog ?? Config().url, categories: widget.id, page: 1);
    if (res.isEmpty || !(res is List)) {
      setState(() {
        isEnd = true;
      });
      refreshController.refreshCompleted();
      return;
    }
    var _blogs = <BlogNews>[];
    for (var item in res) {
      _blogs.add(BlogNews.fromJson(item));
    }
    setState(() {
      page = 2;
      isEnd = false;
      blogs = _blogs;
    });
    refreshController.refreshCompleted();
  }

  void loadMore() async {
    if (isEnd) return;
    var res = await Blog.getBlogs(
        url: Config().blog ?? Config().url, categories: widget.id, page: page);
    if (res.isEmpty || !(res is List)) {
      setState(() {
        isEnd = true;
      });
      refreshController.loadComplete();
      return;
    }
    for (var item in res) {
      setState(() {
        blogs.add(BlogNews.fromJson(item));
      });
    }
    setState(() {
      page = page + 1;
    });
    refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    final length = (blogs.length ~/ 2) * 2 < blogs.length
        ? blogs.length ~/ 2 + 1
        : blogs.length ~/ 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).blog,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (firstLoading) {
            return Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: kLoadingWidget(context),
            );
          }
          return Container(
            padding: const EdgeInsets.only(left: 10, top: 20),
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: !isEnd,
              controller: refreshController,
              header: const WaterDropHeader(),
              footer: CustomFooter(
                builder: (BuildContext context, LoadStatus mode) {
                  Widget body = Container();
                  if (mode == LoadStatus.idle) {
                    body = Text(S.of(context).pullToLoadMore);
                  } else if (mode == LoadStatus.loading) {
                    body = Text(S.of(context).loading);
                  }
                  return Container(
                    height: 55.0,
                    child: Center(child: body),
                  );
                },
              ),
              onRefresh: onRefresh,
              onLoading: loadMore,
              child: ListView.builder(
                  itemCount: length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Expanded(
                          child: BlogCard(
                              item: blogs[index * 2],
                              width: constraints.maxWidth / 2),
                        ),
                        if (index * 2 + 1 < blogs.length)
                          Expanded(
                            child: BlogCard(
                              item: blogs[index * 2 + 1],
                              width: constraints.maxWidth / 2,
                            ),
                          ),
                      ],
                    );
                  }),
            ),
          );
        },
      ),
    );
  }
}
