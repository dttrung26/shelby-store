import 'dart:async';
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:quiver/strings.dart';

import '../../../common/config.dart';
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
        ProductAttribute,
        ProductVariation,
        Review,
        ShippingMethod,
        User,
        UserModel;
import '../../../services/base_services.dart';
import '../../../services/wordpress/blognews_api.dart';
import 'magento_helper.dart';

class MagentoApi extends BaseServices {
  static final MagentoApi _instance = MagentoApi._internal();

  factory MagentoApi() => _instance;

  MagentoApi._internal();

  String domain;
  String accessToken;
  String guestQuoteId;
  Map<String, ProductAttribute> attributes;

  @override
  BlogNewsApi blogApi;

  void setAppConfig(appConfig) {
    domain = appConfig['url'];
    blogApi = BlogNewsApi(appConfig['blog'] ?? 'https://mstore.io');
    accessToken = appConfig['accessToken'];
    attributes = null;
    guestQuoteId = null;
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

  Product parseProductFromJson(item) {
    final dateSaleFrom = MagentoHelper.getCustomAttribute(
        item['custom_attributes'], 'special_from_date');
    final dateSaleTo = MagentoHelper.getCustomAttribute(
        item['custom_attributes'], 'special_to_date');
    var onSale = false;
    var price = item['price'];
    var salePrice = MagentoHelper.getCustomAttribute(
        item['custom_attributes'], 'special_price');
    if (dateSaleFrom != null && dateSaleTo != null) {
      final now = DateTime.now();
      onSale = now.isAfter(DateTime.parse(dateSaleFrom)) &&
          now.isBefore(DateTime.parse(dateSaleTo));
      if (onSale && salePrice != null) {
        price = salePrice;
      }
    } else if (salePrice != null) {
      onSale = double.parse("${item["price"]}") > double.parse('$salePrice');
      price = salePrice;
    }
    final mediaGalleryEntries = item['media_gallery_entries'];
    var images = [MagentoHelper.getProductImageUrl(domain, item, 'thumbnail')];
    if (mediaGalleryEntries != null && mediaGalleryEntries.length > 1) {
      for (var item in mediaGalleryEntries) {
        images
            .add(MagentoHelper.getProductImageUrlByName(domain, item['file']));
      }
    }
    var product = Product.fromMagentoJson(item);
    final description = MagentoHelper.getCustomAttribute(
        item['custom_attributes'], 'description');
    product.description = description ??
        MagentoHelper.getCustomAttribute(
            item['custom_attributes'], 'short_description');
    if (item['type_id'] == 'configurable') {
      product.price = MagentoHelper.getCustomAttribute(
          item['custom_attributes'], 'minimal_price');
      product.regularPrice = product.price;
    } else {
      product.price = '$price';
      product.regularPrice = "${item["price"]}";
    }

    product.salePrice = MagentoHelper.getCustomAttribute(
        item['custom_attributes'], 'special_price');
    product.onSale = onSale;
    product.images = images;
    product.imageFeature = images[0];

    List<dynamic> categoryIds;
    if (item['custom_attributes'] != null &&
        item['custom_attributes'].length > 0) {
      for (var item in item['custom_attributes']) {
        if (item['attribute_code'] == 'category_ids') {
          categoryIds = item['value'];
          break;
        }
      }
    }
    product.categoryId = categoryIds.isNotEmpty ? '${categoryIds[0]}' : '0';
    product.permalink = '';

    var attrs = <ProductAttribute>[];
    final options = item['extension_attributes'] != null &&
            item['extension_attributes']['configurable_product_options'] != null
        ? item['extension_attributes']['configurable_product_options']
        : [];

    List attrsList = kAdvanceConfig['EnableAttributesConfigurableProduct'];
    List attrsLabelList =
        kAdvanceConfig['EnableAttributesLabelConfigurableProduct'];
    for (var i = 0; i < options.length; i++) {
      final option = options[i];

      for (var j = 0; j < attrsList.length; j++) {
        final item = attrsList[j];
        final itemLabel = attrsLabelList[j];
        if (option['label'].toLowerCase() ==
            itemLabel.toString().toLowerCase()) {
          List values = option['values'];
          var optionAttr = [];
          if (attributes[item] != null) {
            for (var f in attributes[item].options) {
              final value = values.firstWhere(
                  (o) => o['value_index'].toString() == f['value'],
                  orElse: () => null);
              if (value != null) {
                optionAttr.add(f);
              }
            }
            attrs.add(ProductAttribute.fromMagentoJson({
              'attribute_id': attributes[item].id,
              'attribute_code': attributes[item].name,
              'options': optionAttr
            }));
          }
        }
      }
      attrsList.forEach((item) {});
    }

    product.attributes = attrs;
    product.type = item['type_id'];
    return product;
  }

  Future<bool> getStockStatus(sku) async {
    try {
      var response = await http.get(
          MagentoHelper.buildUrl(domain, 'stockItems/$sku'),
          headers: {'Authorization': 'Bearer ' + accessToken});

      final body = convert.jsonDecode(response.body);
      return body['is_in_stock'] ?? false;
    } catch (e) {
      rethrow;
    }
  }

  Future getAllAttributes() async {
    try {
      attributes = <String, ProductAttribute>{};
      List attrs = kAdvanceConfig['EnableAttributesConfigurableProduct'];
      attrs.forEach((item) async {
        var attrsItem = await getProductAttributes(item);
        attributes[item] = attrsItem;
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductAttribute> getProductAttributes(String attributeCode) async {
    try {
      var response = await http.get(
          MagentoHelper.buildUrl(domain, 'products/attributes/$attributeCode'),
          headers: {'Authorization': 'Bearer ' + accessToken});

      final body = convert.jsonDecode(response.body);
      if (body['message'] != null) {
        throw Exception(MagentoHelper.getErrorMessage(body));
      } else {
        return ProductAttribute.fromMagentoJson(body);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Category>> getCategories({lang}) async {
    try {
      var response = await http.get(
          MagentoHelper.buildUrl(domain, 'mstore/categories', lang),
          headers: {'Authorization': 'Bearer ' + accessToken});
      var list = <Category>[];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)['children_data']) {
          if (item['is_active'] == true) {
            var category = Category.fromMagentoJson(item);
            category.parent = '0';
            if (item['image'] != null) {
              category.image = item['image'].toString().contains('media/')
                  ? "$domain/${item["image"]}"
                  : "$domain/pub/media/catalog/category/${item["image"]}";
            }
            list.add(category);

            for (var item1 in item['children_data']) {
              if (item1['is_active'] == true) {
                list.add(Category.fromMagentoJson(item1));

                for (var item2 in item1['children_data']) {
                  if (item1['is_active'] == true) {
                    list.add(Category.fromMagentoJson(item2));
                  }
                }
              }
            }
          }
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
      var response = await http.get(
          MagentoHelper.buildUrl(
              domain, 'mstore/products&searchCriteria[pageSize]=$ApiPageSize'),
          headers: {'Authorization': 'Bearer ' + accessToken});
      var list = <Product>[];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)['items']) {
          var product = parseProductFromJson(item);
          list.add(product);
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

      var endPoint = '?';
      if (config.containsKey('category')) {
        endPoint +=
            "searchCriteria[filter_groups][0][filters][0][field]=category_id&searchCriteria[filter_groups][0][filters][0][value]=${config["category"]}&searchCriteria[filter_groups][0][filters][0][condition_type]=eq&searchCriteria[pageSize]=$ApiPageSize";
      }
      if (config.containsKey('page')) {
        endPoint += "&searchCriteria[currentPage]=${config["page"]}";
      }
      endPoint +=
          '&searchCriteria[filter_groups][1][filters][0][field]=visibility&searchCriteria[filter_groups][1][filters][0][value]=4';

      var response = await http.get(
          MagentoHelper.buildUrl(domain, 'mstore/products$endPoint', lang),
          headers: {'Authorization': 'Bearer ' + accessToken});

      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)['items']) {
          var product = parseProductFromJson(item);
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
      lang,
      orderBy,
      order,
      featured,
      onSale,
      attribute,
      attributeTerm,
      listingLocation,
      userId}) async {
    try {
      var endPoint = '?';
      if (categoryId != null) {
        endPoint +=
            'searchCriteria[filter_groups][0][filters][0][field]=category_id&searchCriteria[filter_groups][0][filters][0][value]=$categoryId&searchCriteria[filter_groups][0][filters][0][condition_type]=eq';
      }
      if (maxPrice != null) {
        endPoint +=
            '&searchCriteria[filter_groups][0][filters][1][field]=price&searchCriteria[filter_groups][0][filters][1][value]=$maxPrice&searchCriteria[filter_groups][0][filters][1][condition_type]=lteq';
      }
      if (page != null) {
        endPoint += '&searchCriteria[currentPage]=$page';
      }
      if (orderBy != null) {
        endPoint +=
            "&searchCriteria[sortOrders][1][field]=${orderBy == "date" ? "created_at" : orderBy}";
      }
      if (order != null) {
        endPoint +=
            '&searchCriteria[sortOrders][1][direction]=${(order as String).toUpperCase()}';
      }
      endPoint += '&searchCriteria[pageSize]=$ApiPageSize';

      endPoint +=
          '&searchCriteria[filter_groups][1][filters][0][field]=visibility&searchCriteria[filter_groups][1][filters][0][value]=4';

      var response = await http.get(
          MagentoHelper.buildUrl(domain, 'mstore/products$endPoint', lang),
          headers: {'Authorization': 'Bearer ' + accessToken});

      var list = <Product>[];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)['items']) {
          var product = parseProductFromJson(item);
          list.add(product);
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
          MagentoHelper.buildUrl(domain, 'mstore/social_login'),
          body: convert.jsonEncode({'token': token, 'type': 'facebook'}),
          headers: {'content-type': 'application/json'});

      if (response.statusCode == 200) {
        final token = convert.jsonDecode(response.body);
        var user = await getUserInfo(token);
        user.isSocial = true;
        return user;
      } else {
        final body = convert.jsonDecode(response.body);
        throw Exception(body['message'] != null
            ? MagentoHelper.getErrorMessage(body)
            : 'Can not get token');
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<User> loginSMS({String token}) async {
    try {
      var response = await http.post(
        MagentoHelper.buildUrl(domain, 'mstore/social_login'),
        body: convert.jsonEncode({'token': token, 'type': 'firebase_sms'}),
        headers: {'content-type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final token = convert.jsonDecode(response.body);
        var user = await getUserInfo(token);
        user.isSocial = true;
        return user;
      } else {
        final body = convert.jsonDecode(response.body);
        throw Exception(body['message'] != null
            ? MagentoHelper.getErrorMessage(body)
            : 'Can not get token');
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<Review>> getReviews(productId) {
    return null;
  }

  @override
  Future<List<ProductVariation>> getProductVariations(Product product,
      {String lang = 'en'}) async {
    try {
      final res = await http.get(
          MagentoHelper.buildUrl(
              domain, 'configurable-products/${product.sku}/children'),
          headers: {
            'Authorization': 'Bearer ' + accessToken,
            'content-type': 'application/json'
          });

      var list = <ProductVariation>[];
      if (res.statusCode == 200) {
        for (var item in convert.jsonDecode(res.body)) {
          var prod = ProductVariation.fromMagentoJson(item, product);
          prod.inStock = await getStockStatus(prod.sku);
          list.add(prod);
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
      var url = token != null
          ? MagentoHelper.buildUrl(
              domain, 'carts/mine/estimate-shipping-methods')
          : MagentoHelper.buildUrl(
              domain, 'guest-carts/$guestQuoteId/estimate-shipping-methods');
      final res = await http.post(url,
          body: convert.jsonEncode({
            'address': {'country_id': address.country}
          }),
          headers: token != null
              ? {
                  'Authorization': 'Bearer ' + token,
                  'content-type': 'application/json'
                }
              : {'content-type': 'application/json'});

      if (res.statusCode == 200) {
        var list = <ShippingMethod>[];
        for (var item in convert.jsonDecode(res.body)) {
          list.add(ShippingMethod.fromMagentoJson(item));
        }
        return list;
      } else {
        final body = convert.jsonDecode(res.body);
        throw Exception(body['message'] != null
            ? MagentoHelper.getErrorMessage(body)
            : 'Can not get shipping methods');
      }
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
      var address = cartModel.address;
      final params = {
        'addressInformation': {
          'shipping_address': address.toMagentoJson()['address'],
          'billing_address': address.toMagentoJson()['address'],
          'shipping_carrier_code': shippingMethod.id,
          'shipping_method_code': shippingMethod.methodId
        }
      };
      var url = token != null
          ? MagentoHelper.buildUrl(domain, 'carts/mine/shipping-information')
          : MagentoHelper.buildUrl(
              domain, 'guest-carts/$guestQuoteId/shipping-information');
      final res = await http.post(url,
          body: convert.jsonEncode(params),
          headers: token != null
              ? {
                  'Authorization': 'Bearer ' + token,
                  'content-type': 'application/json'
                }
              : {'content-type': 'application/json'});

      final body = convert.jsonDecode(res.body);
      if (res.statusCode == 200) {
        var list = <PaymentMethod>[];
        for (var item in body['payment_methods']) {
          list.add(PaymentMethod.fromMagentoJson(item));
        }
        return list;
      } else if (body['message'] != null) {
        throw Exception(MagentoHelper.getErrorMessage(body));
      } else {
        throw Exception('Can not get payment methods');
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<Order>> getMyOrders({UserModel userModel, int page}) async {
    try {
      var endPoint = '?';
      endPoint +=
          'searchCriteria[filter_groups][0][filters][0][field]=customer_email&searchCriteria[filter_groups][0][filters][0][value]=${userModel.user.email}&searchCriteria[filter_groups][0][filters][0][condition_type]=eq';
      endPoint += '&searchCriteria[currentPage]=0';
      endPoint += '&searchCriteria[pageSize]=$ApiPageSize';

      var response = await http.get(
          MagentoHelper.buildUrl(domain, 'orders$endPoint'),
          headers: {'Authorization': 'Bearer ' + accessToken});

      var list = <Order>[];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)['items']) {
          list.add(Order.fromMagentoJson(item));
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
      var isGuest = user.user == null || user.user.cookie == null;
      var url = !isGuest
          ? MagentoHelper.buildUrl(domain, 'carts/mine/payment-information')
          : MagentoHelper.buildUrl(
              domain, 'guest-carts/$guestQuoteId/payment-information');
      var params = Order().toMagentoJson(cartModel, null, paid);
      if (isGuest) {
        params['email'] = cartModel.address.email;
        params['firstname'] = cartModel.address.firstName;
        params['lastname'] = cartModel.address.lastName;
      }

      final res = await http.post(url,
          body: convert.jsonEncode(params),
          headers: !isGuest
              ? {
                  'Authorization': 'Bearer ' + user.user.cookie,
                  'content-type': 'application/json'
                }
              : {'content-type': 'application/json'});

      final body = convert.jsonDecode(res.body);
      if (res.statusCode == 200) {
        var order = Order();
        order.id = body.toString();
        order.number = body.toString();
        return order;
      } else {
        if (body['message'] != null) {
          throw Exception(MagentoHelper.getErrorMessage(body));
        } else {
          throw Exception('Can not create order');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future updateOrder(orderId, {status, token}) async {
    try {
      var response = await http.post(
        MagentoHelper.buildUrl(domain, 'mstore/me/orders/$orderId/cancel'),
        body: convert.jsonEncode({}),
        headers: {
          'Authorization': 'Bearer ' + token,
          'content-type': 'application/json'
        },
      );
      final body = convert.jsonDecode(response.body);
      if (body is Map && body['message'] != null) {
        throw Exception(MagentoHelper.getErrorMessage(body));
      } else {
        return;
      }
    } catch (err) {
      rethrow;
    }
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
      var endPoint = '?';
      if (name != null) {
        endPoint +=
            'searchCriteria[filter_groups][0][filters][0][field]=name&searchCriteria[filter_groups][0][filters][0][value]=%$name%&searchCriteria[filter_groups][0][filters][0][condition_type]=like';
      }
      if (page != null) {
        endPoint += '&searchCriteria[currentPage]=$page';
      }
      endPoint += '&searchCriteria[pageSize]=$ApiPageSize';
      endPoint +=
          '&searchCriteria[filter_groups][1][filters][0][field]=visibility&searchCriteria[filter_groups][1][filters][0][value]=4';

      var response = await http.get(
          MagentoHelper.buildUrl(domain, 'mstore/products$endPoint'),
          headers: {'Authorization': 'Bearer ' + accessToken});

      var list = <Product>[];
      if (response.statusCode == 200) {
        final body = convert.jsonDecode(response.body);
        if (!MagentoHelper.isEndLoadMore(body)) {
          for (var item in body['items']) {
            var product = parseProductFromJson(item);
            list.add(product);
          }
        }
      }
      return list;
    } catch (err, trace) {
      printLog(trace);
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
      var response =
          await http.post(MagentoHelper.buildUrl(domain, 'customers'),
              body: convert.jsonEncode({
                'customer': {
                  'email': username,
                  'firstname': firstName,
                  'lastname': lastName
                },
                'password': password
              }),
              headers: {'content-type': 'application/json'});

      if (response.statusCode == 200) {
        return await login(username: username, password: password);
      } else {
        final body = convert.jsonDecode(response.body);
        throw Exception(body['message'] != null
            ? MagentoHelper.getErrorMessage(body)
            : 'Can not get token');
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<User> getUserInfo(cookie) async {
    var res = await http.get(MagentoHelper.buildUrl(domain, 'customers/me'),
        headers: {'Authorization': 'Bearer ' + cookie});
    return User.fromMagentoJson(convert.jsonDecode(res.body), cookie);
  }

  @override
  Future<User> login({username, password}) async {
    try {
      var response = await http.post(
          MagentoHelper.buildUrl(domain, 'integration/customer/token'),
          body:
              convert.jsonEncode({'username': username, 'password': password}),
          headers: {'content-type': 'application/json'});

      if (response.statusCode == 200) {
        final token = convert.jsonDecode(response.body);
        var user = await getUserInfo(token);
        return user;
      } else {
        final body = convert.jsonDecode(response.body);
        throw Exception(body['message'] != null
            ? MagentoHelper.getErrorMessage(body)
            : 'Can not get token');
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<User> loginApple({String email, String fullName}) async {
    try {
      final lastName =
          fullName.split(' ').length > 1 ? fullName.split(' ')[1] : 'fluxstore';
      var response = await http.post(
        MagentoHelper.buildUrl(domain, 'mstore/appleLogin'),
        body: convert.jsonEncode({
          'email': email,
          'firstName': fullName.split(' ')[0],
          'lastName': lastName
        }),
        headers: {'content-type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final token = convert.jsonDecode(response.body);
        var user = await getUserInfo(token);
        user.isSocial = true;
        return user;
      } else {
        final body = convert.jsonDecode(response.body);
        throw Exception(body['message'] != null
            ? MagentoHelper.getErrorMessage(body)
            : 'Can not get token');
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<Product> getProduct(id, {lang}) async {
    return null;
  }

  Future<bool> addToCart(CartModel cartModel, String token, quoteId,
      {isDelete = false, guestCartId}) async {
    try {
      //delete items in cart
      if (isDelete) {
        await Future.forEach(cartModel.productsInCart.keys, (key) async {
          var productId = Product.cleanProductID(key);

          await http.delete(
              MagentoHelper.buildUrl(domain, 'carts/mine/items/$productId'),
              headers: {'Authorization': 'Bearer $token'});
        });
        await http.delete(MagentoHelper.buildUrl(domain, 'carts/mine/coupons'),
            headers: {'Authorization': 'Bearer $token'});
      }
      //add items to cart
      await Future.forEach(cartModel.productsInCart.keys, (key) async {
        var params = <String, dynamic>{};
        params['qty'] = cartModel.productsInCart[key];
        params['quote_id'] = quoteId;
        params['sku'] = cartModel.productSkuInCart[key];
        final res = await http.post(
            guestCartId == null
                ? MagentoHelper.buildUrl(domain, 'carts/mine/items')
                : MagentoHelper.buildUrl(domain, 'guest-carts/$quoteId/items'),
            body: convert.jsonEncode({'cartItem': params}),
            headers: token != null
                ? {
                    'Authorization': 'Bearer ' + token,
                    'content-type': 'application/json'
                  }
                : {'content-type': 'application/json'});
        final body = convert.jsonDecode(res.body);
        if (body['messages'] != null &&
            body['messages']['error'] != null &&
            body['messages']['error'][0].length > 0) {
          throw MagentoHelper.getErrorMessage(body['messages']['error'][0]);
        } else if (body['message'] != null) {
          throw MagentoHelper.getErrorMessage(body);
        } else {
          printLog(body);
          return;
        }
      });
      return true;
    } catch (err) {
      rethrow;
    }
  }

  Future<bool> addItemsToCart(CartModel cartModel, String token) async {
    try {
      if (token != null) {
        //get cart info
        var res = await http.get(MagentoHelper.buildUrl(domain, 'carts/mine'),
            headers: {'Authorization': 'Bearer ' + token});
        final cartInfo = convert.jsonDecode(res.body);
        if (res.statusCode == 200) {
          return await addToCart(cartModel, token, cartInfo['id'],
              isDelete: true);
        } else if (res.statusCode == 401) {
          throw Exception('Token expired. Please logout then login again');
        } else if (res.statusCode != 404) {
          throw Exception(MagentoHelper.getErrorMessage(cartInfo));
        }
      }

      //create a quote
      var url = token != null
          ? MagentoHelper.buildUrl(domain, 'carts/mine')
          : MagentoHelper.buildUrl(domain, 'guest-carts');
      var res = await http.post(url,
          headers: token != null ? {'Authorization': 'Bearer ' + token} : {});
      if (res.statusCode == 200) {
        if (token != null) {
          final quoteId = convert.jsonDecode(res.body);
          return await addToCart(cartModel, token, quoteId);
        } else {
          String quoteId = convert.jsonDecode(res.body);
          var response = await http
              .get(MagentoHelper.buildUrl(domain, 'guest-carts/$quoteId'));
          final cartInfo = convert.jsonDecode(response.body);
          if (response.statusCode == 200) {
            final cartId = cartInfo['id'];
            guestQuoteId = quoteId;
            return await addToCart(cartModel, token, quoteId,
                guestCartId: cartId);
          } else {
            throw Exception(MagentoHelper.getErrorMessage(cartInfo));
          }
        }
      } else {
        throw Exception(
            MagentoHelper.getErrorMessage(convert.jsonDecode(res.body)));
      }
    } catch (err) {
      rethrow;
    }
  }

  Future<double> applyCoupon(String token, String coupon) async {
    try {
      var url = token != null
          ? MagentoHelper.buildUrl(domain, 'carts/mine/coupons/$coupon')
          : MagentoHelper.buildUrl(
              domain, 'guest-carts/$guestQuoteId/coupons/$coupon');
      var res = await http.put(url,
          headers: token != null ? {'Authorization': 'Bearer ' + token} : {});
      var body = convert.jsonDecode(res.body);
      if (res.statusCode == 200) {
        var totalUrl = token != null
            ? MagentoHelper.buildUrl(domain, 'carts/mine/totals')
            : MagentoHelper.buildUrl(
                domain, 'guest-carts/$guestQuoteId/totals');
        var res = await http.get(totalUrl,
            headers: token != null ? {'Authorization': 'Bearer ' + token} : {});
        body = convert.jsonDecode(res.body);
        if (body['message'] != null) {
          throw Exception(MagentoHelper.getErrorMessage(body));
        } else {
          var discount = double.parse("${body['discount_amount']}");
          return discount < 0 ? discount * (-1) : discount;
        }
      } else {
        throw Exception(MagentoHelper.getErrorMessage(body));
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<Coupons> getCoupons() async {
    try {
      return Coupons.getListCoupons([]);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> loginGoogle({String token}) async {
    try {
      var response = await http.post(
          MagentoHelper.buildUrl(domain, 'mstore/social_login'),
          body: convert.jsonEncode({'token': token, 'type': 'google'}),
          headers: {'content-type': 'application/json'});

      if (response.statusCode == 200) {
        final token = convert.jsonDecode(response.body);
        var user = await getUserInfo(token);
        user.isSocial = true;
        return user;
      } else {
        final body = convert.jsonDecode(response.body);
        throw Exception(body['message'] != null
            ? MagentoHelper.getErrorMessage(body)
            : 'Can not get token');
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateUserInfo(
      Map<String, dynamic> json, String token) async {
    try {
      if (isNotBlank(json['user_email'])) {
        var response = await http.post(
          MagentoHelper.buildUrl(domain, 'mstore/customers/me/changeEmail'),
          body: convert.jsonEncode({
            'new_email': json['user_email'],
            'current_password': json['current_pass']
          }),
          headers: {
            'Authorization': 'Bearer ' + token,
            'content-type': 'application/json'
          },
        );
        final body = convert.jsonDecode(response.body);
        if (body is Map && body['message'] != null) {
          throw Exception(MagentoHelper.getErrorMessage(body));
        }
      }
      if (isNotBlank(json['user_pass'])) {
        var response = await http.post(
          MagentoHelper.buildUrl(domain, 'mstore/customers/me/changePassword'),
          body: convert.jsonEncode({
            'new_password': json['user_pass'],
            'confirm_password': json['user_pass'],
            'current_password': json['current_pass']
          }),
          headers: {
            'Authorization': 'Bearer ' + token,
            'content-type': 'application/json'
          },
        );
        final body = convert.jsonDecode(response.body);
        if (body is Map && body['message'] != null) {
          throw Exception(MagentoHelper.getErrorMessage(body));
        }
      }
      return json;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future getCountries() async {
    var response =
        await http.get(MagentoHelper.buildUrl(domain, 'directory/countries'));
    final body = convert.jsonDecode(response.body);
    return body;
  }

  Future<bool> resetPassword(String email) async {
    try {
      var response = await http.put(
        MagentoHelper.buildUrl(domain, 'customers/password'),
        body: convert.jsonEncode({'email': email, 'template': 'email_reset'}),
        headers: {
          'Authorization': 'Bearer ' + accessToken,
          'content-type': 'application/json'
        },
      );

      return convert.jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }
}
