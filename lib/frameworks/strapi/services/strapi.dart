import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../models/entities/blog.dart';
import '../../../models/index.dart'
    show
        BlogNews,
        CartModel,
        Category,
        Order,
        PaymentMethod,
        Product,
        ProductVariation,
        ShippingMethod,
        User,
        UserModel;
import '../../../models/serializers/index.dart' show SerializerProduct;
import '../../../services/base_services.dart';
import '../../../services/wordpress/blognews_api.dart';
import 'strapi_api.dart';

class Strapi extends BaseServices {
  static final Strapi _instance = Strapi._internal();

  factory Strapi() => _instance;

  Strapi._internal();

  String url;

  StrapiAPI strapiAPI;
  List<Category> cats;
  List<Map<String, dynamic>> product_options;
  List<Map<String, dynamic>> product_option_values;
  String id_lang;
  String language_code;
  Map<String, dynamic> configCache;

  @override
  BlogNewsApi blogApi;

  void appConfig(appConfig) {
    blogApi = BlogNewsApi(appConfig['blog'] ?? appConfig['url']);
    strapiAPI = StrapiAPI(appConfig['url']);
    url = appConfig['url'];
  }

  @override
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
      var list = <Category>[];
      var response = await strapiAPI.getAsync('/product-categories');

      for (var item in response) {
        list.add(Category.fromJsonStrapi(item, strapiAPI.apiLink));
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> getProducts({userId}) async {
    try {
      var productList = <Product>[];
      var response = await strapiAPI.getAsync('/products');

      for (var json in response) {
        var model = SerializerProduct.fromJson(json);
        productList.add(Product.fromJsonStrapi(model, strapiAPI.apiLink));
      }

      return productList;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getHomeCache(String lang) async {
    try {
      if (kAdvanceConfig['isCaching']) {
        var categoryList = <String, Category>{};

        final categories = await getCategories(lang: lang);

        for (var cat in categories) {
          categoryList[cat.id] = cat;
        }

        final appJson = await rootBundle.loadString(kAppConfig);

        var config = convert.jsonDecode(appJson);

        if (config['HorizonLayout'] != null) {
          var horizontalLayout = config['HorizonLayout'] as List;
          var items = [];

          for (var i = 0; i < horizontalLayout.length; i++) {
            var categoryID = horizontalLayout[i]['category'].toString();
            config['HorizonLayout'][i]['data'] =
                categoryList[categoryID] != null
                    ? categoryList[categoryID].products
                    : [];

            items = horizontalLayout[i]['items'];
            if (items != null && items.isNotEmpty) {
              for (var j = 0; j < items.length; j++) {
                var _categoryID = items[j]['category'].toString();
                items[j]['data'] = categoryList[_categoryID]?.products;
              }
            }
            horizontalLayout[i]['items'] = items;
          }

          if (config['VerticalLayout'] != null) {
            var vCategory = config['VerticalLayout']['category'].toString();
            config['VerticalLayout']['data'] =
                categoryList[vCategory]?.products;
          }
          configCache = config;
          return config;
        }
      }
      return configCache;
    } catch (e, trace) {
      printLog(trace);
      printLog(e);
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      return null;
    }
  }

  @override
  Future<List<Product>> fetchProductsLayout({config, lang, userId}) async {
    try {
      /// If enable Caching we should find the layout config inside configCache
      if (config.containsKey('page') &&
          int.parse(config['page'].toString()) > 1) return [];
      if (kAdvanceConfig['isCaching'] && configCache != null) {
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

      var productList = <Product>[];
      var endPoint = '/products';
      if (config['category'] != null) {
        endPoint += '?product_categories=${config['category']}';
      }
      var response = await strapiAPI.getAsync(endPoint);
      for (var item in response) {
        var model = SerializerProduct.fromJson(item);
        productList.add(Product.fromJsonStrapi(model, strapiAPI.apiLink));
      }
      return productList;
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

      var endPoint = '/products?';
      if (categoryId != null) {
        endPoint += '&product_categories=$categoryId';
      }
      var response = await strapiAPI.getAsync(endPoint);

      for (var item in response) {
        var model = SerializerProduct.fromJson(item);
        list.add(Product.fromJsonStrapi(model, strapiAPI.apiLink));
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Product> getProduct(id, {lang, cursor}) async {
    printLog('::::request getProduct $id');

    var response = await strapiAPI.getAsync('/products/$id');
    var model = SerializerProduct.fromJson(response);
    return Product.fromJsonStrapi(model, strapiAPI.apiLink);
  }

  @override
  Future<List<ProductVariation>> getProductVariations(Product product,
      {String lang = 'en'}) async {
    return null;
  }

  @override
  Future<List<ShippingMethod>> getShippingMethods(
      {CartModel cartModel, String token, String checkoutId}) async {
    var lists = <ShippingMethod>[];
    var endPoint = '/shippings';
    var response = await strapiAPI.getAsync(endPoint);
    for (var item in response) {
      lists.add(ShippingMethod.fromStrapi(item));
    }
    return lists;
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods(
      {CartModel cartModel,
      ShippingMethod shippingMethod,
      String token}) async {
    var lists = <PaymentMethod>[];
    var endPoint = '/payments';
    var response = await strapiAPI.getAsync(endPoint);
    for (var item in response) {
      lists.add(PaymentMethod.fromStrapiJson(item));
    }
    return lists;
  }

  @override
  Future<List<Order>> getMyOrders({UserModel userModel, int page}) async {
    var list = <Order>[];
    var response =
        await strapiAPI.getAsync('/orders?user=${userModel.user.id}');
    for (var item in response) {
      list.add(Order.fromStrapiJson(item));
    }
    return list;
  }

  @override
  Future<Order> createOrder(
      {CartModel cartModel,
      UserModel user,
      bool paid,
      String transactionId}) async {
    var id_shipping = cartModel.shippingMethod.id;
    var id_user = user.user.id;
    var user_jwtToken = user.user.jwtToken;
    var id_payment = cartModel.paymentMethod.id;
    var total = cartModel.getTotal();
    final products = cartModel.item;
    // ignore: omit_local_variable_types
    Map data = {
      'total': total,
      'user': id_user,
      'shipping': id_shipping,
      'payment': id_payment,
      'products': products.keys.toList(),
    };
    var body = json.encode(data);
    final response = await http.post(
      '$url/orders',
      headers: {'Content-Type': 'application/json', 'Token': user_jwtToken},
      body: body,
    );
    var responseBody = convert.jsonDecode(response.body);
    return Order.fromStrapiJson(responseBody);
  }

  @override
  Future<List<Product>> searchProducts(
      {name,
      categoryId,
      tag = '',
      attribute = '',
      attributeId = '',
      page,
      lang,
      listingLocation,
      userId}) async {
    try {
      var list = <Product>[];
      var response = await strapiAPI.getAsync(
          '/products?title_contains=$name&product_categories_contains=$categoryId');
      for (var item in response) {
        var model = SerializerProduct.fromJson(item);
        list.add(Product.fromJsonStrapi(model, strapiAPI.apiLink));
      }
      return list;
    } catch (e) {
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
      // ignore: omit_local_variable_types
      Map data = {
        'displayName': niceName,
        'username': username,
        'email': username,
        'password': password,
      };
      //encode Map to JSON
      var body = json.encode(data);
      final response = await http.post('$url/auth/local/register/',
          headers: {'Content-Type': 'application/json'}, body: body);
      var user;
      var responseBody = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && responseBody['jwt'] != null) {
        user = User.fromStrapi(responseBody);
      } else {
        throw ('[Strapi] createUser fail');
      }
      return user;
    } catch (e, trace) {
      printLog(e.toString());
      printLog(trace.toString());
      rethrow;
    }
  }

  /// login
  @override
  Future<User> login({username, password}) async {
    try {
      // ignore: omit_local_variable_types
      Map data = {
        'identifier': username,
        'password': password,
      };
      var body = json.encode(data);
      final response = await http.post('$url/auth/local',
          headers: {'Content-Type': 'application/json'}, body: body);
      var user;
      var responseBody = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && responseBody['jwt'] != null) {
        user = User.fromStrapi(responseBody);
      } else {
        throw ('[Strapi] login fail');
      }
      return user;
    } catch (err, trace) {
      printLog(err.toString());
      printLog(trace.toString());
      return null;
    }
  }

  @override
  Future<List<Blog>> getBlogs<int>({
    int cursor,
    Function(int) cursorCallback,
  }) async {
    final response = await http.get('$url/posts');
    List data = jsonDecode(response.body);
    return data.map((json) => Blog.fromJson(json)).toList();
  }
}
