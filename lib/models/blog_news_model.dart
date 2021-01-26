import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import '../common/constants.dart';
import '../screens/blogs/posts.dart';
import '../services/wordpress/wordpress.dart';
import 'app_model.dart';
import 'entities/blog_news.dart';

class BlogNewsModel with ChangeNotifier {
  List<BlogNews> blogList = [];

  final WordPress _service = WordPress();

  bool isFetching = false;
  bool isEnd;
  int categoryId;
  String categoryName;
  String errMsg;

  Future<List<BlogNews>> fetchBlogLayout(config, lang) async {
    return _service.fetchBlogLayout(config: config, lang: lang);
  }

  void setBlogNewsList(blogs) {
    blogList = blogs;
    isFetching = false;
    isEnd = false;
    notifyListeners();
  }

  void fetchBlogsByCategory({categoryId, categoryName}) {
    this.categoryId = categoryId;

    this.categoryName = categoryName;
    notifyListeners();
  }

  Future<void> saveBlogs(Map<String, dynamic> data) async {
    final storage = LocalStorage('fstore');
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem(kLocalKey['home'], data);
      }
    } catch (err) {
      printLog(err);
    }
  }

  Future<void> getBlogsList(
      {categoryId, minPrice, maxPrice, orderBy, order, lang, page}) async {
    try {
      printLog(categoryId);
      if (categoryId != null) {
        this.categoryId = categoryId;
      }
      isFetching = true;
      isEnd = false;
      notifyListeners();

      final blogs = await _service.fetchBlogsByCategory(
          categoryId: categoryId, lang: lang, page: page);
      if (blogs.isEmpty) {
        isEnd = true;
      }

      if (page == 0 || page == 1) {
        blogList = blogs;
      } else {
        blogList = [...blogList, ...blogs];
      }
      isFetching = false;
      notifyListeners();
    } catch (err) {
      errMsg = err.toString();
      isFetching = false;
      notifyListeners();
    }
  }

  void setBlogsList(blogs) {
    blogList = blogs;
    isFetching = false;
    isEnd = false;
    notifyListeners();
  }

  static dynamic showList(
      {cateId, cateName, context, List<BlogNews> blogs, config, noRouting}) {
    var categoryId = cateId ?? config['category'];

    var categoryName = cateName ?? config['name'];
    final blog = Provider.of<BlogNewsModel>(context, listen: false);

    // for caching current products list
    if (blogs != null) {
      blog.setBlogNewsList(blogs);
      return Navigator.push(
          context,
          MaterialPageRoute(
              fullscreenDialog: kIsWeb,
              builder: (context) =>
                  BlogsPage(blogs: blogs, categoryId: categoryId)));
    }
    if (categoryId != null) {
      blog.fetchBlogsByCategory(
          categoryId: categoryId, categoryName: categoryName);
    }

    blog.setBlogsList([]); //clear old products
    blog.getBlogsList(
      categoryId: categoryId,
      page: 1,
      lang: Provider.of<AppModel>(context, listen: false).langCode,
    );

    if (noRouting == null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              fullscreenDialog: kIsWeb,
              builder: (context) =>
                  BlogsPage(blogs: blogs ?? [], categoryId: categoryId)));
    } else {
      return BlogsPage(blogs: blogs ?? [], categoryId: categoryId);
    }
  }
}
