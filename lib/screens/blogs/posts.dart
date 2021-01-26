import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../models/index.dart'
    show AppModel, BlogNews, BlogNewsModel, Product;
import '../../widgets/backdrop/backdrop.dart';
import '../../widgets/backdrop/backdrop_menu.dart';
import '../../widgets/blog/blog_list_backdrop.dart';

class PostBackdrop extends StatelessWidget {
//  final ExpandingBottomSheet expandingBottomSheet;
  final Backdrop backdrop;

  const PostBackdrop({Key key, this.backdrop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        backdrop,
      ],
    );
  }
}

class BlogsPage extends StatefulWidget {
  final List<BlogNews> blogs;
  final int categoryId;
  final config;

  BlogsPage({this.blogs, this.categoryId, this.config});

  @override
  _BlogsPageState createState() => _BlogsPageState();
}

class _BlogsPageState extends State<BlogsPage>
    with SingleTickerProviderStateMixin {
  int newCategoryId = -1;
  double minPrice;
  double maxPrice;
  String orderBy;
  String order;
  bool isFiltering = false;
  List<Product> products = [];
  String errMsg;

  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    setState(() {
      newCategoryId = widget.categoryId;
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: 1.0,
    );

    if (widget.config != null) {
      onRefresh();
    }
  }

  void onFilter({minPrice, maxPrice, categoryId}) {
    _controller.forward();
    final blogNewsModel = Provider.of<BlogNewsModel>(context, listen: false);
    newCategoryId = categoryId;
    this.minPrice = minPrice;
    this.maxPrice = maxPrice;
    blogNewsModel.setBlogNewsList([]);
    blogNewsModel.getBlogsList(
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        page: 1,
        lang: Provider.of<AppModel>(context, listen: false).langCode,
        orderBy: orderBy,
        order: order);
  }

  void onSort(order) {
    orderBy = 'date';
    this.order = order;
    Provider.of<BlogNewsModel>(context, listen: false).getBlogsList(
      categoryId: newCategoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      lang: Provider.of<AppModel>(context, listen: false).langCode,
      page: 1,
      orderBy: orderBy,
      order: order,
    );
  }

  Future<void> onRefresh() async {
    if (widget.config == null) {
      await Provider.of<BlogNewsModel>(context, listen: false).getBlogsList(
          categoryId: newCategoryId,
          minPrice: minPrice,
          maxPrice: maxPrice,
          lang: Provider.of<AppModel>(context, listen: false).langCode,
          page: 1,
          orderBy: orderBy,
          order: order);
    }
  }

  void onLoadMore(page) {
    Provider.of<BlogNewsModel>(context, listen: false).getBlogsList(
        categoryId: newCategoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        lang: Provider.of<AppModel>(context, listen: false).langCode,
        page: page,
        orderBy: orderBy,
        order: order);
  }

  @override
  Widget build(BuildContext context) {
    final blog = Provider.of<BlogNewsModel>(context);
    final title = blog.categoryName ?? S.of(context).blog;
    final layout = widget.config != null && widget.config['layout'] != null
        ? widget.config['layout']
        : Provider.of<AppModel>(context).productListLayout;

    final backdrop = ({blogs, isFetching, errMsg, isEnd}) => PostBackdrop(
          backdrop: Backdrop(
            frontLayer: BlogListBackdrop(
                blogs: blogs,
                onRefresh: onRefresh,
                onLoadMore: onLoadMore,
                isFetching: isFetching,
                errMsg: errMsg,
                isEnd: isEnd,
                layout: layout),
            backLayer: BackdropMenu(onFilter: onFilter),
            frontTitle: Text(title),
            backTitle: Text(S.of(context).filter),
            controller: _controller,
            onSort: onSort,
          ),
        );

    return ListenableProvider.value(
      value: blog,
      child: Consumer<BlogNewsModel>(builder: (context, value, child) {
        return backdrop(
            blogs: value.blogList,
            isFetching: value.isFetching,
            errMsg: value.errMsg,
            isEnd: value.isEnd);
      }),
    );
  }
}
