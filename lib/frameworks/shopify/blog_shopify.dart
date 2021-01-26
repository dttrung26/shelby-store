// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:html_unescape/html_unescape.dart';
// import 'package:http/http.dart' as http;
// import 'package:localstorage/localstorage.dart';
// import 'package:provider/provider.dart';
//
// import '../../common/constants.dart';
// import '../../models/entities/blog.dart';
// import '../../models/index.dart' show AppModel;
// import '../../screens/index.dart' show BlogsPage;
// import 'services/shopify.dart';
//
// class BlogShopifyModel with ChangeNotifier {
//   List<Blog> blogList = [];
//
//   bool isFetching = false;
//   bool isEnd;
//   dynamic categoryId;
//   String categoryName;
//   String errMsg;
//
//   Future<List<Blog>> fetchBlogLayout() async {
//     return await ShopifyApi().getBlogs();
//   }
//
//   void setBlogNewsList(blogs) {
//     blogList = blogs;
//     isFetching = false;
//     isEnd = false;
//     notifyListeners();
//   }
//
//   void fetchBlogsByCategory({categoryId, categoryName}) {
//     this.categoryId = categoryId;
//
//     this.categoryName = categoryName;
//     notifyListeners();
//   }
//
//   Future<void> saveBlogs(Map<String, dynamic> data) async {
//     final LocalStorage storage = LocalStorage("fstore");
//     try {
//       final ready = await storage.ready;
//       if (ready) {
//         await storage.setItem(kLocalKey["home"], data);
//       }
//     } catch (err) {
//       printLog(err);
//     }
//   }
//
//   Future<void> getBlogsList(
//       {categoryId, minPrice, maxPrice, orderBy, order, lang, page}) async {
//     try {
//       printLog(categoryId);
//       if (categoryId != null) {
//         this.categoryId = categoryId;
//       }
//       isFetching = true;
//       isEnd = false;
//       notifyListeners();
//
//       List<Blog> blogs = await ShopifyApi().getBlogs();
//
//       if (blogs.isEmpty) {
//         isEnd = true;
//       }
//
//       if (page == 0 || page == 1) {
//         blogList = blogs;
//       } else {
//         blogList = []..addAll(blogList)..addAll(blogs);
//       }
//       isFetching = false;
//       notifyListeners();
//     } catch (err) {
//       errMsg = err.toString();
//       isFetching = false;
//       notifyListeners();
//     }
//   }
//
//   void setBlogsList(blogs) {
//     blogList = blogs;
//     isFetching = false;
//     isEnd = false;
//     notifyListeners();
//   }
// }
//
// class BlogShopify {
//   int id;
//   String date;
//   String title;
//   String author;
//   String content;
//   String excerpt;
//   String slug;
//   String imageFeature;
//
//   BlogShopify.empty(this.id) {
//     date = '';
//     title = 'Loading...';
//     author = '';
//     content = '';
//     excerpt = '';
//     imageFeature = '';
//   }
//
//   bool isEmptyBlog() {
//     return date == '' &&
//         title == 'Loading...' &&
//         content == 'Loading...' &&
//         excerpt == 'Loading...' &&
//         imageFeature == '';
//   }
//
//   static Future<dynamic> getBlogs({url, page = 1}) async {
//     final response = await http.get("$url/wp-json/wp/v2/posts?page=$page");
//     return json.decode(response.body);
//   }
//
//   BlogShopify.fromJson(Map<String, dynamic> parsedJson) {
//     try {
// //      categoryId = parsedJson["categories"][0];
//       id = parsedJson["id"];
//       slug = parsedJson["slug"];
//       title = HtmlUnescape().convert(parsedJson["title"]["rendered"]);
//       content = parsedJson["content"]["rendered"];
//
//       var imgJson = parsedJson["better_featured_image"];
//       if (imgJson != null) {
//         if (imgJson["media_details"]["sizes"]["medium_large"] != null) {
//           imageFeature =
//               imgJson["media_details"]["sizes"]["medium_large"]["source_url"];
//         }
//       }
//
//       if (imageFeature == null) {
//         var imgMedia = parsedJson['_embedded']['wp:featuredmedia'];
//         if (imgMedia != null &&
//             imgMedia[0]['media_details']["sizes"]["large"] != null) {
//           imageFeature =
//               imgMedia[0]['media_details']["sizes"]["large"]['source_url'];
//         }
//       }
//       excerpt = HtmlUnescape().convert(parsedJson['excerpt']['rendered']);
//       date = parsedJson["date"];
//     } catch (e) {
//       printLog(e);
//     }
//   }
//
//   static showList(
//       {cateId, cateName, context, List<BlogShopify> blogs, config, noRouting}) {
//     var categoryId = cateId ?? config['category'];
//
//     var categoryName = cateName ?? config['name'];
//     printLog('showList cateId $categoryId cateName $categoryName');
//     final blog = Provider.of<BlogShopifyModel>(context, listen: false);
//
//     // for caching current products list
//     if (blogs != null) {
//       blog.setBlogNewsList(blogs);
//     }
//     if (categoryId != null) {
//       blog.fetchBlogsByCategory(
//           categoryId: categoryId, categoryName: categoryName);
//     }
//
//     blog.setBlogsList([]); //clear old products
//     blog.getBlogsList(
//       categoryId: categoryId,
//       page: 1,
//       lang: Provider.of<AppModel>(context, listen: false).langCode,
//     );
//
//     if (noRouting == null) {
//       Navigator.push(
//           context,
//           MaterialPageRoute(
//               fullscreenDialog: kIsWeb,
//               builder: (context) =>
//                   BlogsPage(blogs: blogs ?? [], categoryId: categoryId)));
//     } else {
//       return BlogsPage(blogs: blogs ?? [], categoryId: categoryId);
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       "id": id,
//       "title": title,
//       "slug": slug,
//       "content": content,
//       "imageFeature": imageFeature,
//       "excerpt": excerpt,
//       "date": date,
//     };
//   }
//
//   BlogShopify.fromLocalJson(Map<String, dynamic> json) {
//     try {
//       id = json['id'];
//       title = json['title'];
//       slug = json['slug'];
//       content = json['content'];
//       imageFeature = json["imageFeature"];
//       excerpt = json["excerpt"];
//       date = json["date"];
//     } catch (e) {
//       printLog(e.toString());
//     }
//   }
//
//   @override
//   String toString() => 'Blog { id: $id title: $title }';
// }
