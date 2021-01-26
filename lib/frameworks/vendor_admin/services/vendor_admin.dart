import 'dart:async';
import 'dart:convert' as convert;
import 'dart:core';

import 'package:http/http.dart' as http;
import 'package:quiver/strings.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../models/entities/category.dart';
import '../../../models/entities/notification_vendor_admin.dart';
import '../../../models/entities/order.dart';
import '../../../models/entities/sale_stats.dart';
import '../../../models/entities/vendor_notification.dart';
import '../../../models/index.dart' show OrderNote, Product, Review, User;
import '../../woocommerce/services/woo_commerce.dart';
import 'vendor_admin_api.dart';

class VendorAdminApi extends WooCommerce {
  static final VendorAdminApi _instance = VendorAdminApi._internal();

  factory VendorAdminApi() => _instance;

  VendorAdminApi._internal();

  VendorAdminAPI vendorAdminApi;

  @override
  void appConfig(appConfig) {
    super.appConfig(appConfig);
    vendorAdminApi = VendorAdminAPI(url: serverConfig['url']);
  }

  Future<SaleStats> getSaleStats({cookie}) async {
    try {
      var token = Utils.encodeCookie(cookie);
      var response = await http.get(
          '${serverConfig['url']}/wp-json/vendor-admin/sale-stats?token=$token');
      if (response.statusCode == 200) {
        var result = convert.jsonDecode(response.body);
        return SaleStats.fromMap(result['response']);
      }
      return null;
    } catch (e) {
      printLog(e);
      rethrow;
    }
  }

  Future<List<Review>> getVendorReviews(
      {String cookie, String status, int page, int perPage}) async {
    var list = <Review>[];
    try {
      var token = Utils.encodeCookie(cookie);
      var response = await http.get(
          '${serverConfig['url']}/wp-json/vendor-admin/reviews?page=$page&per_page=$perPage&status_type=$status&token=$token');
      if (response.statusCode == 200) {
        var result = convert.jsonDecode(response.body);
        for (var item in result['response']) {
          list.add(Review.fromWCFMJson(item));
        }
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<VendorNotification>> getVendorNotification(
      {String cookie, String status, int page, int perPage}) async {
    var list = <VendorNotification>[];
    try {
      var token = Utils.encodeCookie(cookie);
      var response = await http.get(
          '${serverConfig['url']}/wp-json/vendor-admin/notifications?page=$page&per_page=$perPage&status_type=$status&token=$token');
      if (response.statusCode == 200) {
        var result = convert.jsonDecode(response.body);
        for (var item in result['response']) {
          list.add(VendorNotification.fromMap(item));
        }
      }
    } catch (e) {
      printLog('vendor_admin.dart getVendorNotification: $e');
    }
    return list;
  }

  Future<List<Product>> getVendorProducts(String cookie,
      {int page, int perPage, String searchName}) async {
    var list = <Product>[];
    try {
      var token = Utils.encodeCookie(cookie);
      var endpoint =
          '${serverConfig['url']}/wp-json/vendor-admin/products?page=$page&per_page=$perPage&token=$token';
      if (searchName != null && searchName.isNotEmpty) {
        endpoint += '&search=$searchName';
      }
      var response = await http.get(endpoint);
      if (response.statusCode == 200) {
        var result = convert.jsonDecode(response.body);
        for (var item in result['response']) {
          list.add(Product.fromJson(item));
        }
      }
    } catch (e) {
      printLog('vendor_admin.dart getOwnProducts: $e');
    }
    return list;
  }

  Future<List<Order>> getVendorAdminOrders(
      {String cookie,
      int page = 1,
      int perPage = 10,
      String status,
      String search}) async {
    var list = <Order>[];
    try {
      var base64Str = Utils.encodeCookie(cookie);
      var endpoint =
          '${serverConfig['url']}/wp-json/vendor-admin/orders?page=$page&per_page=$perPage&token=$base64Str';
      if (status != null) {
        endpoint += '&status=$status';
      }
      if (search != null) {
        endpoint += '&search=$search';
      }
      final response = await http.get(endpoint);
      if (response.statusCode == 200) {
        var result = convert.jsonDecode(response.body);
        for (var item in result['response']) {
          list.add(Order.fromJson(item));
        }
      }
    } catch (e) {
      printLog('vendor_admin.dart getVendorOrders: $e');
    }
    return list;
  }

  Future<List<OrderNote>> getVendorAdminOrderNotes(
      {int page = 1, int perPage = 10, String orderId}) async {
    var list = <OrderNote>[];
    try {
      var endpoint =
          '${serverConfig['url']}/wp-json/wc/v3/orders/$orderId/notes?page=$page&per_page=$perPage&consumer_key=${serverConfig['consumerKey']}&consumer_secret=${serverConfig['consumerSecret']}';
      final response = await http.get(endpoint);
      if (response.statusCode == 200) {
        var result = convert.jsonDecode(response.body);
        for (var item in result) {
          list.add(OrderNote.fromJson(item));
        }
      }
    } catch (e) {
      printLog('vendor_admin.dart getVendorAdminOrderNotes: $e');
    }
    return list;
  }

  Future<void> updateReviewStatus(
      {String cookie, int reviewId, bool isApproved}) async {
    try {
      var base64Str = Utils.encodeCookie(cookie);
      await http.put(
          "${serverConfig['url']}/wp-json/vendor-admin/reviews/$reviewId",
          body: {
            'token': base64Str,
            'status': isApproved ? '1' : '0',
          });
    } catch (e) {
      printLog('vendor_admin.dart updateReviewStatus: $e');
    }
  }

  Future<List<String>> getImagesByVendor(
      {String vendorId, int page, int perPage}) async {
    var list = <String>[];
    try {
      final response = await http.get(
          "${serverConfig['url']}/wp-json/wp/v2/media?author=$vendorId&page=$page&per_page=$perPage");

      if (response.statusCode == 200) {
        var result = convert.jsonDecode(response.body);
        for (var item in result) {
          list.add(item['guid']['rendered']);
        }
      }
    } catch (e) {
      printLog('vendor_admin.dart getImagesByVendor: $e');
    }
    return list;
  }

  Future<Product> updateProduct(
      {String cookie,
      Product product,
      List<dynamic> images,
      dynamic featuredImage}) async {
    try {
      var base64Str = Utils.encodeCookie(cookie);

      /// Notice: Don't try to modify these because they will be handled on the server
      var categoryIds = '';
      for (var id in product.categoryIds) {
        categoryIds += '$id,';
      }
      var preparedImages =
          await ImageTools.compressAndConvertImagesForUploading(images);

      var preparedFeaturedImage = await ImageTools.compressImage(featuredImage);

      /// End Notice

      final response = await http
          .put("${serverConfig['url']}/wp-json/vendor-admin/products", body: {
        'token': base64Str,
        'id': product.id,
        'sku': product.sku,
        'name': product.name,
        'featured': product.isFeatured ? 'true' : 'false',
        'in_stock': product.stockQuantity > 0 ? 'true' : 'false',
        'regular_price': product.regularPrice,
        'sale_price': product.salePrice,
        'description': product.description,
        'short_description': product.shortDescription,
        'manage_stock': product.manageStock ? 'true' : 'false',
        'stock_quantity': product.stockQuantity.toString(),
        'categories': categoryIds,
        'images': preparedImages,
        'featuredImage': preparedFeaturedImage,
      });
      if (response.statusCode == 200) {
        var result = convert.jsonDecode(response.body);
        return Product.fromJson(result['response']);
      }
    } catch (e) {
      printLog('vendor_admin.dart updateProduct: $e');
    }
    return product;
  }

  Future<Product> createVendorAdminProduct(
      {String cookie,
      Product product,
      List<dynamic> images,
      dynamic featuredImage}) async {
    try {
      var base64Str = Utils.encodeCookie(cookie);

      /// Notice: Don't try to modify these because they will be handled on the server
      var categoryIds = '';
      for (var id in product.categoryIds) {
        categoryIds += '$id,';
      }
      var preparedImages =
          await ImageTools.compressAndConvertImagesForUploading(images);

      var preparedFeaturedImage = await ImageTools.compressImage(featuredImage);

      /// End Notice

      final response = await http
          .post("${serverConfig['url']}/wp-json/vendor-admin/products", body: {
        'token': base64Str,
        'sku': product.sku,
        'name': product.name,
        'featured': product.isFeatured ? 'true' : 'false',
        'in_stock': product.stockQuantity > 0 ? 'true' : 'false',
        'regular_price': product.regularPrice,
        'sale_price': product.salePrice,
        'description': product.description,
        'short_description': product.shortDescription,
        'stock_quantity': product.stockQuantity.toString(),
        'manage_stock': product.manageStock ? 'true' : 'false',
        'categories': categoryIds,
        'images': preparedImages,
        'featuredImage': preparedFeaturedImage,
      });

      if (response.statusCode == 200) {
        var result = convert.jsonDecode(response.body);
        return Product.fromJson(result['response']);
      }
    } catch (e) {
      printLog('vendor_admin.dart updateProduct: $e');
    }
    return product;
  }

  Future<List<Category>> getVendorAdminCategoriesByPage(
      {String categoryId, int page, int perPage}) async {
    try {
      var categories = <Category>[];
      var url =
          "${serverConfig['url']}/wp-json/wc/v3/products/categories?parent=$categoryId&per_page=$perPage&page=$page&consumer_key=${serverConfig['consumerKey']}&consumer_secret=${serverConfig['consumerSecret']}";
      var response = await http.get(url);
      var result = convert.jsonDecode(response.body);
      if (result is Map &&
          result['message'] != null &&
          result['message'].isNotEmpty) {
        throw Exception(result['message']);
      } else {
        for (var item in result) {
          if (item['slug'] != 'uncategorized') {
            categories.add(Category.fromJson(item));
          }
        }
        return categories;
      }
    } catch (e) {
      printLog('vendor_admin.dart getVendorAdminCategoriesByPage: $e');
      rethrow;
    }
  }

  Future<List<Category>> getSubCategory({page, categoryId}) async {
    try {
      var categories = <Category>[];
      var url =
          "${serverConfig['url']}/wp-json/wc/v3/products/categories?parent=$categoryId&per_page=100&page=$page&consumer_key=${serverConfig['consumerKey']}&consumer_secret=${serverConfig['consumerSecret']}";
      var response = await http.get(url);
      var result = convert.jsonDecode(response.body);
      if (result is Map &&
          result['message'] != null &&
          result['message'].isNotEmpty) {
        throw Exception(result['message']);
      } else {
        for (var item in result) {
          if (item['slug'] != 'uncategorized') {
            categories.add(Category.fromJson(item));
          }
        }
        return categories;
      }
    } catch (e) {
      printLog('vendor_admin.dart getSubCategory: $e');
      rethrow;
    }
  }

  Future<List<Category>> searchCategory({name, page}) async {
    try {
      var categories = <Category>[];
      var url =
          "${serverConfig['url']}/wp-json/wc/v3/products/categories?search=$name&per_page=100&page=$page&consumer_key=${serverConfig['consumerKey']}&consumer_secret=${serverConfig['consumerSecret']}";
      var response = await http.get(url);
      var result = convert.jsonDecode(response.body);
      if (result is Map &&
          result['message'] != null &&
          result['message'].isNotEmpty) {
        throw Exception(result['message']);
      } else {
        for (var item in result) {
          if (item['slug'] != 'uncategorized') {
            categories.add(Category.fromJson(item));
          }
        }
        return categories;
      }
    } catch (e) {
      printLog('vendor_admin.dart searchCategory: $e');
      rethrow;
    }
  }

  Future<List<NotificationVendorAdmin>> getNotifications(
      {cookie, int page, int perPage}) async {
    var notifications = <NotificationVendorAdmin>[];
    try {
      var base64Str = Utils.encodeCookie(cookie);
      var endpoint =
          "${serverConfig['url']}/wp-json/vendor-admin/notifications?page=$page&per_page=$perPage&token=$base64Str";
      var response = await http.get(endpoint);

      if (response.statusCode == 200) {
        var result = convert.jsonDecode(response.body);
        for (var item in result['response']) {
          notifications.add(NotificationVendorAdmin.fromJson(item));
        }
      }
    } catch (e) {
      printLog('vendor_admin.dart getNotifications: $e');
    }
    return notifications;
  }

  @override
  Future updateOrder(orderId, {status, customerNote, token}) async {
    try {
      var base64Str = Utils.encodeCookie(token);
      var endpoint =
          '${serverConfig['url']}/wp-json/vendor-admin/vendor-orders';
      await http.put(endpoint, body: {
        'order_id': orderId.toString(),
        'order_status': status,
        'customer_note': customerNote ?? '',
        'token': base64Str,
      });
    } catch (e) {
      printLog('vendor_admin.dart updateOrder: $e');
      rethrow;
    }
  }

  /// App Authentication

  @override
  Future<User> login({username, password}) async {
    var cookieLifeTime = 120960000000;
    try {
      final response = await http.post(
          "${serverConfig['url']}/wp-json/api/flutter_user/generate_auth_cookie/?insecure=cool&$isSecure",
          body: convert.jsonEncode({
            'seconds': cookieLifeTime.toString(),
            'username': username,
            'password': password
          }));

      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && isNotBlank(body['cookie'])) {
        return await getUserInfo(body['cookie']);
      }
    } catch (err) {
      printLog(err);
    }
    return null;
  }

  @override
  Future<User> loginGoogle({String token}) async {
    const cookieLifeTime = 120960000000;

    try {
      var endPoint =
          "${serverConfig['url']}/wp-json/api/flutter_user/google_login/?second=$cookieLifeTime"
          '&access_token=$token';

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['wp_user_id'] == null || jsonDecode['cookie'] == null) {
        throw Exception(jsonDecode['message']);
      }

      return User.fromWooJson(jsonDecode);
    } catch (e) {
      printLog(e);
    }
    return null;
  }

  @override
  Future<User> loginFacebook({String token}) async {
    const cookieLifeTime = 120960000000;

    try {
      var endPoint =
          "${serverConfig['url']}/wp-json/api/flutter_user/fb_connect/?second=$cookieLifeTime"
          '&access_token=$token';

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['wp_user_id'] == null || jsonDecode['cookie'] == null) {
        throw Exception(jsonDecode['message']);
      }

      return User.fromWooJson(jsonDecode);
    } catch (e) {
      printLog(e);
    }
    return null;
  }

  @override
  Future<User> loginApple({String email, String fullName}) async {
    try {
      var endPoint =
          "${serverConfig['url']}/wp-json/api/flutter_user/apple_login?email=$email&display_name=$fullName&user_name=${email.split("@")[0]}";

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['wp_user_id'] == null || jsonDecode['cookie'] == null) {
        throw Exception(jsonDecode['message']);
      }

      return User.fromWooJson(jsonDecode);
    } catch (e) {
      printLog(e);
    }
    return null;
  }

  @override
  Future<User> getUserInfo(cookie) async {
    try {
      var base64Str = Utils.encodeCookie(cookie);
      final response = await http.get(
          "${serverConfig['url']}/wp-json/api/flutter_user/get_currentuserinfo?token=$base64Str&$isSecure");
      final body = convert.jsonDecode(response.body);
      if (body['user'] != null) {
        var user = body['user'];
        return User.fromAuthUser(user, cookie);
      } else {
        if (body['message'] != 'Invalid cookie') {
          throw Exception(body['message']);
        }
        return null;
      }
    } catch (e) {
      printLog('vendor_admin.dart getUserInfo: $e');
      rethrow;
    }
  }
}
