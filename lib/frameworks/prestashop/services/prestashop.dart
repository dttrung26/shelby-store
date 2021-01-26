import 'dart:async';

import '../../../common/constants.dart';
import '../../../models/index.dart';
import '../../../services/base_services.dart';
import '../../../services/wordpress/blognews_api.dart';
import 'prestashop_api.dart';

class Prestashop extends BaseServices {
  static final Prestashop _instance = Prestashop._internal();

  factory Prestashop() => _instance;

  Prestashop._internal();

  String url;
  String key;
  PrestashopAPI prestaApi;
  List<Category> cats;
  List<Map<String, dynamic>> product_options;
  List<Map<String, dynamic>> product_option_values;
  List<Map<String, dynamic>> order_states;
  Map<String, dynamic> orderAddresses;
  String id_lang;
  String language_code;

  @override
  BlogNewsApi blogApi;

  void appConfig(appConfig) {
    blogApi = BlogNewsApi(appConfig['blog'] ?? appConfig['url']);
    prestaApi = PrestashopAPI(appConfig['url'], appConfig['key']);
    url = appConfig['url'];
    key = appConfig['key'];
    product_options = null;
    product_option_values = null;
    order_states = null;
    cats = null;
    orderAddresses = <String, dynamic>{};
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

  List<dynamic> downLevelsCategories(dynamic cats) {
    int parent;
    var _categories = <dynamic>[];
    for (var item in cats) {
      if (parent == null || int.parse(item['id_parent'].toString()) < parent) {
        parent = int.parse(item['id_parent'].toString());
      }
    }
    for (var item in cats) {
      if (int.parse(item['id_parent'].toString()) == parent) continue;
      _categories.add(item);
    }
    return _categories;
  }

  List<dynamic> setParentCategories(dynamic cats) {
    int parent;
    var _categories = <dynamic>[];
    for (var item in cats) {
      if (parent == null || int.parse(item['id_parent'].toString()) < parent) {
        parent = int.parse(item['id_parent'].toString());
      }
    }
    for (var item in cats) {
      if (int.parse(item['id_parent'].toString()) == parent) {
        item['id_parent'] = '0';
      }
      _categories.add(item);
    }
    return _categories;
  }

  @override
  Future<List<Category>> getCategories({lang}) async {
    try {
      if (language_code != lang) await getLanguage(lang: lang);
      if (cats != null) return cats;
      var categoriesId;
      var categories = <Category>[];
      categoriesId =
          await prestaApi.getAsync('categories?filter[active]=1&display=full');
      var _categories = categoriesId['categories'];
      _categories = downLevelsCategories(_categories);
      _categories = downLevelsCategories(_categories);
      _categories = setParentCategories(_categories);
      for (var item in _categories) {
        item['name'] = getValueByLang(item['name']);
        //printLog(item);
        categories.add(Category.fromJsonPresta(item, prestaApi.apiLink));
      }
      cats ??= categories;
      return categories;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Product>> getProducts({userId}) async {
    try {
      var productsId;
      var products = <Product>[];
      productsId = await prestaApi.getAsync('products');
      for (var item in productsId['products']) {
        var category = await prestaApi.getAsync('products/${item["id"]}');
        if (category['product']['name'].isEmpty) continue;
        products
            .add(Product.fromPresta(category['product'], prestaApi.apiLink));
      }
      return products;
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<Product>> fetchProductsLayout({config, lang, userId}) async {
    try {
      var products = <Product>[];
      if (language_code != lang) await getLanguage(lang: lang);
      if (cats == null) await getCategories();
      if (product_options == null) {
        await getProductOptions();
      }
      if (product_option_values == null) {
        await getProductOptionValues();
      }
      var filter = '';
      if (config.containsKey('category')) {
        var childs = getChildCategories([config['category'].toString()]);
        filter = '&id_category=${childs.toString()}';
        filter = filter.replaceAll('[', '');
        filter = filter.replaceAll(']', '');
      }
      var page = config.containsKey('page') ? config['page'] : 1;
      var display = 'full';
      var limit = '${(page - 1) * ApiPageSize},$ApiPageSize';
      var response = await prestaApi
          .getAsync('product?display=$display&limit=$limit$filter&lang=$lang');
      if (response is Map) {
        for (var item in response['products']) {
          var _product_option_values =
              item['associations']['product_option_values'];
          if (_product_option_values != null) {
            var attribute = <String, dynamic>{};
            for (var option in _product_option_values) {
              var opt = product_option_values.firstWhere(
                  (e) => e['id'].toString() == option['id'].toString(),
                  orElse: () => null);
              if (opt != null) {
                var name = product_options.firstWhere(
                    (e) =>
                        e['id'].toString() ==
                        opt['id_attribute_group'].toString(),
                    orElse: () => null);
                var val = attribute[getValueByLang(name['name'])] ?? [];
                val.add(getValueByLang(opt['name']));
                attribute.update(getValueByLang(name['name']), (value) => val,
                    ifAbsent: () => val);
              }
            }
            item['attributes'] = attribute;
          }
          products.add(Product.fromPresta(item, prestaApi.apiLink));
        }
      } else {
        return [];
      }
      return products;
    } catch (e, trace) {
      printLog(trace.toString());
      printLog(e.toString());
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      return [];
    }
  }

  //get all attribute_term for selected attribute for filter menu
  @override
  Future<List<SubAttribute>> getSubAttributes({int id}) async {
    try {
      var list = <SubAttribute>[];
      if (product_option_values == null) await getProductOptions();
      for (var item in product_option_values) {
        if (item['id_attribute_group'].toString() == id.toString()) {
          list.add(SubAttribute.fromJson(item));
        }
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  //get all attributes for filter menu
  @override
  Future<List<FilterAttribute>> getFilterAttributes() async {
    var list = <FilterAttribute>[];
    if (product_options == null) await getProductOptions();

    for (var item in product_options) {
      list.add(FilterAttribute.fromJson(
          {'id': item['id'], 'name': item['name'], 'slug': item['name']}));
    }
    return list;
  }

  List<String> getChildCategories(List<String> _categories) {
    var categories = _categories != null ? [..._categories] : [];
    if (cats.firstWhere((e) {
          for (var item in categories) {
            var exist =
                categories.firstWhere((i) => i == e.id, orElse: () => null);
            if (item == e.parent && exist == null) return true;
          }
          return false;
        }, orElse: () => null) ==
        null) return _categories;
    for (var item in _categories) {
      var _cats = cats.where((e) => e.parent == item);
      if (_cats.isNotEmpty) {
        for (var cat in _cats) {
          var exist =
              _categories.firstWhere((i) => i == cat.id, orElse: () => null);
          if (exist == null) categories.add(cat.id);
        }
      }
    }
    return getChildCategories(categories);
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
      attribute,
      attributeTerm,
      featured,
      onSale,
      listingLocation,
      userId}) async {
    try {
      var products = <Product>[];
      if (language_code != lang) await getLanguage(lang: lang);
      if (cats == null) await getCategories();
      if (product_options == null) {
        await getProductOptions();
      }
      if (product_option_values == null) {
        await getProductOptionValues();
      }
      var childs = getChildCategories([categoryId]);
      var filter = '';
      filter = '&id_category=${childs.toString()}';
      filter = filter.replaceAll('[', '');
      filter = filter.replaceAll(']', '');
      if (attributeTerm != null && attributeTerm.isNotEmpty) {
        var attributeId =
            attributeTerm.substring(0, attributeTerm.indexOf(','));
        filter += '&attribute=$attributeId';
      }

      if (onSale ?? false) {
        filter += '&sale=1';
      }
      if (orderBy != null && orderBy == 'date' && !(featured ?? false)) {
        filter += '&date=${order.toUpperCase()}';
      }
      var display = 'full';
      var limit = '${(page - 1) * ApiPageSize},$ApiPageSize';
      var response = await prestaApi
          .getAsync('product?display=$display&limit=$limit$filter&lang=$lang');
      if (response is Map) {
        for (var item in response['products']) {
          var _product_option_values =
              item['associations']['product_option_values'];
          if (_product_option_values != null) {
            var attribute = <String, dynamic>{};
            for (var option in _product_option_values) {
              var opt = product_option_values.firstWhere(
                  (e) => e['id'].toString() == option['id'].toString(),
                  orElse: () => null);
              if (opt != null) {
                var name = product_options.firstWhere(
                    (e) =>
                        e['id'].toString() ==
                        opt['id_attribute_group'].toString(),
                    orElse: () => null);
                var val = attribute[getValueByLang(name['name'])] ?? [];
                val.add(getValueByLang(opt['name']));
                attribute.update(getValueByLang(name['name']), (value) => val,
                    ifAbsent: () => val);
              }
            }
            item['attributes'] = attribute;
          }
          products.add(Product.fromPresta(item, prestaApi.apiLink));
        }
      } else {
        return [];
      }
      return products;
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<Null> createReview(
      {String productId, Map<String, dynamic> data, String token}) async {
    try {} catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  Future<void> getProductOptions() async {
    try {
      product_options = List<Map<String, dynamic>>.from((await prestaApi
              .getAsync('product_options?display=[id,name,group_type]'))[
          'product_options']);
    } catch (e) {
      product_options = [];
    }
    return;
  }

  Future<void> getProductOptionValues() async {
    try {
      product_option_values = List<
          Map<String, dynamic>>.from((await prestaApi.getAsync(
              'product_option_values?display=[id,id_attribute_group,color,name]'))[
          'product_option_values']);
    } catch (e) {
      product_option_values = [];
    }
    return;
  }

  String getValueByLang(dynamic values) {
    if (!(values is List)) return values;
    for (var item in values) {
      if (item['id'].toString() == (id_lang ?? '1')) {
        return item['value'];
      }
    }
    return 'Error';
  }

  Future<void> getLanguage({lang = 'en'}) async {
    language_code = lang;
    var res = await prestaApi.getAsync('languages?display=full');
    for (var item in res['languages']) {
      if (item['iso_code'] == lang.toString()) {
        id_lang = item['id'].toString();
        return;
      }
    }
    id_lang = res['languages'].length > 0
        ? res['languages'][0]['id'].toString()
        : '1';
  }

  @override
  Future<List<ProductVariation>> getProductVariations(Product product,
      {String lang = 'en'}) async {
    try {
      var productVariantions = <ProductVariation>[];
      // var _product = await prestaApi.getAsync('products/${product.id}');
      // List<dynamic> combinations =
      //     _product['product']['associations']['combinations'];
      if (language_code != lang) await getLanguage(lang: lang);
      if (product_options == null) await getProductOptions();
      if (product_option_values == null) await getProductOptionValues();
      var params = 'id_product=${product.id}&display=full';
      if (product.idShop != null && product.idShop.isNotEmpty) {
        params += '&id_shop_default=${product.idShop}';
      }
      var combinationRes = await prestaApi.getAsync('attribute?$params');

      for (var i = 0; i < combinationRes['combinations'].length; i++) {
        var combination = combinationRes['combinations'][i];
        var options = combination['associations']['product_option_values'];
        var attributes = <Map<String, dynamic>>[];
        for (var option in options) {
          var option_value = product_option_values.firstWhere(
              (element) => element['id'].toString() == option['id'].toString(),
              orElse: () => null);
          if (option_value != null) {
            var name = product_options.firstWhere(
                (e) =>
                    e['id'].toString() ==
                    option_value['id_attribute_group'].toString(),
                orElse: () => null);
            attributes.add({
              'id': option_value['id'],
              'name': getValueByLang(name['name']),
              'option': getValueByLang(option_value['name'])
            });
          }
        }
        combination['attributes'] = attributes;

        combination['image'] = product.imageFeature;
        productVariantions.add(ProductVariation.fromPrestaJson(combination));
      }
      return productVariantions;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ShippingMethod>> getShippingMethods(
      {CartModel cartModel, String token, String checkoutId}) async {
    var address = cartModel.address;
    var lists = <ShippingMethod>[];
    var countries = await prestaApi
        .getAsync('countries?filter[iso_code]=${address.country}&display=full');
    var zone = '1';
    if (countries is Map) {
      zone = countries['countries'][0]['id_zone'] ?? 1;
    }
    var shipping = await prestaApi.getAsync(
        'shipping?$checkoutId&zone=$zone&display=full&id_lang=$id_lang');
    for (var item in shipping['carriers']) {
      lists.add(ShippingMethod.fromPrestaJson(item));
    }
    return lists;
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods(
      {CartModel cartModel,
      ShippingMethod shippingMethod,
      String token}) async {
    var lists = <PaymentMethod>[];
    var payment = await prestaApi.getAsync('payment?display=full');
    for (var item in payment['taxes']) {
      lists.add(PaymentMethod.fromPrestaJson(item));
    }
    return lists;
  }

  Future<void> getOrderStates() async {
    order_states = List<Map<String, dynamic>>.from((await prestaApi
        .getAsync('order_states?display=full'))['order_states']);
    return;
  }

  Future<void> getMyOrderAddress(String id) async {
    if (orderAddresses.containsKey(id)) return;
    var response =
        await prestaApi.getAsync('addresses?filter[id]=$id&display=full');
    if (response is Map && response['addresses'].isNotEmpty) {
      orderAddresses.update(id, (value) => response['addresses'][0],
          ifAbsent: () => response['addresses'][0]);
    } else {
      orderAddresses.update(id, (value) => {'firstname': 'Not found'},
          ifAbsent: () => {'firstname': 'Not found'});
    }
    return;
  }

  @override
  Future<List<Order>> getMyOrders({UserModel userModel, int page}) async {
    var lists = <Order>[];
    if (order_states == null) await getOrderStates();
    var response = await prestaApi.getAsync(
        'orders?filter[id_customer]=${userModel.user.id}&display=full');
    for (var item in response['orders']) {
      var order = item;
      var status = order_states.firstWhere(
          (e) => e['id'].toString() == item['current_state'].toString(),
          orElse: () => null);
      if (status != null) {
        order['status'] = getValueByLang(status['name']);
      }
      await getMyOrderAddress(item['id_address_delivery'].toString());
      var address = orderAddresses[item['id_address_delivery'].toString()];
      order['address'] = address;
      lists.add(Order.fromPrestashop(item));
    }
    return lists;
  }

  @override
  Future<Order> createOrder(
      {CartModel cartModel,
      UserModel user,
      bool paid,
      String transactionId}) async {
    var id_carrier = cartModel.shippingMethod.id;
    var id_customer = user.user.id;
    var id_currency = '1';
    var address = await createAddress(cartModel, user);
    var id_address_delivery = address;
    var id_address_invoice = address;
    var current_state = '1';
    var payment = cartModel.paymentMethod.title;
    var module = cartModel.paymentMethod.id;
    var total_shipping = cartModel.shippingMethod.cost.toString();
    var total_products = cartModel.getSubTotal().toString();
    final products = cartModel.item;
    final productVariationInCart =
        cartModel.productVariationInCart.keys.toList();
    var productsId = <String>[];
    var attribute = <String>[];
    var productsQuantity = [];
    if (order_states == null) await getOrderStates();
    for (var key in products.keys.toList()) {
      if (productVariationInCart.toString().contains('$key-')) {
        for (var item in productVariationInCart) {
          if (item.contains('$key-')) {
            productsId.add(key);
            attribute.add(item.replaceAll('$key-', ''));
            productsQuantity.add(cartModel.productsInCart[item]);
          }
        }
      } else {
        productsId.add(key);
        attribute.add('-1');
        productsQuantity.add(cartModel.productsInCart[key]);
      }
    }
    var params =
        'products=${productsId.toString()}&quantity=${productsQuantity.toString()}&attribute=${attribute.toString()}';
    params +=
        '&id_carrier=$id_carrier&id_lang=$id_lang&id_customer=$id_customer';
    params +=
        '&id_currency=$id_currency&id_address_delivery=$id_address_delivery';
    params +=
        '&id_address_invoice=$id_address_invoice&current_state=$current_state';
    params +=
        '&payment=$payment&module=$module&total_shipping=$total_shipping&total_products=$total_products&display=full';
    if ((cartModel.notes ?? '').isNotEmpty) {
      params += '&notes=${cartModel.notes}';
    }
    var response = await prestaApi.getAsync('order?$params');
    return Order.fromPrestashop(response['orders'][0]);
  }

  @override
  Future updateOrder(orderId, {status, token}) async {}

  @override
  Future<List<Product>> searchProducts({
    name,
    categoryId = '',
    tag = '',
    attribute = '',
    attributeId = '',
    page,
    lang,
    listingLocation,
    userId,
  }) async {
    var products = <Product>[];
    if (cats == null) await getCategories();
    if (language_code != lang) await getLanguage(lang: lang);
    if (product_options == null) {
      await getProductOptions();
    }
    if (product_option_values == null) {
      await getProductOptionValues();
    }
    var filter = '&name=$name';
    if (categoryId != null && categoryId.isNotEmpty) {
      var childs = getChildCategories([categoryId]);
      var id_category = '&id_category=${childs.toString()}';
      id_category = id_category.replaceAll('[', '');
      id_category = id_category.replaceAll(']', '');
      filter = filter + id_category;
    }
    if (attributeId != null && attributeId.isNotEmpty) {
      filter += '&attribute=$attributeId';
    }
    var display = 'full';
    var limit = '${(page - 1) * ApiPageSize},$ApiPageSize';
    var response = await prestaApi
        .getAsync('product?display=$display&limit=$limit$filter&lang=$lang');
    if (response is Map) {
      for (var item in response['products']) {
        var _product_option_values =
            item['associations']['product_option_values'];
        if (_product_option_values != null) {
          var attribute = <String, dynamic>{};
          for (var option in _product_option_values) {
            var opt = product_option_values.firstWhere(
                (e) => e['id'].toString() == option['id'].toString(),
                orElse: () => null);
            if (opt != null) {
              var name = product_options.firstWhere(
                  (e) =>
                      e['id'].toString() ==
                      opt['id_attribute_group'].toString(),
                  orElse: () => null);
              var val = attribute[getValueByLang(name['name'])] ?? [];
              val.add(getValueByLang(opt['name']));
              attribute.update(getValueByLang(name['name']), (value) => val,
                  ifAbsent: () => val);
            }
          }
          item['attributes'] = attribute;
        }
        products.add(Product.fromPresta(item, prestaApi.apiLink));
      }
    } else {
      return [];
    }
    return products;
  }

  @override
  Future<Product> getProduct(id, {lang}) async {
    printLog('::::request getProduct $id');
    var response = await prestaApi
        .getAsync('product?display=full&limit=5&id_product=$id&lang=$lang');

    return Product.fromPresta(response['products'][0], prestaApi.apiLink);
  }

  /// Auth
  @override
  Future<User> getUserInfo(cookie) async {
    return null;
  }

  @override
  Future<Map<String, dynamic>> updateUserInfo(
      Map<String, dynamic> json, String token) async {
    return null;
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
      var response = await prestaApi.getAsync(
          'register?email=$username&passwd=$password&firstname=$firstName&lastname=$lastName&display=full');
      var user;
      if (response is Map) {
        user = User.fromPrestaJson(response['customers'][0]);
      } else {
        throw ('Email is exist!!!');
      }
      return user;
    } catch (e) {
      printLog(e.toString());
      rethrow;
    }
  }

  /// login
  @override
  Future<User> login({username, password}) async {
    try {
      var response = await prestaApi
          .getAsync('signin?email=$username&passwd=$password&display=full');
      if (response is Map && response['customers'].length == 1) {
        return User.fromPrestaJson(response['customers'][0]);
      } else {
        throw Exception('No match for E-Mail Address and/or Password');
      }
    } catch (err) {
      rethrow;
    }
  }

  //Get list countries
  @override
  Future<dynamic> getCountries() async {
    try {
      var response =
          await prestaApi.getAsync('countries?filter[active]=1&display=full');
      var countries = response['countries'];
      if (countries != null && countries is List) {
        for (var item in countries) {
          item['name'] = getValueByLang(item['name']);
        }
      }
      return countries;
    } catch (err) {
      return [];
    }
  }

  @override
  Future getStatesByCountryId(countryId) async {
    try {
      var response = await prestaApi.getAsync(
          'states?filter[id_country]=$countryId&filter[active]=1&display=full');
      var states = response['states'];
      if (states != null && states is List) {
        for (var item in states) {
          item['name'] = getValueByLang(item['name']);
        }
      }
      return states;
    } catch (err) {
      return [];
    }
  }

  //Get list states
  Future<dynamic> getStates(String id_country) async {
    try {
      var response = await prestaApi.getAsync(
          'states?filter[id_country]=$id_country&filter[active]=1&display=full');
      var states = response['states'];
      if (states != null && states is List) {
        for (var item in states) {
          item['name'] = getValueByLang(item['name']);
        }
      }
      return states;
    } catch (err) {
      return [];
    }
  }

  //Create user address in order
  Future<String> createAddress(CartModel cartModel, UserModel user) async {
    try {
      var param = '';
      param += 'id_customer=${user.user.id}';
      param += '&country_iso=${cartModel.address.country}';
      param += '&id_state=${cartModel.address.state}';
      param += '&firstname=${cartModel.address.firstName}';
      param += '&lastname=${cartModel.address.lastName}';
      param += '&email=${cartModel.address.email}';
      param += '&address=${cartModel.address.street}';
      param += '&city=${cartModel.address.city}';
      param += '&postcode=${cartModel.address.zipCode}';
      param += '&phone=${cartModel.address.phoneNumber}';
      param += '&display=full';
      var response = await prestaApi.getAsync('address?$param');
      return response['addresses'][0]['id'].toString();
    } catch (err) {
      return '1';
    }
  }

  //Get order status
  Future<List<Map<String, dynamic>>> getOrderStatus(String order_id) async {
    var response = await prestaApi
        .getAsync('order_histories?filter[id_order]=$order_id&display=full');
    var order_histories = <Map<String, dynamic>>[];
    for (var item in response['order_histories']) {
      var history = Map<String, dynamic>.from(item);
      var status = order_states.firstWhere(
          (e) => e['id'].toString() == history['id_order_state'].toString(),
          orElse: () => null);
      if (status != null) {
        history['status'] = getValueByLang(status['name']);
      }
      order_histories.add(history);
    }
    order_histories.sort((a, b) =>
        DateTime.parse(a['date_add']).compareTo(DateTime.parse(b['date_add'])));
    return order_histories;
  }

  @override
  Future<Coupons> getCoupons() async {
    try {
      var response =
          await prestaApi.getAsync('cart_rules?filter[active]=1&display=full');
      if (response is Map) {
        return Coupons.getListCouponsPresta(response['cart_rules']);
      }
      return Coupons.getListCouponsPresta([]);
    } catch (e) {
      rethrow;
    }
  }
}
