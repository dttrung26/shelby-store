import 'dart:async';
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:quiver/strings.dart';
import 'package:random_string/random_string.dart';

import '../../../common/constants.dart';
import '../../../models/index.dart'
    show
        BlogNews,
        CartModel,
        Category,
        Coupons,
        Order,
        PaymentMethod,
        Product,
        Review,
        ShippingMethod,
        User,
        UserModel;
import '../../../services/base_services.dart';
import '../../../services/wordpress/blognews_api.dart';

class OpencartApi extends BaseServices {
  static final OpencartApi _instance = OpencartApi._internal();

  factory OpencartApi() => _instance;

  OpencartApi._internal();

  String cookie;
  String domain;
  @override
  BlogNewsApi blogApi;

  void setAppConfig(appConfig) {
    domain = appConfig['url'];
    blogApi = BlogNewsApi(appConfig['blog'] ?? 'http://demo.mstore.io');
    getCookie();
  }

  @override
  Future<List<BlogNews>> fetchBlogLayout({config, lang}) async {
    try {
      final list = <BlogNews>[];

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
      rethrow;
    }
  }

  @override
  Future<BlogNews> getPageById(int pageId) async {
    var response = await blogApi.getAsync('pages/$pageId?_embed');
    return BlogNews.fromJson(response);
  }

  Future<void> getCookie() async {
    final storage = LocalStorage('fstore');
    try {
      final ready = await storage.ready;
      if (ready) {
        final json = storage.getItem('opencart_cookie');
        if (json != null) {
          cookie = json;
        } else {
          cookie = 'OCSESSID=' +
              randomNumeric(30) +
              '; PHPSESSID=' +
              randomNumeric(30);
          await storage.setItem('opencart_cookie', cookie);
        }
      }
    } catch (err) {
      cookie =
          'OCSESSID=' + randomNumeric(30) + '; PHPSESSID=' + randomNumeric(30);
    }
  }

  @override
  Future<List<Category>> getCategories({lang}) async {
    try {
      var response = await http.get(
          '$domain/index.php?route=extension/mstore/category&limit=100&lang=$lang');
      var list = <Category>[];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)['data']) {
          list.add(Category.fromOpencartJson(item));
        }
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> getProducts({userId}) async {
    try {
      var response =
          await http.get('$domain/index.php?route=extension/mstore/product');
      var list = <Product>[];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)['data']) {
          list.add(Product.fromOpencartJson(item));
        }
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> fetchProductsLayout({config, lang, userId}) async {
    try {
      var list = <Product>[];
      if (config['layout'] == 'imageBanner' ||
          config['layout'] == 'circleCategory') {
        return list;
      }

      var endPoint = '&limit=$ApiPageSize';
      if (config.containsKey('category')) {
        endPoint += "&category=${config["category"]}";
      }
      if (config.containsKey('tag')) {
        endPoint += "&tag=${config["tag"]}";
      }
      if (config.containsKey('page')) {
        endPoint += "&page=${config["page"]}";
      }
      if (lang != null) {
        endPoint += '&lang=$lang';
      }
      var response = await http
          .get('$domain/index.php?route=extension/mstore/product$endPoint');

      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)['data']) {
          var product = Product.fromOpencartJson(item);
          if (config['category'] != null &&
              "${config["category"]}".isNotEmpty) {
            product.categoryId = config['category'].toString();
          }
          list.add(product);
        }
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> fetchProductsByCategory(
      {categoryId,
      tagId,
      page,
      minPrice,
      maxPrice,
      orderBy,
      lang,
      order,
      featured,
      onSale,
      attribute,
      attributeTerm,
      listingLocation,
      userId}) async {
    try {
      var list = <Product>[];

      var endPoint =
          '/index.php?route=extension/mstore/product&limit=$ApiPageSize&page=$page&lang=$lang';
      if (categoryId != null && categoryId.toString().isNotEmpty) {
        endPoint += '&category=$categoryId';
      }
      if (tagId != null) {
        endPoint += '&tag=$tagId';
      }
      if (maxPrice != null && maxPrice > 0) {
        endPoint += '&max_price=${(maxPrice as double).toInt().toString()}';
      }
      if (orderBy != null) {
        endPoint += "&sort=${orderBy == "date" ? "date_added" : orderBy}";
      }
      if (order != null) {
        endPoint += '&order=${order.toString().toUpperCase()}';
      }

      // ignore: prefer_single_quotes
      var response = await http.get("$domain$endPoint");
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)['data']) {
          list.add(Product.fromOpencartJson(item));
        }
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> loginFacebook({String token}) async {
    try {
      var response = await http.post(
          '$domain/index.php?route=extension/mstore/account/socialLogin',
          body: convert.jsonEncode({'token': token, 'type': 'facebook'}),
          headers: {'content-type': 'application/json', 'cookie': cookie});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return User.fromOpencartJson(body['data'], '');
      } else {
        List error = body['error'];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception('Login fail');
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<User> loginSMS({String token}) async {
    try {
      var response = await http.post(
          '$domain/index.php?route=extension/mstore/account/socialLogin',
          body: convert.jsonEncode({'token': token, 'type': 'firebase_sms'}),
          headers: {'content-type': 'application/json', 'cookie': cookie});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return User.fromOpencartJson(body['data'], '');
      } else {
        List error = body['error'];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception('Login fail');
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<User> loginApple({String email, String fullName}) async {
    try {
      var response = await http.post(
          '$domain/index.php?route=extension/mstore/account/socialLogin',
          body: convert.jsonEncode(
              {'email': email, 'fullName': fullName, 'type': 'apple'}),
          headers: {'content-type': 'application/json', 'cookie': cookie});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return User.fromOpencartJson(body['data'], '');
      } else {
        List error = body['error'];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception('Login fail');
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<Review>> getReviews(productId) async {
    try {
      var response = await http
          .get('$domain/index.php?route=extension/mstore/review&id=$productId');
      var list = <Review>[];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)['data']) {
          list.add(Review.fromOpencartJson(item));
        }
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ShippingMethod>> getShippingMethods(
      {CartModel cartModel, String token, String checkoutId}) async {
    try {
      var address = cartModel.address;
      var list = <ShippingMethod>[];
      var response = await http.post(
          '$domain/index.php?route=extension/mstore/shipping_address/save',
          body: convert.jsonEncode(address.toOpencartJson()),
          headers: {'content-type': 'application/json', 'cookie': cookie});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body['success'] == 1) {
        var res = await http.get(
            '$domain/index.php?route=extension/mstore/shipping_method',
            headers: {'cookie': cookie});
        final body = convert.jsonDecode(res.body);
        if (res.statusCode == 200 && body['data']['error_warning'] == '') {
          Map<String, dynamic> data = body['data']['shipping_methods'];
          for (var item in data.values.toList()) {
            if (item['quote'] is Map) {
              if (item['quote']['code'] != null) {
                list.add(ShippingMethod.fromOpencartJson(item));
              } else {
                for (var quote
                    in Map<String, dynamic>.from(item['quote']).values) {
                  quote['quote'] = quote;
                  list.add(ShippingMethod.fromOpencartJson(quote));
                }
              }
            } else if (item['quote'] is List) {
              for (var quote in item['quote']) {
                item['quote'] = quote;
                list.add(ShippingMethod.fromOpencartJson(item));
              }
            }
          }
          return list;
        } else {
          throw Exception(body['data']['error_warning']);
        }
      } else {
        throw Exception(body['error'][0]);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods(
      {CartModel cartModel,
      ShippingMethod shippingMethod,
      String token}) async {
    try {
      var address = cartModel.address;
      var list = <PaymentMethod>[];
      var response = await http.post(
          '$domain/index.php?route=extension/mstore/shipping_method/save',
          body: convert.jsonEncode(
              {'shipping_method': shippingMethod.id, 'comment': 'no comment'}),
          headers: {'content-type': 'application/json', 'cookie': cookie});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body['success'] == 1) {
        response = await http.post(
            '$domain/index.php?route=extension/mstore/payment_address/save',
            body: convert.jsonEncode(address.toOpencartJson()),
            headers: {'content-type': 'application/json', 'cookie': cookie});
        final body = convert.jsonDecode(response.body);
        if (response.statusCode == 200 && body['success'] == 1) {
          var res = await http.get(
              '$domain/index.php?route=extension/mstore/payment_method',
              headers: {'cookie': cookie});
          final body = convert.jsonDecode(res.body);
          if (res.statusCode == 200 && body['data']['error_warning'] == '') {
            Map<String, dynamic> data = body['data']['payment_methods'];
            for (var item in data.values.toList()) {
              list.add(PaymentMethod.fromOpencartJson(item));
            }
            return list;
          } else {
            throw Exception(body['data']['error_warning']);
          }
        } else {
          throw Exception(body['error'][0]);
        }
      } else {
        throw Exception(body['error'][0]);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Order>> getMyOrders({UserModel userModel, int page}) async {
    try {
      var response = await http.post(
          '$domain/index.php?route=extension/mstore/order/orders&page=1&limit=50',
          headers: {'content-type': 'application/json', 'cookie': cookie});
      var list = <Order>[];
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body['data'] != null) {
        for (var item in body['data']) {
          list.add(Order.fromOpencartJson(item));
        }
      }
      return list;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<Order> createOrder(
      {CartModel cartModel,
      UserModel user,
      bool paid,
      String transactionId}) async {
    try {
      var response = await http
          .post('$domain/index.php?route=extension/mstore/payment_method/save',
              body: convert.jsonEncode({
                'payment_method': cartModel.paymentMethod.id,
                'agree': '1',
                'comment': cartModel.notes
              }),
              headers: {'content-type': 'application/json', 'cookie': cookie});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body['success'] == 1) {
        var res = await http.post(
            '$domain/index.php?route=extension/mstore/order/confirm',
            body: convert.jsonEncode({}),
            headers: {'cookie': cookie});
        final body = convert.jsonDecode(res.body);
        if (res.statusCode == 200 && body['success'] == 1) {
          var order = Order();
          order.id = body['data']['order_id']?.toString();
          order.number = body['data']['order_id']?.toString();
          return order;
        } else {
          throw Exception(body['error'][0]);
        }
      } else {
        throw Exception(body['error'][0]);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future updateOrder(orderId, {status, token}) {
    return null;
  }

  @override
  Future<List<Product>> searchProducts(
      {name,
      categoryId,
      tag,
      attribute,
      attributeId,
      page,
      lang,
      listingLocation,
      userId}) async {
    try {
      var list = <Product>[];

      var endPoint =
          '/index.php?route=extension/mstore/product&limit=$ApiPageSize&page=$page&search=$name&lang=$lang';

      // ignore: prefer_single_quotes
      var response = await http.get("$domain$endPoint");
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)['data']) {
          list.add(Product.fromOpencartJson(item));
        }
      }
      return list;
    } catch (e) {
      rethrow;
    }
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
      var response = await http
          .post('$domain/index.php?route=extension/mstore/account/register',
              body: convert.jsonEncode({
                'telephone': phoneNumber,
                'email': username,
                'firstname': firstName,
                'lastname': lastName,
                'password': password,
                'confirm': password
              }),
              headers: {'content-type': 'application/json'});

      if (response.statusCode == 200) {
        return await login(username: username, password: password);
      } else {
        final body = convert.jsonDecode(response.body);
        List error = body['error'];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception('Can not create user');
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<User> getUserInfo(cookie) async {
    try {
      var res = await http.get(
          '$domain/index.php?route=extension/mstore/account',
          headers: {'cookie': this.cookie});
      final body = convert.jsonDecode(res.body);
      if (res.statusCode == 200) {
        return User.fromOpencartJson(body['data'], cookie);
      } else {
        List error = body['error'];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception('No match for E-Mail Address and/or Password');
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<User> login({username, password}) async {
    try {
      var response = await http.post(
          '$domain/index.php?route=extension/mstore/account/login',
          body: convert.jsonEncode({'email': username, 'password': password}),
          headers: {'content-type': 'application/json', 'cookie': cookie});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return User.fromOpencartJson(body['data'], '');
      } else {
        List error = body['error'];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception('No match for E-Mail Address and/or Password');
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<Product> getProduct(id, {lang}) async {
    return null;
  }

  Future<bool> addItemsToCart(CartModel cartModel, String token) async {
    try {
      if (cookie != null) {
        var items = [];
        cartModel.productsInCart.keys.forEach((productId) {
          items.add({
            'product_id': productId,
            'quantity': cartModel.productsInCart[productId],
            'option': cartModel.productOptionInCart[productId]
          });
        });

        var res = await http.delete(
            '$domain/index.php?route=extension/mstore/cart/emptyCart',
            headers: {'cookie': cookie, 'content-type': 'application/json'});
        if (res.statusCode == 200) {
          final body = convert.jsonDecode(res.body);
          if (res.statusCode == 200 &&
              body['success'] == 1 &&
              body['data']['total_product_count'] == 0) {
            var res = await http.post(
                '$domain/index.php?route=extension/mstore/cart/add',
                body: convert.jsonEncode(items),
                headers: {
                  'cookie': cookie,
                  'content-type': 'application/json'
                });
            final body = convert.jsonDecode(res.body);
            if (res.statusCode == 200 &&
                body['success'] == 1 &&
                body['data']['total_product_count'] > 0) {
              if (cartModel.couponObj != null &&
                  cartModel.couponObj.code != null) {
                await http.post(
                    '$domain/index.php?route=extension/mstore/cart/coupon',
                    body: convert
                        .jsonEncode({'coupon': cartModel.couponObj.code}),
                    headers: {
                      'cookie': cookie,
                      'content-type': 'application/json'
                    });
              }
              return true;
            } else {
              throw Exception('Can not add items to cart');
            }
          } else {
            throw Exception(body['error'][0]);
          }
        } else {
          throw Exception(res.reasonPhrase);
        }
      } else {
        throw Exception('You need to login to checkout');
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<Coupons> getCoupons() async {
    try {
      var res = await http.get(
          '$domain/index.php?route=extension/mstore/cart/coupons',
          headers: {'cookie': cookie, 'content-type': 'application/json'});
      final body = convert.jsonDecode(res.body);
      return Coupons.getListCouponsOpencart(body['data']);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<User> loginGoogle({String token}) async {
    try {
      var response = await http.post(
          '$domain/index.php?route=extension/mstore/account/socialLogin',
          body: convert.jsonEncode({'token': token, 'type': 'google'}),
          headers: {'content-type': 'application/json', 'cookie': cookie});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return User.fromOpencartJson(body['data'], '');
      } else {
        List error = body['error'];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception('Login fail');
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future logout() async {
    return await http.post(
        '$domain/index.php?route=extension/mstore/account/logout',
        headers: {'content-type': 'application/json', 'cookie': cookie});
  }

  @override
  Future getCountries() async {
    try {
      var res = await http.get(
          '$domain/index.php?route=extension/mstore/shipping_address/countries',
          headers: {'cookie': cookie, 'content-type': 'application/json'});
      final body = convert.jsonDecode(res.body);
      return body['data'];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future getStatesByCountryId(countryId) async {
    try {
      var res = await http.get(
          '$domain/index.php?route=extension/mstore/shipping_address/states&countryId=$countryId',
          headers: {'cookie': cookie, 'content-type': 'application/json'});
      final body = convert.jsonDecode(res.body);
      return body['data'];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateUserInfo(
      Map<String, dynamic> json, String token) async {
    try {
      var params = <String, dynamic>{};
      if (isNotBlank(json['user_email'])) {
        params['email'] = json['user_email'];
      }
      if (isNotBlank(json['user_pass'])) {
        params['password'] = json['user_pass'];
      }
      var res = await http.put(
          '$domain/index.php?route=extension/mstore/account/edit',
          body: convert.jsonEncode(params),
          headers: {'cookie': cookie});
      final body = convert.jsonDecode(res.body);
      if (res.statusCode == 200) {
        return null;
      } else {
        List error = body['error'];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("Can't update user info");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<Null> createReview(
      {String productId, Map<String, dynamic> data, String token}) async {
    try {
      data['product_id'] = productId;
      data['name'] = data['reviewer'];
      data['text'] = data['review'];
      var res = await http.post(
          '$domain/index.php?route=extension/mstore/review',
          body: convert.jsonEncode(data),
          headers: {'cookie': cookie});
      if (res.statusCode == 200) {
        return null;
      } else {
        final body = convert.jsonDecode(res.body);
        List error = body['error'];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("Can't Post Review");
        }
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }
}
