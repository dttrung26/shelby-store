import 'dart:async';
import 'dart:convert' as convert;
import 'dart:core';

import 'package:http/http.dart' as http;
import 'package:quiver/strings.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../models/entities/prediction.dart';
import '../../../models/index.dart' show Product, Review, User;
import '../../../models/vendor/store_model.dart';
import '../../woocommerce/services/woo_commerce.dart';
import 'wcfm_api.dart';

class WCFMApi extends WooCommerce {
  static final WCFMApi _instance = WCFMApi._internal();

  factory WCFMApi() => _instance;

  WCFMApi._internal();

  WCFMAPI wcfmApi;

  String jwtToken;

  @override
  void appConfig(appConfig) {
    super.appConfig(appConfig);
    wcfmApi = WCFMAPI(url: appConfig['url']);
  }

  @override
  Future<User> createUser({
    String firstName,
    String lastName,
    String username,
    String password,
    String phoneNumber,
    bool isVendor = false,
  }) async {
    try {
      var niceName = firstName + ' ' + lastName;
      final response = await http.post(
          '$url/wp-json/api/flutter_user/sign_up/?insecure=cool&$isSecure',
          body: convert.jsonEncode({
            'user_email': username,
            'user_login': username,
            'username': username,
            'first_name': firstName,
            'last_name': lastName,
            'user_pass': password,
            'email': username,
            'user_nicename': niceName,
            'display_name': niceName,
            'phone': phoneNumber,
            'role': (isVendor ?? false) ? 'wcfm_vendor' : 'subscriber'
          }));
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body['message'] == null) {
        var cookie = body['cookie'];
        return await getUserInfo(cookie);
      } else {
        var message = body['message'];
        throw Exception(message ?? 'Can not create the user.');
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> getProductsByStore({storeId, page}) async {
    try {
      final response = await http.post(
          '$url/wp-json/api/flutter_multi_vendor/products/owner',
          body: convert.jsonEncode({'id': storeId, 'page': page}),
          headers: {'Content-Type': 'application/json'});
      var body = convert.jsonDecode(response.body);
      if (body is Map && isNotBlank(body['message'])) {
        throw Exception(body['message']);
      } else {
        var list = <Product>[];
        for (var item in body) {
          if (item['status'] == 'published' || item['status'] == 'publish') {
            final product = Product.fromJson(item);
            if (item['store'] != null && item['store'].isNotEmpty) {
              product.store = Store.fromWCFMJson(item['store']);
            }
            list.add(product);
          }
        }
        return list;
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Review>> getReviewsStore({storeId}) async {
    try {
      var list = <Review>[];
      var response = await wcfmApi.getAsync('reviews');

      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        for (var item in response) {
          if (int.parse(item['vendor_id']) == storeId) {
            list.add(Review.fromWCFMJson(item));
          }
        }
        return list;
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Store> getStoreInfo(storeId) async {
    try {
      var response = await wcApi.getAsync('flutter/wcfm-stores/$storeId');

      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        if (response['settings'] == null) {
          return null;
        }
        return Store.fromWCFMJson(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Store>> searchStores({String keyword, int page = 10}) async {
    try {
      var list = <Store>[];
      var endPoint = 'flutter/wcfm-stores?';
      if (keyword?.isNotEmpty ?? false) {
        endPoint += 'search=$keyword';
      }

      endPoint += '&page=$page';

      var response = await wcApi.getAsync(endPoint);

      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        for (var item in response) {
          if (!item['disable_vendor']) list.add(Store.fromWCFMJson(item));
        }
        return list;
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Store>> getFeaturedStores() async {
    var page = 1;
    var list = <Store>[];
    while (true) {
      try {
        var response =
            await wcApi.getAsync('flutter/wcfm-stores?page=$page&per_page=100');
        if (response.length == 0) {
          return list;
        }
        if (response is Map && isNotBlank(response['message'])) {
          throw Exception(response['message']);
        } else {
          for (var item in response) {
            if (!item['disable_vendor']) list.add(Store.fromWCFMJson(item));
          }
          page++;
        }
      } catch (e) {
        return list;
      }
    }
  }

  @override
  Future<List<Store>> getNearbyStores(Prediction prediction) async {
    var list = <Store>[];

    try {
      var response = await wcApi.getAsync(
          "flutter/wcfm-stores?page=1&per_page=100&wcfmmp_radius_lat=${prediction.lat}&wcfmmp_radius_lng=${prediction.long}&wcfmmp_radius_range=${kAdvanceConfig['QueryRadiusDistance']}");
      if (response.length == 0) {
        return list;
      }
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        for (var item in response) {
          if (!item['disable_vendor']) {
            final store = Store.fromWCFMJson(item);
            if (store.lat == null || store.long == null) {
              continue;
            }
            list.add(Store.fromWCFMJson(item));
          }
        }
      }
    } catch (e) {
      printLog(e);
    }
    return list;
  }
}
