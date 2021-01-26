import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter/foundation.dart' show compute;
import 'package:http/http.dart' as http;
import 'package:quiver/strings.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../models/entities/blog.dart';
import '../../../models/entities/prediction.dart';
import '../../../models/index.dart';
import '../../../services/base_services.dart';
import '../../../services/index.dart';
import '../../../services/wordpress/blognews_api.dart';
import '../../../services/wordpress/wordpress_api.dart';
import 'woocommerce_api.dart';

class WooCommerce extends BaseServices {
  Map<String, dynamic> configCache;
  WooCommerceAPI wcApi;

  String isSecure;
  String url;
  List<Category> categories = [];
  Map<String, Tag> tags = {};
  String currentLanguage;
  Map<String, List<Product>> categoryCache = <String, List<Product>>{};

  @override
  BlogNewsApi blogApi;
  WordPressApi wordPressAPI;

  void appConfig(appConfig) {
    blogApi = BlogNewsApi(appConfig['blog'] ?? appConfig['url']);
    wordPressAPI = WordPressApi(appConfig['url']);
    wcApi = WooCommerceAPI(appConfig['url'], appConfig['consumerKey'],
        appConfig['consumerSecret']);
    isSecure = appConfig['url'].indexOf('https') != -1 ? '' : '&insecure=cool';
    url = appConfig['url'];
    configCache = null;
    categories = [];
    currentLanguage = null;
    categoryCache = <String, List<Product>>{};
  }

  Product jsonParser(item) {
    var product = Product.fromJson(item);
    if (item['store'] != null) {
      if (item['store']['errors'] == null) {
        product = Services().widget.updateProductObject(product, item);
      }
    }
    return product;
  }

  @override
  Future<List<BlogNews>> fetchBlogLayout({config, lang}) async {
    try {
      var list = <BlogNews>[];

      var endPoint = 'posts?_embed';
      if (kAdvanceConfig['isMultiLanguages']) {
        endPoint += '&lang=$lang';
      }
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

  @override
  Future<List<Category>> getCategories({lang}) async {
    try {
      if (categories.isNotEmpty && currentLanguage == lang) {
        return categories;
      }
      currentLanguage = lang;
      var list = <Category>[];
      var isEnd = false;
      var page = 1;

      while (!isEnd) {
        var categories = await getCategoriesByPage(lang: lang, page: page);
        if (categories.isEmpty) {
          isEnd = true;
        }
        page = page + 1;
        list = [...list, ...categories];
      }
      categories = list;
      return list;
    } catch (e) {
      return [];
      //rethrow;
    }
  }

  Future<List<Category>> getCategoriesByPage({lang, page}) async {
    try {
      var url =
          'products/categories?exclude=$kExcludedCategory&per_page=100&page=$page&hide_empty=true';
      if (lang != null && kAdvanceConfig['isMultiLanguages']) {
        url += '&lang=$lang';
      }
      var response = await wcApi.getAsync(url);

      return compute(CategoryModel.parseCategoryList, response);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<Product>> getProducts({userId}) async {
    try {
      var endpoint = 'products';
      if (userId != null) {
        endpoint += '?user_id=$userId';
      }
      var response = await wcApi.getAsync(endpoint);
      var list = <Product>[];
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        for (var item in response) {
          list.add(jsonParser(item));
        }
        return list;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<Product>> fetchProductsLayout({config, lang, userId}) async {
    try {
      /// Load first page from cache.
      if (kAdvanceConfig['isCaching'] &&
          configCache != null &&
          config['page'] == 1) {
        var obj;
        final horizontalLayout = configCache['HorizonLayout'] as List;
        if (horizontalLayout != null) {
          obj = horizontalLayout.firstWhere(
              (o) =>
                  o['layout'] == config['layout'] &&
                  ((o['category'] != null &&
                          o['category'] == config['category']) ||
                      (o['tag'] != null && o['tag'] == config['tag'])),
              orElse: () => null);
          if (obj != null && obj['data'].length > 0) return obj['data'];
        }

        final verticalLayout = configCache['VerticalLayout'];
        if (verticalLayout != null &&
            verticalLayout['layout'] == config['layout'] &&
            ((verticalLayout['category'] != null &&
                    verticalLayout['category'] == config['category']) ||
                (verticalLayout['tag'] != null &&
                    verticalLayout['tag'] == config['tag']))) {
          return verticalLayout['data'];
        }
      }

      var endPoint = 'products?status=publish';
      if (kAdvanceConfig['isMultiLanguages']) {
        endPoint += '&lang=$lang';
      }
      if (config.containsKey('category') && config['category'] != null) {
        endPoint += "&category=${config["category"]}";
      }
      if (config.containsKey('tag') && config['tag'] != null) {
        endPoint += "&tag=${config["tag"]}";
      }

      /// Add featured filter
      if (config.containsKey('featured') && config['featured'] != null) {
        endPoint += "&featured=${config["featured"]}";
      }

      /// Add onSale filter
      if (config.containsKey('onSale') && config['onSale'] != null) {
        endPoint += "&on_sale=${config["onSale"]}";
      }

      if (config.containsKey('page')) {
        endPoint += "&page=${config["page"]}";
      }
      if (config.containsKey('limit')) {
        endPoint += "&per_page=${config["limit"] ?? ApiPageSize}";
      }
      if (userId != null) {
        endPoint += '&user_id=$userId';
      }

      var response = await wcApi.getAsync(endPoint);

      if (response is Map && isNotBlank(response['message'])) {
        printLog('WooCommerce Error: ' + response['message']);
        return [];
      }

      return ProductModel.parseProductList(response, config);
    } catch (e, trace) {
      printLog(trace.toString());
      printLog(e.toString());
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      return [];
    }
  }

  /// get all attribute_term for selected attribute for filter menu
  @override
  Future<List<SubAttribute>> getSubAttributes({int id}) async {
    try {
      var list = <SubAttribute>[];

      for (var i = 1; i < 100; i++) {
        var subAttributes = await getSubAttributesByPage(id: id, page: i);
        if (subAttributes.isEmpty) {
          break;
        }
        list = list + subAttributes;
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SubAttribute>> getSubAttributesByPage({id, page}) async {
    try {
      var listAttributes = <SubAttribute>[];

      var url = 'products/attributes/$id/terms?per_page=100&page=$page';
      var response = await wcApi.getAsync(url);

      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        for (var item in response) {
          if (item['count'] > 0) {
            listAttributes.add(SubAttribute.fromJson(item));
          }
        }
        return listAttributes;
      }
    } catch (e) {
      rethrow;
    }
  }

  //get all attributes for filter menu
  @override
  Future<List<FilterAttribute>> getFilterAttributes() async {
    try {
      var list = <FilterAttribute>[];
      var endPoint = 'products/attributes';

      var response = await wcApi.getAsync(endPoint);

      for (var item in response) {
        list.add(FilterAttribute.fromJson(item));
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
      page = 1,
      minPrice,
      maxPrice,
      orderBy,
      lang,
      order,
      attribute,
      attributeTerm,
      featured,
      onSale,
      listingLocation,
      userId}) async {
    try {
      var list = <Product>[];

      /// this cause a bug on Profile List
      /// we just allow cache if the totalItem = perPageItem otherwise, should reload
      if ((page == 0 || page == 1) &&
          categoryCache['$categoryId'] != null &&
          categoryCache['$categoryId'].isNotEmpty &&
          featured == null &&
          onSale == null &&
          attributeTerm == null) {
        if (categoryCache['$categoryId'].length == ApiPageSize) {
          return categoryCache['$categoryId'];
        }
      }

      var endPoint =
          'products?status=publish&per_page=$ApiPageSize&page=$page&skip_cache=1';
      if (kAdvanceConfig['isMultiLanguages']) {
        endPoint += '&lang=$lang';
      }
      if (categoryId != null && categoryId != '-1' && categoryId != '0') {
        endPoint += '&category=$categoryId';
      }
      if (tagId != null) {
        endPoint += '&tag=$tagId';
      }
      if (minPrice != null) {
        endPoint += '&min_price=${(minPrice as double).toInt().toString()}';
      }
      if (maxPrice != null && maxPrice > 0) {
        endPoint += '&max_price=${(maxPrice as double).toInt().toString()}';
      }
      if (orderBy != null) {
        endPoint += '&orderby=$orderBy';
      }
      if (order != null) {
        endPoint += '&order=$order';
      }
      if (featured != null) {
        endPoint += '&featured=$featured';
      }
      if (onSale != null) {
        endPoint += '&on_sale=$onSale';
      }
      if (attribute != null && attributeTerm != null) {
        endPoint += '&attribute=$attribute&attribute_term=$attributeTerm';
      }
      if (kAdvanceConfig['hideOutOfStock']) {
        endPoint += '&stock_status=instock';
      }
      if (userId != null) {
        endPoint += '&user_id=$userId';
      }

      printLog('fetchProductsByCategory: ' + endPoint);
      var response = await wcApi.getAsync(endPoint, version: 3);

      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        for (var item in response) {
          var product = jsonParser(item);

          if ((kAdvanceConfig['hideOutOfStock'] ?? false) && !product.inStock) {
            /// hideOutOfStock product
            continue;
          }

          if (categoryId != null) {
            product.categoryId = categoryId;
          }
          list.add(product);
        }
        return list;
      }
    } catch (e, trace) {
      printLog(trace);
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<User> loginFacebook({String token}) async {
    const cookieLifeTime = 120960000000;

    try {
      var endPoint =
          '$url/wp-json/api/flutter_user/fb_connect/?second=$cookieLifeTime'
          // ignore: prefer_single_quotes
          "&access_token=$token$isSecure";

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['wp_user_id'] == null || jsonDecode['cookie'] == null) {
        throw Exception(jsonDecode['message']);
      }

      return User.fromWooJson(jsonDecode);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<User> loginSMS({String token}) async {
    try {
      //var endPoint = "$url/wp-json/api/flutter_user/sms_login/?access_token=$token$isSecure";
      var endPoint =
          // ignore: prefer_single_quotes
          "$url/wp-json/api/flutter_user/firebase_sms_login?phone=$token$isSecure";

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['wp_user_id'] == null || jsonDecode['cookie'] == null) {
        throw Exception(jsonDecode['message']);
      }

      return User.fromWooJson(jsonDecode);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<User> loginApple({String email, String fullName}) async {
    try {
      var endPoint =
          "$url/wp-json/api/flutter_user/apple_login?email=$email&display_name=$fullName&user_name=${email.split("@")[0]}$isSecure";

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['wp_user_id'] == null || jsonDecode['cookie'] == null) {
        throw Exception(jsonDecode['message']);
      }

      return User.fromWooJson(jsonDecode);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<Review>> getReviews(productId) async {
    try {
      var response =
          await wcApi.getAsync('products/$productId/reviews', version: 2);
      var list = <Review>[];
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        for (var item in response) {
          list.add(Review.fromJson(item));
        }
        return list;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<Null> createReview(
      {String productId, Map<String, dynamic> data, String token}) async {
    try {
      data['product_id'] = productId;
      final response = await http.post(
          '$url/wp-json/api/flutter_woo/products/reviews',
          body: convert.jsonEncode(data),
          headers: {'User-Cookie': token});
      var body = convert.jsonDecode(response.body);
      if (body['message'] == null) {
        return;
      } else {
        throw Exception(body['message']);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<ProductVariation>> getProductVariations(Product product,
      {String lang = 'en'}) async {
    try {
      final list = <ProductVariation>[];
      var page = 1;

      while (true) {
        var endPoint =
            'products/${product.id}/variations?per_page=100&page=$page';
        if (kAdvanceConfig['isMultiLanguages']) {
          endPoint += '&lang=$lang';
        }

        var response = await wcApi.getAsync(endPoint);
        if (response is Map && isNotBlank(response['message'])) {
          throw Exception(response['message']);
        } else {
          for (var item in response) {
            if (item['visible']) {
              list.add(ProductVariation.fromJson(item));
            }
          }

          if (response is List && response.length < 100) {
            /// No more data.
            break;
          }

          /// Fetch next page.
          page++;
        }
      }

      return list;
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<ShippingMethod>> getShippingMethods(
      {CartModel cartModel, String token, String checkoutId}) async {
    try {
      final params = Order().toJson(cartModel, null, false);

      var list = <ShippingMethod>[];
      final response = await http.post(
          '$url/wp-json/api/flutter_woo/shipping_methods',
          body: convert.jsonEncode(params));
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        for (var item in body) {
          list.add(ShippingMethod.fromJson(item));
        }
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      if (list.isEmpty) {
        throw Exception(
            'Your selected address is not supported by any Shipping method, please update the billing address again!');
      }
      return list;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods(
      {CartModel cartModel,
      ShippingMethod shippingMethod,
      String token}) async {
    try {
      final params = Order().toJson(cartModel, null, false);

      var list = <PaymentMethod>[];

      final response = await http.post(
          '$url/wp-json/api/flutter_woo/payment_methods',
          body: convert.jsonEncode(params));
      final body = convert.jsonDecode(response.body);

      if (response.statusCode == 200) {
        for (var item in body) {
          list.add(PaymentMethod.fromJson(item));
        }
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      return list;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<Order>> getMyOrders({UserModel userModel, int page}) async {
    try {
      var response = await wcApi.getAsync(
          'orders?customer=${userModel.user.id}&per_page=20&page=$page&order=desc&orderby=id');
      var list = <Order>[];
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        for (var item in response) {
          list.add(Order.fromJson(item));
        }
        return list;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<OrderNote>> getOrderNote(
      {UserModel userModel, String orderId}) async {
    try {
      var response = await wcApi.getAsync(
          'orders/$orderId/notes?customer=${userModel.user.id}&per_page=20');
      var list = <OrderNote>[];
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        for (var item in response) {
//          if (item.type == 'any') {
          /// it is possible to update to `any` note
          /// ref: https://woocommerce.github.io/woocommerce-rest-api-docs/#list-all-order-notes
          list.add(OrderNote.fromJson(item));
//          }
        }
        return list;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
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
      final params = Order()
          .toJson(cartModel, user.user != null ? user.user.id : null, paid);
      if (transactionId != null) {
        params['transaction_id'] = transactionId;
      }

      final response = await http.post('$url/wp-json/api/flutter_order/create',
          body: convert.jsonEncode(params),
          headers: {
            'User-Cookie': user.user != null ? user.user.cookie : null
          });
      var body = convert.jsonDecode(response.body);
      if (response.statusCode == 201 && body['message'] == null) {
        if (cartModel.shippingMethod == null &&
            kPaymentConfig['EnableShipping']) {
          body['shipping_lines'][0]['method_title'] = null;
        }
        return Order.fromJson(body);
      } else {
        throw Exception(body['message']);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future updateOrder(orderId, {status, token}) async {
    try {
      final response = await http.put(
          '$url/wp-json/api/flutter_order/update/$orderId',
          body: convert.jsonEncode({'status': status}),
          headers: {'User-Cookie': token});

      var body = convert.jsonDecode(response.body);
      if (body['message'] != null) {
        throw Exception(body['message']);
      } else {
        return Order.fromJson(body);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<Product>> searchProducts({
    name,
    categoryId = '',
    tag = '',
    attribute = '',
    attributeId = '',
    page,
    lang,
    listingLocation = '',
    userId,
  }) async {
    try {
      var endPoint = 'products?status=publish&page=$page&per_page=$ApiPageSize';

      if ((lang?.isNotEmpty ?? false) && kAdvanceConfig['isMultiLanguages']) {
        endPoint += '&lang=$lang';
      }

      if (categoryId != null) {
        endPoint += '&category=$categoryId';
      }

      if (attribute != null) {
        endPoint += '&attribute=$attribute';
      }

      if (attributeId != null) {
        endPoint += '&attribute_term=$attributeId';
      }

      if (tag != null) {
        endPoint += '&tag=$tag';
      }
      if (userId != null) {
        endPoint += '&user_id=$userId';
      }
      var response = await wcApi.getAsync('$endPoint&search=$name');
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        var list = <Product>[];
        for (var item in response) {
          if (!kAdvanceConfig['hideOutOfStock'] || item['in_stock']) {
            list.add(jsonParser(item));
          }
        }

        /// Search by SKU.
        if (kAdvanceConfig['EnableSkuSearch'] ?? false) {
          var skuList = <Product>[];
          var response = await wcApi.getAsync('$endPoint&sku=$name');
          if (response is List) {
            for (var item in response) {
              if (!kAdvanceConfig['hideOutOfStock'] || item['in_stock']) {
                skuList.add(jsonParser(item));
              }
            }

            if (skuList.isNotEmpty) {
              /// Merge results. Let SKU results on top.
              skuList.addAll(list);
              return skuList;
            }
          }
        }
        return list;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  /// Auth
  @override
  Future<User> getUserInfo(cookie) async {
    try {
      var base64Str = Utils.encodeCookie(cookie);
      final response = await http.get(
          '$url/wp-json/api/flutter_user/get_currentuserinfo?token=$base64Str&$isSecure');
      final body = convert.jsonDecode(response.body);
      if (body['user'] != null) {
        var user = body['user'];
        return User.fromAuthUser(user, cookie);
      } else {
        if (body['message'] != 'Invalid cookie') {
          throw Exception(body['message']);
        }
        return null;

        /// we may handle if Invalid cookie here
      }
    } catch (err) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateUserInfo(
      Map<String, dynamic> json, String token) async {
    try {
      final body = convert.jsonEncode({...json, 'cookie': token});
      final response = await http.post(
          '$url/wp-json/api/flutter_user/update_user_profile',
          body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        data['cookie'] = token;
        return data;
      } else {
        throw Exception('Can not update user infor');
      }
    } catch (err) {
      rethrow;
    }
  }

  /// Create a New User
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
            'user_pass': password,
            'email': username,
            'user_nicename': niceName,
            'display_name': niceName,
            'phone': phoneNumber,
            'first_name': firstName,
            'last_name': lastName,
          }));
      var body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body['message'] == null) {
        var cookie = body['cookie'];
        return await getUserInfo(cookie);
      } else {
        var message = body['message'];
        throw Exception(message ?? 'Can not create the user.');
      }
    } catch (err) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  /// login
  @override
  Future<User> login({username, password}) async {
    var cookieLifeTime = 120960000000;
    try {
      final response = await http.post(
          '$url/wp-json/api/flutter_user/generate_auth_cookie/?insecure=cool&$isSecure',
          body: convert.jsonEncode({
            'seconds': cookieLifeTime.toString(),
            'username': username,
            'password': password
          }));

      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && isNotBlank(body['cookie'])) {
        return await getUserInfo(body['cookie']);
      } else {
        throw Exception('The username or password is incorrect.');
      }
    } catch (err, trace) {
      printLog('🔥 Integration error:');
      printLog(err);
      printLog(trace);
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  Future<Stream<Product>> streamProductsLayout({config}) async {
    try {
      var endPoint = 'products?per_page=$ApiPageSize';
      if (config.containsKey('category')) {
        endPoint += "&category=${config["category"]}";
      }
      if (config.containsKey('tag')) {
        endPoint += "&tag=${config["tag"]}";
      }

      var response = await wcApi.getStream(endPoint);

      return response.stream
          .transform(utf8.decoder)
          .transform(json.decoder)
          .expand((data) => (data as List))
          .map(jsonParser);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<Product> getProduct(id, {lang}) async {
    try {
      var endpoint = (lang == null || !kAdvanceConfig['isMultiLanguages'])
          ? 'products/$id'
          : 'products/$id?lang=$lang';

      var response = await wcApi.getAsync(endpoint);
      return jsonParser(response);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<Coupons> getCoupons() async {
    try {
      var response = await wcApi.getAsync('coupons');
      //printLog(response.toString());
      return Coupons.getListCoupons(response);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<AfterShip> getAllTracking() async {
    final data = await http.get('https://api.aftership.com/v4/trackings',
        headers: {'aftership-api-key': afterShip['api']});
    return AfterShip.fromJson(json.decode(data.body));
  }

  @override
  Future<Map<String, dynamic>> getHomeCache(String lang) async {
    try {
      final data = await wcApi.getAsync('flutter/cache?lang=$lang');
      if (data['message'] != null) {
        throw Exception(data['message']);
      }
      var config = data;
      if (config['HorizonLayout'] != null) {
        var horizontalLayout = config['HorizonLayout'] as List;
        var items = [];
        var products = [];
        List<Product> list;
        for (var i = 0; i < horizontalLayout.length; i++) {
          if (horizontalLayout[i]['radius'] != null) {
            horizontalLayout[i]['radius'] =
                double.parse("${horizontalLayout[i]["radius"]}");
          }
          if (horizontalLayout[i]['size'] != null) {
            horizontalLayout[i]['size'] =
                double.parse("${horizontalLayout[i]["size"]}");
          }
          if (horizontalLayout[i]['padding'] != null) {
            horizontalLayout[i]['padding'] =
                double.parse("${horizontalLayout[i]["padding"]}");
          }

          products = horizontalLayout[i]['data'] as List;
          list = [];
          if (products != null && products.isNotEmpty) {
            for (var item in products) {
              var product = jsonParser(item);
              if ((kAdvanceConfig['hideOutOfStock'] ?? false) &&
                  !product.inStock) {
                /// hideOutOfStock product
                continue;
              }
              if (horizontalLayout[i]['category'] != null &&
                  "${horizontalLayout[i]["category"]}".isNotEmpty) {
                product.categoryId = horizontalLayout[i]['category'].toString();
              }
              list.add(product);
            }
          }
          horizontalLayout[i]['data'] = list;

          items = horizontalLayout[i]['items'] as List;
          if (items != null && items.isNotEmpty) {
            for (var j = 0; j < items.length; j++) {
              if (items[j]['padding'] != null) {
                items[j]['padding'] = double.parse("${items[j]["padding"]}");
              }

              var listProduct = <Product>[];
              var prods = items[j]['data'] as List;
              if (prods != null && prods.isNotEmpty) {
                for (var prod in prods) {
                  var product = jsonParser(prod);
                  if ((kAdvanceConfig['hideOutOfStock'] ?? false) &&
                      !product.inStock) {
                    /// hideOutOfStock product
                    continue;
                  }
                  listProduct.add(product);
                }
              }
              items[j]['data'] = listProduct;
            }
          }
        }

        if (config['VerticalLayout'] != null) {
          var products = config['VerticalLayout']['data'] as List;
          var list = <Product>[];
          if (products != null && products.isNotEmpty) {
            for (var item in products) {
              var product = jsonParser(item);
              if ((kAdvanceConfig['hideOutOfStock'] ?? false) &&
                  !product.inStock) {
                /// hideOutOfStock product
                continue;
              }
              list.add(product);
            }
          }
          config['VerticalLayout']['data'] = list;
        }
        configCache = config;
        return config;
      }
      return null;
    } catch (e, trace) {
      printLog(trace);
      printLog(e);
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      return null;
    }
  }

  @override
  Future<User> loginGoogle({String token}) async {
    const cookieLifeTime = 120960000000;

    try {
      var endPoint =
          '$url/wp-json/api/flutter_user/google_login/?second=$cookieLifeTime'
          '&access_token=$token$isSecure';

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['wp_user_id'] == null || jsonDecode['cookie'] == null) {
        throw Exception(jsonDecode['message']);
      }

      return User.fromWooJson(jsonDecode);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  /// This layout only suitable for the small Categories items
  @override
  Future getCategoryWithCache() async {
    List<Category> getSubCategories(id) {
      return categories.where((o) => o.parent == id).toList();
    }

    bool hasChildren(id) {
      return categories.where((o) => o.parent == id).toList().isNotEmpty;
    }

    List<Category> getParentCategory() {
      return categories.where((item) => item.parent == '0').toList();
    }

    var categoryIds = <String>[];
    var parentCategories = getParentCategory();
    for (var item in parentCategories) {
      if (hasChildren(item.id)) {
        var subCategories = getSubCategories(item.id);
        for (var item in subCategories) {
          categoryIds.add(item.id.toString());
        }
      } else {
        categoryIds.add(item.id.toString());
      }
    }

    return await getCategoryCache(categoryIds);
  }

  Future<Map<String, dynamic>> getCategoryCache(categoryIds) async {
    try {
      final data = await wcApi.getAsync(
          'flutter/category/cache?categoryIds=${List<String>.from(categoryIds).join(",")}');
      if (data['message'] != null) {
        // throw Exception(data['message']);
      } else {
        for (var i = 0; i < categoryIds.length; i++) {
          var productsJson = data['${categoryIds[i]}'] as List;
          var list = <Product>[];
          if (productsJson != null && productsJson.isNotEmpty) {
            for (var item in productsJson) {
              var product = jsonParser(item);
              product.categoryId = categoryIds[i];
              list.add(product);
            }
          }
          categoryCache['${categoryIds[i]}'] = list;
        }
      }

      return categoryCache;
    } catch (e, trace) {
      printLog(trace.toString());
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<FilterTag>> getFilterTags() async {
    try {
      var list = <FilterTag>[];
      var endPoint = 'products/tags';
      var response = await wcApi.getAsync(endPoint);

      for (var item in response) {
        list.add(FilterTag.fromJson(item));
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> getCheckoutUrl(
      Map<String, dynamic> params, String lang) async {
    try {
      var str = convert.jsonEncode(params);
      var bytes = convert.utf8.encode(str);
      var base64Str = convert.base64.encode(bytes);

      final response = await http.post('$url/wp-json/api/flutter_user/checkout',
          body: convert.jsonEncode({
            'order': base64Str,
          }));
      var body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body is String) {
        if (kPaymentConfig['EnableOnePageCheckout'] ||
            kPaymentConfig['NativeOnePageCheckout']) {
          Map<String, dynamic> checkoutPageSlug =
              kPaymentConfig['CheckoutPageSlug'];
          String slug = checkoutPageSlug[lang];
          slug ??= checkoutPageSlug.values.toList().first;
          slug = slug.contains('?') ? slug + '&' : slug + '?';
          printLog('$url/${slug}code=$body&mobile=true');
          return '$url/${slug}code=$body&mobile=true';
        } else {
          return '$url/mstore-checkout?code=$body&mobile=true';
        }
      } else {
        var message = body['message'];
        throw Exception(message ?? "Can't save the order to website");
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<String> submitForgotPassword(
      {String forgotPwLink, Map<String, dynamic> data}) async {
    try {
      var endpoint = '$url/wp-json/api/flutter_user/reset-password';
      var response = await http.post(
        endpoint,
        body: convert.jsonEncode(data),
      );
      var result = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return '';
      } else {
        return result['message'];
      }
    } catch (e) {
      printLog(e);
      return 'Unknown Error: $e';
    }
  }

  @override
  Future<Map<String, dynamic>> getCurrencyRate() async {
    try {
      final response =
          await http.get('$url/wp-json/api/flutter_user/get_currency_rates');
      var body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body != null && body is Map) {
        var data = Map<String, dynamic>.from(body);
        var currency = <String, dynamic>{};
        data.keys.forEach((key) {
          currency[key.toUpperCase()] =
              double.parse("${data[key]['rate'] == 0 ? 1 : data[key]['rate']}");
        });
        return currency;
      } else {
        return null;
      }
    } catch (err) {
      return null;
    }
  }

  @override
  Future getCountries() async {
    try {
      final response =
          await http.get('$url/wp-json/api/flutter_user/get_countries');
      var body = convert.jsonDecode(response.body);
      return body;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future getStatesByCountryId(countryId) async {
    try {
      final response = await http.get(
          '$url/wp-json/api/flutter_user/get_states?country_code=$countryId');
      var body = convert.jsonDecode(response.body);
      return body;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future getCartInfo(String token) async {
    try {
      var base64Str = Utils.encodeCookie(token);
      final response =
          await http.get('$url/wp-json/api/flutter_woo/cart?token=$base64Str');
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return body;
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      return null;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future syncCartToWebsite(CartModel cartModel, User user) async {
    try {
      final params = Order()
          .toJson(cartModel, cartModel.user != null ? user.id : null, false);

      final response = await http.post('$url/wp-json/api/flutter_woo/cart',
          body: convert.jsonEncode(params));
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return body;
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      return null;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getCustomerInfo(String id) async {
    try {
      final http.Response response = await wcApi.getAsync('customers/$id');
      var body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body != null && body is Map) {
        var data = Map<String, dynamic>.from(body);
        return data;
      } else {
        return null;
      }
    } catch (err) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> getTaxes(CartModel cartModel) async {
    try {
      final params = Order().toJson(
          cartModel, cartModel.user != null ? cartModel.user.id : null, false);

      final response = await http.post('$url/wp-json/api/flutter_woo/taxes',
          body: convert.jsonEncode(params));
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        var taxes = <Tax>[];
        body['items'].forEach((item) {
          taxes.add(Tax.fromJson(item));
        });
        return {'items': taxes, 'total': body['taxes_total']};
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      return null;
    } catch (err) {
      rethrow;
    }
  }

  Future<Map<String, Tag>> getTagsByPage({String lang, int page}) async {
    try {
      var url = 'products/tags?per_page=100&page=$page&hide_empty=true';
      if (lang != null && kAdvanceConfig['isMultiLanguages']) {
        url += '&lang=$lang';
      }
      var response = await wcApi.getAsync(url);

      return compute(TagModel.parseTagList, response);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<Map<String, Tag>> getTags({String lang}) async {
    try {
      if (tags.isNotEmpty && currentLanguage == lang) {
        return tags;
      }
      currentLanguage = lang;
      var map = <String, Tag>{};
      var isEnd = false;
      var page = 1;

      while (!isEnd) {
        var _tags = await getTagsByPage(lang: lang, page: page);
        if (_tags.isEmpty) {
          isEnd = true;
        }
        page = page + 1;

        map.addAll(_tags);
      }
      tags = map;
      return tags;
    } catch (e) {
      return {};
      //rethrow;
    }
  }

  //For vendor
  @override
  Future<Store> getStoreInfo(storeId) {
    return null;
  }

  @override
  Future<bool> pushNotification({receiverEmail, senderName, message}) async {
    try {
      final res = await http.get(
          'https://us-central1-fluxstore-inspireui.cloudfunctions.net/pushNotification?email=$receiverEmail&senderName=$senderName&message=$message');
      if (res.statusCode == 200) {
        return true;
      } else {
        throw Exception(res.statusCode);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Review>> getReviewsStore({storeId}) {
    return null;
  }

  @override
  Future<List<Product>> getProductsByStore({storeId, page}) {
    return null;
  }

  @override
  Future<List<Store>> searchStores({String keyword, int page}) {
    return null;
  }

  @override
  Future<List<Store>> getFeaturedStores() {
    return null;
  }

  @override
  Future<List<Order>> getVendorOrders(
      {UserModel userModel, int page = 1}) async {
    try {
      var base64Str = Utils.encodeCookie(userModel.user.cookie);
      final response = await http.get(
          '$url/wp-json/wc/v2/flutter/vendor-orders?page=$page&token=$base64Str');
      printLog(
          '$url/wp-json/wc/v2/flutter/vendor-orders?page=$page&token=$base64Str');
      var body = convert.jsonDecode(response.body);
      var list = <Order>[];
      if (body is Map && isNotBlank(body['message'])) {
        throw Exception(body['message']);
      } else {
        for (var item in body) {
          list.add(Order.fromJson(item));
        }
        return list;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<Product> createProduct(
      String cookie, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
          '$url/wp-json/api/flutter_multi_vendor/product',
          body: convert.jsonEncode(data),
          headers: {'User-Cookie': cookie, 'Content-Type': 'application/json'});
      var body = convert.jsonDecode(response.body);
      if (body['message'] == null) {
        return jsonParser(body);
      } else {
        throw Exception(body['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> getOwnProducts(String cookie,
      {int page, int perPage}) async {
    try {
      final response = await http.post(
          '$url/wp-json/api/flutter_multi_vendor/products/owner',
          body: convert.jsonEncode({'cookie': cookie, 'page': page}),
          headers: {'User-Cookie': cookie, 'Content-Type': 'application/json'});
      var body = convert.jsonDecode(response.body);
      if (body is Map && isNotBlank(body['message'])) {
        throw Exception(body['message']);
      } else {
        var list = <Product>[];
        for (var item in body) {
          list.add(jsonParser(item));
        }
        return list;
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> uploadImage(dynamic data, String token) async {
    try {
      final response = await http.post(
          '$url/wp-json/api/flutter_multi_vendor/media',
          body: convert.jsonEncode(data),
          headers: {'User-Cookie': token, 'Content-Type': 'application/json'});
      var body = convert.jsonDecode(response.body);
      if (body['message'] == null) {
        return body;
      } else {
        throw Exception(body['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Point> getMyPoint(String token) async {
    try {
      var base64Str = Utils.encodeCookie(token);
      final response = await http
          .get('$url/wp-json/api/flutter_woo/points?token=$base64Str');
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Point.fromJson(body);
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      return null;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future updatePoints(String token, Order order) async {
    try {
      final response = await http.patch('$url/wp-json/api/flutter_woo/points',
          body: convert.jsonEncode({'cookie': token, 'order_id': order.id}));
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return body;
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      return null;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<BookStatus> bookService({userId, value, message}) => null;

  @override
  Future<List<Product>> getProductNearest(location) async {
    try {
      var list = <Product>[];
      var lat = location.latitude;
      var long = location.longitude;
      var urlReq =
          '$url/wp-json/wp/v2/${DataMapping().kProductPath}?status=publish&_embed=true';
      if (lat != 0 || long != 0) {
        urlReq += '&isGetLocate=true&lat=$lat&long=$long';
      }
      final response = await http.get(urlReq);
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)) {
          var product = Product.fromListingJson(item);
          var _gallery = <String>[];
          for (var item in product.images) {
            if (!item.contains('http')) {
              var res = await http.get('$url/wp-json/wp/v2/media/$item');
              _gallery.add(convert.jsonDecode(res.body)['source_url']);
            } else {
              _gallery.add(item);
            }
          }
          product.images = _gallery;
          list.add(product);
        }
      }
      printLog('getProductNearest');
      return list;
    } catch (err) {
      printLog('err at getProductRecents func ${err.toString()}');
      rethrow;
    }
  }

  @override
  Future<List<ListingBooking>> getBooking({userId, page, perPage}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> createBooking(dynamic booking) async {
    if (booking.isAvaliableOrder && booking.isEmpty == false) {
      final response = await http.post(
        '$url/wp-json/api/flutter_booking/checkout',
        body: convert.jsonEncode(booking.toJsonAPI()),
      );

      var body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body['appointment'] != null) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  @override
  Future<List<StaffBooking>> getListStaff(String idProduct) async {
    final urlAPI = wcApi.getOAuthURLExternal(
        '$url/wp-json/api/flutter_booking/get_staffs?product_id=$idProduct');

    final response = await http.get(urlAPI);

    var body = convert.jsonDecode(response.body);
    if (response.statusCode == 200) {
      final listStaff = <StaffBooking>[];
      if (body is List) {
        if (body?.isNotEmpty ?? false) {
          body.forEach((staff) {
            if (staff != null) {
              listStaff.add(StaffBooking.fromJson(staff));
            }
          });
        }
      }
      return listStaff;
    } else {
      return [];
    }
  }

  @override
  Future<List<String>> getSlotBooking(
      String idProduct, String idStaff, String date) async {
    var urlAPI =
        '$url/wp-json/api/flutter_booking/get_slots?product_id=$idProduct&date=$date';

    if ((idStaff?.isNotEmpty ?? false) && idStaff != 'null') {
      urlAPI += '&staff_ids=$idStaff';
    }

    final response = await http.get(urlAPI);
    if (response.body?.isNotEmpty ?? false) {
      final listSlot = <String>[];
      final result = convert.jsonDecode(response.body);
      if (result is List) {
        result.forEach((item) {
          if (item?.isNotEmpty ?? false) {
            listSlot.add('$item');
          }
        });
      }
      return listSlot;
    }
    return <String>[];
  }

  @override
  Future<Map<String, dynamic>> checkBookingAvailability({data}) => null;

  @override
  Future<List<Store>> getNearbyStores(Prediction prediction) => null;

  @override
  Future<Prediction> getPlaceDetail(
      Prediction prediction, String sessionToken) async {
    final isIOS = Platform.isIOS;

    try {
      var endpoint =
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=${prediction.placeId}&fields=geometry&key=${isIOS ? kGoogleAPIKey['ios'] : kGoogleAPIKey['android']}&sessiontoken=$sessionToken';

      var response = await http.get(endpoint);
      var result = convert.jsonDecode(response.body);
      var lat = result['result']['geometry']['location']['lat'].toString();
      var long = result['result']['geometry']['location']['lng'].toString();
      prediction.lat = lat;
      prediction.long = long;
    } catch (e) {
      printLog('getPlaceDetail: $e');
    }
    return prediction;
  }

  @override
  Future<List<Prediction>> getAutoCompletePlaces(
      String term, String sessionToken) async {
    final isIOS = Platform.isIOS;

    try {
      var endpoint =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$term&key=${isIOS ? kGoogleAPIKey['ios'] : kGoogleAPIKey['android']}&sessiontoken=$sessionToken';

      var response = await http.get(endpoint);
      var result = convert.jsonDecode(response.body);
      var list = <Prediction>[];
      for (var item in result['predictions']) {
        list.add(Prediction.fromJson(item));
      }
      return list;
    } catch (e) {
      printLog('getAutoCompletePlaces: $e');
    }
    return [];
  }

  @override
  Future<List<dynamic>> getLocations() => null;

  @override
  Future<List<Blog>> getBlogs<int>({
    int cursor,
    Function(int) cursorCallback,
  }) async {
    try {
      dynamic page = cursor ?? 1;

      final param = '_embed&page=$page';
      // if (categories != null) {
      //   param += '&categories=$categories';
      // }
      final response = await http.get('$url/wp-json/wp/v2/posts?$param');

      if (response.statusCode != 200) {
        return [];
      }
      List data = jsonDecode(response.body);

      cursorCallback?.call(++page);
      return data.map((json) => Blog.fromJson(json)).toList();
    } on Exception catch (_) {
      return [];
    }
  }
}
