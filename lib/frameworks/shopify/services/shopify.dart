import 'dart:async';
import 'dart:convert' as convert;

import 'package:graphql/client.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:random_string/random_string.dart';
import 'package:uuid/uuid.dart';

import '../../../common/constants.dart';
import '../../../models/entities/blog.dart';
import '../../../models/index.dart'
    show
        Address,
        BlogNews,
        CartModel,
        Category,
        CheckoutCart,
        Coupons,
        CreditCardModel,
        Order,
        PaymentMethod,
        PaymentSettings,
        PaymentSettingsModel,
        Product,
        ProductModel,
        ProductVariation,
        Review,
        ShippingMethod,
        User,
        UserModel;
import '../../../services/base_services.dart';
import '../../../services/service_config.dart';
import '../../../services/wordpress/blognews_api.dart';
import 'auto_link.dart';
import 'shopify_query.dart';
import 'shopify_storage.dart';

class ShopifyApi extends BaseServices {
  static final ShopifyApi _instance = ShopifyApi._internal();

  factory ShopifyApi() => _instance;

  ShopifyApi._internal();

  String cookie;
  String domain;
  GraphQLClient client;

  @override
  BlogNewsApi blogApi;
  ShopifyStorage shopifyStorage = ShopifyStorage();

  GraphQLClient getClient() {
    final httpLink = HttpLink(
      uri: '$domain/api/graphql',
    );
    final authLink = HeaderLink(
      getToken: () async => '${Config().accessToken}',
    );
    return GraphQLClient(
      cache: InMemoryCache(),
      link: authLink.concat(httpLink),
    );
  }

  void setAppConfig(appConfig) {
    domain = appConfig['url'];
    blogApi = BlogNewsApi(appConfig['blog'] ?? 'https://demo.mstore.io');
    client = getClient();
    getCookie();
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
  Future<List<Blog>> getBlogs<String>({
    String cursor,
    Function(String) cursorCallback,
  }) async {
    try {
      printLog('::::request blogs');

      const nRepositories = 50;
      final options = QueryOptions(
        documentNode: gql(ShopifyQuery.getArticle),
        variables: {
          'nRepositories': nRepositories,
          'pageSize': 12,
          if (cursor != null) 'cursor': cursor,
        },
      );
      final result = await client.query(options);

      if (result.hasException) {
        printLog(result.exception.toString());
      }

      var list = <Blog>[];

      var _cursor;
      for (var item in result.data['shop']['articles']['edges']) {
        var blog = item['node'];
        _cursor = item['cursor'];
        list.add(Blog.fromJson(blog));
      }

      // printLog(list);
      cursorCallback?.call(_cursor);
      return list;
    } catch (e) {
      printLog('::::fetchBlogLayout shopify error');
      printLog(e.toString());
      rethrow;
    }
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
      printLog(err);
      cookie =
          'OCSESSID=' + randomNumeric(30) + '; PHPSESSID=' + randomNumeric(30);
    }
  }

  @override
  Future<List<Category>> getCategories({lang}) async {
    try {
      printLog('::::request category');

      const nRepositories = 50;
      final options = QueryOptions(
        documentNode: gql(ShopifyQuery.readCollections),
        variables: <String, dynamic>{
          'nRepositories': nRepositories,
        },
      );
      final result = await client.query(options);

      if (result.hasException) {
        printLog(result.exception.toString());
      }

      var list = <Category>[];

      for (var item in result.data['shop']['collections']['edges']) {
        var category = item['node'];

        list.add(Category.fromJsonShopify(category));
      }

      printLog(list);
      return list;
    } catch (e) {
      printLog('::::getCategories shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Product>> getProducts({cursor, userId}) async {
    try {
      printLog('::::request products');

      const nRepositories = 50;
      final options = QueryOptions(
        documentNode: gql(ShopifyQuery.getProducts),
        variables: <String, dynamic>{
          'nRepositories': nRepositories,
          'cursor': cursor
        },
      );
      final result = await client.query(options);

      if (result.hasException) {
        printLog(result.exception.toString());
      }

      var list = <Product>[];

      for (var item in result.data['shop']['products']['edges']) {
        list.add(item['node']);
      }

      printLog(list);

      return list;
    } catch (e) {
      printLog('::::getProducts shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Product>> fetchProductsLayout(
      {config, lang, ProductModel productModel, userId}) async {
    try {
      var list = <Product>[];
      if (config['layout'] == 'imageBanner' ||
          config['layout'] == 'circleCategory') {
        return list;
      }

      return await fetchProductsByCategory(
          categoryId: config['category'].toString(),
          productModel: productModel,
          page: config.containsKey('page') ? config['page'] : 1
          );
    } catch (e) {
      printLog('::::fetchProductsLayout shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  // get sort key to filter product
  String getProductSortKey(onSale, featured, orderBy) {
    if (onSale == true) return 'BEST_SELLING';

    if (featured == true) return 'PRICE';

    if (orderBy == 'date') return 'UPDATED_AT';

    return 'PRODUCT_TYPE';
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
      ProductModel productModel,
      listingLocation,
      userId}) async {
    printLog(
        '::::request fetchProductsByCategory with category id $categoryId');
    printLog(
        '::::request fetchProductsByCategory with cursor ${shopifyStorage.cursor}');

    /// change category id
    if (page == 1) {
      shopifyStorage.cursor = '';
      shopifyStorage.hasNextPage = true;
    }

    printLog(
        'fetchProductsByCategory with shopifyStorage ${shopifyStorage.toJson()}');

    try {
      var list = <Product>[];

      if (!shopifyStorage.hasNextPage) {
        return list;
      }

      var currentCursor = shopifyStorage.cursor;

      const nRepositories = 50;
      final options = QueryOptions(
        documentNode: gql(ShopifyQuery.getProductByCollection),
        variables: <String, dynamic>{
          'nRepositories': nRepositories,
          'categoryId': categoryId,
          'pageSize': 20,
//          'sortKey': sortKey,
          'cursor': currentCursor != '' ? currentCursor : null
        },
      );
      final result = await client.query(options);

      if (result.hasException) {
        printLog(result.exception.toString());
      }

      var node = result.data['node'];

      // printLog('fetchProductsByCategory with new node $node');

      if (node != null) {
        var productResp = node['products'];
        var pageInfo = productResp['pageInfo'];
        var hasNextPage = pageInfo['hasNextPage'];
        var edges = productResp['edges'];

        printLog(
            'fetchProductsByCategory with products length ${edges.length}');

        if (edges.length != 0) {
          var lastItem = edges.last;
          var cursor = lastItem['cursor'];

          printLog('fetchProductsByCategory with new cursor $cursor');

          // set next cursor
          shopifyStorage.setShopifyStorage(cursor, categoryId, hasNextPage);
        }

        for (var item in result.data['node']['products']['edges']) {
          var product = item['node'];
          product['categoryId'] = categoryId;
          list.add(Product.fromShopify(product));
        }
      }

      return list;
    } catch (e) {
      printLog('::::fetchProductsByCategory shopify error $e');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Review>> getReviews(productId) async {
    var list = <Review>[];

    return list;
  }

  Future<Address> updateShippingAddress(
      {Address address, String checkoutId}) async {
    try {
      final options = MutationOptions(
        documentNode: gql(ShopifyQuery.updateShippingAddress),
        variables: {'shippingAddress': address, 'checkoutId': checkoutId},
      );

      final result = await client.mutate(options);

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }

      printLog('updateShippingAddress $result');

      return null;
    } catch (e) {
      printLog('::::updateShippingAddress shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<ShippingMethod>> getShippingMethods(
      {CartModel cartModel, String token, String checkoutId}) async {
    try {
      var list = <ShippingMethod>[];
      var newAddress = cartModel.address.toShopifyJson()['address'];

      printLog('getShippingMethods with checkoutId $checkoutId');

      final options = MutationOptions(
        documentNode: gql(ShopifyQuery.updateShippingAddress),
        variables: {'shippingAddress': newAddress, 'checkoutId': checkoutId},
      );

      final result = await client.mutate(options);

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }

      var checkout = result.data['checkoutShippingAddressUpdateV2']['checkout'];
      var availableShippingRates = checkout['availableShippingRates'];

      if (availableShippingRates['ready']) {
        for (var item in availableShippingRates['shippingRates']) {
          list.add(ShippingMethod.fromShopifyJson(item));
        }
      }

      // update checkout
      CheckoutCart.fromJsonShopify(checkout);

      printLog('getShippingMethods $list');

      return list;
    } catch (e) {
      printLog('::::getShippingMethods shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  Future updateShippingLine(
      String checkoutId, String shippingRateHandle) async {
    try {
      final options = MutationOptions(
        documentNode: gql(ShopifyQuery.updateShippingLine),
        variables: {
          'checkoutId': checkoutId,
          'shippingRateHandle': shippingRateHandle
        },
      );

      final result = await client.mutate(options);

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }

      var checkout = result.data['checkoutShippingLineUpdate']['checkout'];

      return checkout;
    } catch (e) {
      printLog('::::getShippingMethods shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods(
      {CartModel cartModel,
      ShippingMethod shippingMethod,
      String token}) async {
    try {
      var list = <PaymentMethod>[];

      list.add(PaymentMethod.fromJson({
        'id': '0',
        'title': 'Checkout Free',
        'description': '',
        'enabled': true,
      }));

      list.add(PaymentMethod.fromJson({
        'id': '1',
        'title': 'Checkout Credit card',
        'description': '',
        'enabled': true,
      }));

      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Order>> getMyOrders({UserModel userModel, int page}) async {
    try {
      var token = userModel.user.cookie;
      const nRepositories = 50;
      final options = QueryOptions(
        documentNode: gql(ShopifyQuery.getOrder),
        variables: <String, dynamic>{
          'nRepositories': nRepositories,
          'customerAccessToken': token,
          'pageSize': 50
        },
      );
      final result = await client.query(options);

      if (result.hasException) {
        printLog(result.exception.toString());
      }

      var list = <Order>[];

      for (var item in result.data['customer']['orders']['edges']) {
        var order = item['node'];
        list.add(Order.fromShopify(order));
      }

      return list;
    } catch (e) {
      printLog('::::getMyOrders shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Product>> searchProducts(
      {name,
      categoryId = '',
      tag = '',
      attribute = '',
      attributeId = '',
      page,
      lang,
      cursor,
      listingLocation,
      userId}) async {
    try {
      printLog('::::request searchProducts');

      const nRepositories = 50;
      final options = QueryOptions(
        documentNode: gql(ShopifyQuery.getProductByName),
        variables: <String, dynamic>{
          'nRepositories': nRepositories,
          'query': name,
          'cursor': cursor,
          'pageSize': 50
        },
      );
      final result = await client.query(options);

      if (result.hasException) {
        printLog(result.exception.toString());
      }

      var list = <Product>[];

      for (var item in result.data['shop']['products']['edges']) {
        list.add(Product.fromShopify(item['node']));
      }

      printLog(list);

      return list;
    } catch (e) {
      printLog('::::searchProducts shopify error');
      printLog(e.toString());
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
      printLog('::::request createUser');

      const nRepositories = 50;
      final options = QueryOptions(
          documentNode: gql(ShopifyQuery.createCustomer),
          variables: <String, dynamic>{
            'nRepositories': nRepositories,
            'input': {
              'firstName': firstName,
              'lastName': lastName,
              'email': username,
              'password': password
            }
          });

      final result = await client.query(options);

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }

      printLog('createUser ${result.data}');

      var userInfo = result.data['customerCreate']['customer'];
      final token =
          await createAccessToken(username: username, password: password);
      var user = User.fromShopifyJson(userInfo, token);

      return user;
    } catch (e) {
      printLog('::::createUser shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<User> getUserInfo(accessToken) async {
    try {
      printLog('::::request getUserInfo');

      const nRepositories = 50;
      final options = QueryOptions(
          documentNode: gql(ShopifyQuery.getCustomerInfo),
          fetchPolicy: FetchPolicy.networkOnly,
          variables: <String, dynamic>{
            'nRepositories': nRepositories,
            'accessToken': accessToken
          });

      final result = await client.query(options);

      printLog('result ${result.data}');

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }

      var user = User.fromShopifyJson(result.data['customer'], accessToken);
      if (user.cookie == null) return null;
      return user;
    } catch (e) {
      printLog('::::getUserInfo shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateUserInfo(
      Map<String, dynamic> json, String token) async {
    try {
      printLog('::::request updateUser');

      const nRepositories = 50;
      final options =
          QueryOptions(documentNode: gql(ShopifyQuery.customerUpdate),
              // fetchPolicy: FetchPolicy.networkOnly,
              variables: <String, dynamic>{
            'nRepositories': nRepositories,
            'customerAccessToken': token,
            'customer': json,
          });

      final result = await client.query(options);

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }

      // When update password, full user info will get null
      final user = await getUserInfo(token);
      if (user == null) {
        json['cookie'] = token;
        return json;
      }
      return user.toJson();
    } catch (e) {
      printLog('::::updateUser shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  Future<String> createAccessToken({username, password}) async {
    try {
      printLog('::::request createAccessToken');

      const nRepositories = 50;
      final options = QueryOptions(
          documentNode: gql(ShopifyQuery.createCustomerToken),
          variables: <String, dynamic>{
            'nRepositories': nRepositories,
            'input': {'email': username, 'password': password}
          });

      final result = await client.query(options);

      printLog('result ${result.data}');

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }
      var json =
          result.data['customerAccessTokenCreate']['customerAccessToken'];
      printLog("json['accessToken'] ${json['accessToken']}");

      return json['accessToken'];
    } catch (e) {
      printLog('::::createAccessToken shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<User> login({username, password}) async {
    try {
      printLog('::::request login');

      var accessToken =
          await createAccessToken(username: username, password: password);
      var userInfo = await getUserInfo(accessToken);

      printLog('login $userInfo');

      return userInfo;
    } catch (e) {
      printLog('::::login shopify error');
      printLog(e.toString());
      throw Exception(
          'Please check your username or password and try again. If the problem persists, please contact support!');
    }
  }

  @override
  Future<Product> getProduct(id, {lang, cursor}) async {
    printLog('::::request getProduct $id');

    const nRepositories = 50;
    final options = QueryOptions(
      documentNode: gql(ShopifyQuery.getProductById),
      variables: <String, dynamic>{'nRepositories': nRepositories, 'id': id},
    );
    final result = await client.query(options);

    if (result.hasException) {
      printLog(result.exception.toString());
    }
    return Product.fromShopify(result.data['node']);
  }

  Future<Map<String, dynamic>> checkoutLinkUser(
      String checkoutId, String token) async {
    final options = MutationOptions(
      documentNode: gql(ShopifyQuery.checkoutLinkUser),
      variables: {
        'checkoutId': checkoutId,
        'customerAccessToken': token,
      },
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      printLog(result.exception.toString());
      throw Exception(result.exception.toString());
    }

    var checkout = result.data['checkoutCustomerAssociateV2']['checkout'];

    return checkout;
  }

  Future addItemsToCart(CartModel cartModel, UserModel userModel) async {
    try {
      if (cookie != null) {
        var lineItems = [];

        printLog('addItemsToCart productsInCart ${cartModel.productsInCart}');
        printLog(
            'addItemsToCart productVariationInCart ${cartModel.productVariationInCart}');

        cartModel.productVariationInCart.keys.forEach((productId) {
          var variant = cartModel.productVariationInCart[productId];
          var productCart = cartModel.productsInCart[productId];

          printLog('addItemsToCart $variant');

          lineItems.add({'variantId': variant.id, 'quantity': productCart});
        });

        printLog('addItemsToCart lineItems $lineItems');

        final options = MutationOptions(
          documentNode: gql(ShopifyQuery.createCheckout),
          variables: {
            'input': {'lineItems': lineItems},
            if (userModel.user != null) ...{
              'email': userModel.user.email,
            }
          },
        );

        final result = await client.mutate(options);

        if (result.hasException) {
          printLog(result.exception.toString());
          throw Exception(result.exception.toString());
        }

        final checkout = result.data['checkoutCreate']['checkout'];

        printLog('addItemsToCart checkout $checkout');

        // start link checkout with user
        final cookie = userModel?.user?.cookie;
        if (cookie != null) {
          var newCheckout = await checkoutLinkUser(checkout['id'], cookie);

          return CheckoutCart.fromJsonShopify(newCheckout);
        }
        return CheckoutCart.fromJsonShopify(checkout);
      } else {
        throw Exception('You need to login to checkout');
      }
    } catch (e) {
      printLog('::::addItemsToCart shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  Future updateItemsToCart(CartModel cartModel) async {
    try {
      if (cookie != null) {
        var lineItems = [];
        var checkoutId = cartModel.checkout.id;

        printLog(
            'updateItemsToCart productsInCart ${cartModel.productsInCart}');
        printLog(
            'updateItemsToCart productVariationInCart ${cartModel.productVariationInCart}');

        cartModel.productVariationInCart.keys.forEach((productId) {
          var variant = cartModel.productVariationInCart[productId];
          var productCart = cartModel.productsInCart[productId];

          printLog('updateItemsToCart $variant');

          lineItems.add({'variantId': variant.id, 'quantity': productCart});
        });

        printLog('updateItemsToCart lineItems $lineItems');

        final options = MutationOptions(
          documentNode: gql(ShopifyQuery.updateCheckout),
          variables: <String, dynamic>{
            'lineItems': lineItems,
            'checkoutId': checkoutId
          },
        );

        final result = await client.mutate(options);

        if (result.hasException) {
          printLog(result.exception.toString());
          throw Exception(result.exception.toString());
        }

        var checkout = result.data['checkoutLineItemsReplace']['checkout'];

        return CheckoutCart.fromJsonShopify(checkout);
      } else {
        throw Exception('You need to login to checkout');
      }
    } catch (err) {
      printLog('::::updateItemsToCart shopify error');
      printLog(err.toString());
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

  Future applyCoupon(CartModel cartModel, String discountCode) async {
    try {
      var lineItems = [];

      printLog('applyCoupon ${cartModel.productsInCart}');

      printLog('applyCoupon $lineItems');

      final options = MutationOptions(
        documentNode: gql(ShopifyQuery.applyCoupon),
        variables: {
          'discountCode': discountCode,
          'checkoutId': cartModel.checkout.id
        },
      );

      final result = await client.mutate(options);

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }

      var checkout = result.data['checkoutDiscountCodeApplyV2']['checkout'];

      return CheckoutCart.fromJsonShopify(checkout);
    } catch (e) {
      printLog('::::applyCoupon shopify error');
      printLog(e.toString());
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

  // payment settings from shop
  @override
  Future<PaymentSettings> getPaymentSettings() async {
    try {
      printLog('::::request paymentSettings');

      const nRepositories = 50;
      final options = QueryOptions(
          documentNode: gql(ShopifyQuery.getPaymentSettings),
          variables: <String, dynamic>{
            'nRepositories': nRepositories,
          });

      final result = await client.query(options);

      printLog('result ${result.data}');

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }
      var json = result.data['shop']['paymentSettings'];

      printLog('paymentSettings $json');

      return PaymentSettings.fromShopifyJson(json);
    } catch (e) {
      printLog('::::paymentSettings shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<PaymentSettings> addCreditCard(
      PaymentSettingsModel paymentSettingsModel,
      CreditCardModel creditCardModel) async {
    try {
      var response = await http.post(paymentSettingsModel.getCardVaultUrl(),
          body: convert.jsonEncode(creditCardModel),
          headers: {'content-type': 'application/json'});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return PaymentSettings.fromVaultIdShopifyJson(body['data']);
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
  Future checkoutWithCreditCard(String vaultId, CartModel cartModel,
      Address address, PaymentSettingsModel paymentSettingsModel) async {
    try {
      try {
        var uuid = Uuid();
        var paymentAmount = {
          'amount': cartModel.getTotal(),
          'currencyCode': cartModel.getCurrency()
        };

        final options = MutationOptions(
          documentNode: gql(ShopifyQuery.checkoutWithCreditCard),
          variables: {
            'checkoutId': cartModel.checkout.id,
            'payment': {
              'paymentAmount': paymentAmount,
              'idempotencyKey': uuid.v1(),
              'billingAddress': address.toShopifyJson()['address'],
              'vaultId': vaultId,
              'test': true
            }
          },
        );

        final result = await client.mutate(options);

        if (result.hasException) {
          printLog(result.exception.toString());
          throw Exception(result.exception.toString());
        }

        var checkout =
            result.data['checkoutCompleteWithCreditCardV2']['checkout'];

        return CheckoutCart.fromJsonShopify(checkout);
      } catch (e) {
        printLog('::::applyCoupon shopify error');
        printLog(e.toString());
        rethrow;
      }
    } catch (e) {
      printLog('::::checkoutWithCreditCard shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<ProductVariation>> getProductVariations(Product product,
      {String lang = 'en'}) async {
    try {
      return product.variations;
    } catch (e) {
      printLog('::::getProductVariations shopify error');
      rethrow;
    }
  }
}
