import 'dart:async';
import 'dart:convert' as convert;
import 'dart:core';

import 'package:http/http.dart' as http;

import '../../common/constants.dart' show printLog;
import '../../models/index.dart' show BlogNews, Category, User;
import 'blognews_api.dart';

class WordPress {
  WordPress serviceApi;

  static final WordPress _instance = WordPress._internal();

  factory WordPress() => _instance;

  WordPress._internal();

  static BlogNewsApi blogApi;

  String isSecure;

  String url;

  static Future<Null> createComment(
      {int blogId, Map<String, dynamic> data}) async {
    try {
      await blogApi.postAsync('comments?post=$blogId', data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<BlogNews>> searchBlog({name}) async {
    try {
      var response = await blogApi.getAsync('posts?_embed&search=$name');

      var list = <BlogNews>[];
      for (var item in response) {
        list.add(BlogNews.fromJson(item));
      }
      printLog(list);
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Category>> getCategories({lang = 'en'}) async {
    try {
      var response = await blogApi.getAsync('categories?per_page=20');
      var list = <Category>[];
      for (var item in response) {
        list.add(Category.fromJson(item));
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BlogNews>> getBlogs() async {
    try {
      var response = await blogApi.getAsync('posts');
      var list = <BlogNews>[];
      for (var item in response) {
        list.add(BlogNews.fromJson(item));
      }
      printLog('list ${list?.length}');
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<BlogNews> getBlog(id) async {
    try {
      var response = await blogApi.getAsync('posts/$id');

      return BlogNews.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<BlogNews> getPageById(int pageId) async {
    var response = await blogApi.getAsync('pages/$pageId?_embed');
    return BlogNews.fromJson(response);
  }

  Future<List<BlogNews>> fetchBlogLayout({config, lang}) async {
    try {
      var list = <BlogNews>[];

      var endPoint = 'posts?_embed&lang=$lang';
      if (config.containsKey('category')) {
        endPoint += "&categories=${config["category"]}";
      }
      if (config.containsKey('limit')) {
        endPoint += "&per_page=${config["limit"] ?? 20}";
      }

      var response = await blogApi.getAsync(endPoint);

      for (var item in response) {
        if (BlogNews.fromJson(item) != null) {
          list.add(BlogNews.fromJson(item));
        }
      }

      return list;
    } catch (e) {
      printLog('Error: ${e.toString()}');
      rethrow;
    }
  }

  Future<List<BlogNews>> fetchBlogsByCategory({categoryId, page, lang}) async {
    try {
      var list = <BlogNews>[];

      var endPoint = 'posts?_embed&lang=$lang&per_page=15&page=$page';
      if (categoryId != null) {
        endPoint += '&categories=$categoryId';
      }
      var response = await blogApi.getAsync(endPoint);

      for (var item in response) {
        list.add(BlogNews.fromJson(item));
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future getNonce({method = 'register'}) async {
    try {
      var response = await http.get(
          '$url/api/get_nonce/?controller=mstore_user&method=$method&$isSecure');
      if (response.statusCode == 200) {
        return convert.jsonDecode(response.body)['nonce'];
      } else {
        throw Exception(['error getNonce', response.statusCode]);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<User> loginFacebook({String token}) async {
    const cookieLifeTime = 120960000000;

    try {
      var endPoint = '$url/api/mstore_user/fb_connect/?second=$cookieLifeTime'
          // ignore: prefer_single_quotes
          "&access_token=$token$isSecure";

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['status'] != 'ok') {
        return jsonDecode['msg'];
      }

      return User.fromWooJson(jsonDecode);
    } catch (e) {
      // print(e.toString());
      rethrow;
    }
  }

  Future<User> loginSMS({String token}) async {
    try {
      var endPoint =
          // ignore: prefer_single_quotes
          "$url/api/mstore_user/sms_login/?access_token=$token$isSecure";

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      return User.fromWooJson(jsonDecode);
    } catch (e) {
//      print(e.toString());
      rethrow;
    }
  }

  Future<User> getUserInfo(cookie) async {
    try {
      final response = await http.get(
          '$url/api/mstore_user/get_currentuserinfo/?cookie=$cookie&$isSecure');
      if (response.statusCode == 200) {
        return User.fromAuthUser(
            convert.jsonDecode(response.body)['user'], cookie);
      } else {
        throw Exception('Can not get user info');
      }
    } catch (err) {
      rethrow;
    }
  }

  Future<User> createUser({firstName, lastName, username, password}) async {
    try {
      String niceName = firstName + lastName;
      var nonce = await getNonce();

      final response = await http.get(
          '$url/api/mstore_user/register/?insecure=cool&nonce=$nonce&user_login=$username&username=$username&user_pass=$password&email=$username&user_nicename=$niceName&display_name=$niceName&$isSecure');

      if (response.statusCode == 200) {
        var cookie = convert.jsonDecode(response.body)['cookie'];
        return await getUserInfo(cookie);
      } else {
        var message = convert.jsonDecode(response.body)['error'];
        throw Exception(message ?? 'Can not create the user.');
      }
    } catch (err) {
      rethrow;
    }
  }

  Future<User> login({username, password}) async {
    var cookieLifeTime = 120960000000;
    try {
      printLog('login execute');
      final response = await http.get(
          '$url/api/mstore_user/generate_auth_cookie/?second=$cookieLifeTime&username=$username&password=$password&$isSecure');

      if (response.statusCode == 200) {
        var cookie = convert.jsonDecode(response.body)['cookie'];
        return await getUserInfo(cookie);
      } else {
        throw Exception('The username or password is incorrect.');
      }
    } catch (err) {
      rethrow;
    }
  }
}
