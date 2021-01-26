import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quiver/strings.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../models/entities/listing_location.dart';
import '../../../models/entities/prediction.dart';
import '../../../models/index.dart';
import '../../../services/base_services.dart';
import '../../../services/service_config.dart';
import '../../../services/wordpress/blognews_api.dart';
import '../mapping/mapping.dart';
import 'listing_api.dart';

class ListingService extends BaseServices {
  static final ListingService _instance = ListingService._internal();

  factory ListingService() => _instance;

  ListingService._internal();

  String url;

  ListingAPI listingAPI;

  List<Category> cats;
  List<Map<String, dynamic>> product_options;
  List<Map<String, dynamic>> product_option_values;
  String id_lang;
  String language_code;

  @override
  BlogNewsApi blogApi;

  void appConfig(appConfig) {
    blogApi = BlogNewsApi(appConfig['blog'] ?? appConfig['url']);
    listingAPI = ListingAPI(appConfig['url'], appConfig['consumerKey'],
        appConfig['consumerSecret']);
    url = appConfig['url'];
    Mapping.init(appConfig['type']);
  }

  @override
  Future<List<Order>> getMyOrders({UserModel userModel, int page}) async {
    try {
      var response = await listingAPI.getAsync(
          'orders?customer=${userModel.user.id}&per_page=20&page=$page');
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
          '$url/wp-json/api/flutter_user/register/?insecure=cool&',
          body: convert.jsonEncode({
            'user_email': username,
            'user_login': username,
            'username': username,
            'user_pass': password,
            'email': username,
            'user_nicename': niceName,
            'display_name': niceName,
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
    var list = <Product>[];
    var endPoint =
        '$url/wp-json/wp/v2/${DataMapping().kProductPath}?_embed=true&per_page=$ApiPageSize&page=$page';
    if (listingLocation != null) {
      endPoint += '&location=$listingLocation';
    }
    if (categoryId != null && int.parse(categoryId) > -1) {
      endPoint += '&${DataMapping().kCategoryPath}=$categoryId';
    }
    if (orderBy != null) {
      endPoint += '&orderby=$orderBy';
    }
    if (order != null) {
      endPoint += '&order=$order';
    }
    printLog(endPoint);
    var response = await http.get(endPoint);

    if (response.statusCode == 200) {
      for (var item in convert.jsonDecode(response.body)) {
        try {
          var product = Product.fromListingJson(item);
          list.add(product);
        } catch (e) {
          continue;
        }
      }
    }
    return list;
  }

  @override
  Future<List<Product>> fetchProductsLayout({config, lang, userId}) async {
    try {
      var list = <Product>[];

      printLog('fetchProductsLayoutStart');

      var endPoint =
          '$url/wp-json/wp/v2/${DataMapping().kProductPath}?page=${config['page']}&per_page=${config['limit']}';
      if (config.containsKey('category')) {
        endPoint += '&${DataMapping().kCategoryPath}=${config["category"]}';
      }

      var response = await http.get(endPoint);

      printLog('fetchProductsLayoutStop');
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)) {
          var product = Product.fromListingJson(item);
          list.add(product);
        }
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Category>> getCategories({lang}) async {
    try {
      var endpoint =
          '$url/wp-json/wp/v2/${DataMapping().kCategoryPath}?hide_empty=true&_embed&per_page=100';
      var response = await http.get(endpoint);
      final body = convert.jsonDecode(response.body);
      if (body is Map && body['message'] != null) {
        throw Exception(body['message']);
      } else {
        var list = <Category>[];
        for (var item in body) {
          list.add(Category.fromListingJson(item));
        }
        return list;
      }
    } catch (e) {
      printLog('getCategories: $e');
      rethrow;
    }
  }

  @override
  Future<BlogNews> getPageById(int pageId) {
    throw UnimplementedError();
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods(
      {CartModel cartModel,
      ShippingMethod shippingMethod,
      String token}) async {
    try {
      var endpoint = '$url/wp-json/wp/v2/payment';

      if (token != null) {
        endpoint += '?cookie=$token';
      }
      var list = <PaymentMethod>[];
      final response = await http.get(
        endpoint,
      );
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        for (var item in body) {
          list.add(PaymentMethod.fromJson(item));
        }
      }
      if (list.isEmpty) {
        throw Exception('No payment methods');
      }
      return list;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future updateOrder(orderId, {status, token}) async {
    try {
      var response = await listingAPI
          .postAsync('orders/$orderId', {'status': status}, version: 2);
      if (response['message'] != null) {
        throw Exception(response['message']);
      } else {
        return Order.fromJson(response);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<Product>> getProducts({userId}) {
    throw UnimplementedError();
  }

  @override
  Future<List<ShippingMethod>> getShippingMethods(
      {CartModel cartModel, String token, String checkoutId}) {
    throw UnimplementedError();
  }

  @override
  Future<User> login({username, password}) async {
    var cookieLifeTime = 120960000000;
    try {
      final response = await http.post(
          '$url/wp-json/api/flutter_user/generate_auth_cookie',
          body: convert.jsonEncode({
            'seconds': cookieLifeTime.toString(),
            'username': username,
            'password': password
          }));

      final body = convert.jsonDecode(response.body);

      if (response.statusCode == 200 && body['cookie'] != null) {
        return await getUserInfo(body['cookie']);
      } else {
        throw Exception('The username or password is incorrect.');
      }
    } catch (err) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      printLog(err);
      rethrow;
    }
  }

  @override
  Future<User> loginFacebook({String token}) async {
    const cookieLifeTime = 120960000000;

    try {
      var endPoint =
          '$url/wp-json/api/flutter_user/fb_connect/?second=$cookieLifeTime'
          '&access_token=$token';

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['id'] == null || jsonDecode['cookie'] == null) {
        throw Exception(jsonDecode['message']);
      }

      return User.fromListingJson(jsonDecode);
    } catch (e) {
      printLog(e);
      rethrow;
    }
  }

  @override
  Future<User> loginSMS({String token}) async {
    try {
      var endPoint =
          '$url/wp-json/api/flutter_user/firebase_sms_login?phone=$token';

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['id'] == null || jsonDecode['cookie'] == null) {
        throw Exception(jsonDecode['message']);
      }

      return User.fromListingJson(jsonDecode);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<User> loginApple({String email, String fullName}) async {
    try {
      var endPoint =
          "$url/wp-json/api/flutter_user/apple_login?email=$email&display_name=$fullName&user_name=${email.split("@")[0]}";

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['id'] == null || jsonDecode['cookie'] == null) {
        throw Exception(jsonDecode['message']);
      }

      return User.fromListingJson(jsonDecode);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<User> getUserInfo(cookie) async {
    try {
      final response = await http.get(
          '$url/wp-json/api/flutter_user/get_currentuserinfo?cookie=$cookie');
      final body = convert.jsonDecode(response.body);
      if (body['message'] == null) {
        return User.fromListingJson(body);
      } else {
        throw Exception(body['message']);
      }
    } catch (err) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<User> loginGoogle({String token}) async {
    const cookieLifeTime = 120960000000;

    try {
      var endPoint =
          '$url/wp-json/api/flutter_user/google_login/?second=$cookieLifeTime'
          '&access_token=$token';
      var response = await http.get(endPoint);
      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['id'] == null || jsonDecode['cookie'] == null) {
        throw Exception(jsonDecode['message']);
      }

      return User.fromListingJson(jsonDecode);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      printLog(e);
      rethrow;
    }
  }

  @override
  Future<List<Review>> getReviews(productId) async {
    try {
      var list = <Review>[];

      ///get reviews for my listing/listeo
      if (DataMapping().kListingReviewMapping['review'] == 'getReviews') {
        final response = await http.get(
            '$url/wp-json/wp/v2/${DataMapping().kListingReviewMapping['review']}/$productId?per_page=100');
        if (response.statusCode == 200) {
          for (Map<String, dynamic> item in convert.jsonDecode(response.body)) {
            try {
              var review = Review.fromListing(item);
              if (review.status == 'approved') {
                list.add(review);
              }
            } catch (e) {
              printLog('Error converting review Listing $e');
            }
          }
        }
        return list;
      }

      ///get reviews for listingpro
      final response = await http.get(
          '$url/wp-json/wp/v2/${DataMapping().kListingReviewMapping['review']}?per_page=100');
      if (response.statusCode == 200) {
        for (Map<String, dynamic> item in convert.jsonDecode(response.body)) {
          try {
            var listingId = Tools.getValueByKey(
                item, DataMapping().kListingReviewMapping['item']);
            if (listingId.toString() == (productId.toString())) {
              list.add(Review.fromListing(item));
            }
          } catch (e) {
            printLog('Error converting review Listing $e');
          }
        }
      }
      return list;
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
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
      var list = <Product>[];

      var endPoint =
          '$url/wp-json/wp/v2/${DataMapping().kProductPath}?search=$name&page=$page&per_page=$ApiPageSize';
      if (categoryId != null && categoryId.isNotEmpty) {
        endPoint += '&${DataMapping().kCategoryPath}=$categoryId';
      }

      if (listingLocation != null && listingLocation.isNotEmpty) {
        var locationTag = '';
        switch (Config().typeName) {
          case 'listeo':
            locationTag = 'region';
            break;
          case 'listpro':
            locationTag = 'location';
            break;
          case 'mylisting':
            return [];
        }
        endPoint += '&$locationTag=$listingLocation';
      }

      var response = await http.get(endPoint);

      for (var item in convert.jsonDecode(response.body)) {
        try {
          var product = Product.fromListingJson(item);
          list.add(product);
        } catch (e) {
          continue;
        }
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Null> createReview(
      {String productId, Map<String, dynamic> data, String token}) async {
    try {
      if (serverConfig['type'] == 'listpro') {
        await http.post('$url/wp-json/wp/v2/submitReview', body: {
          'listing_id': productId.toString(),
          'post_content': data['post_content'],
          'post_author': data['post_author'].toString(),
          'post_title': data['post_title'],
          'rating': data['rating'].toString(),
        });
      }
      if (serverConfig['type'] == 'listeo') {
        var request = http.MultipartRequest(
            'POST', Uri.parse('$url/wp-comments-post.php'));
        request.fields['comment_post_ID'] = productId.toString();
        request.fields['comment'] = data['post_content'];
        request.fields['submit'] = 'Post Comment';
        request.fields['comment_parent'] = '0';
        request.fields['value-for-money'] = data['rating'].toString();
        request.fields['service'] = data['rating'].toString();
        request.fields['location'] = data['rating'].toString();
        request.fields['cleanliness'] = data['rating'].toString();
        request.fields['email'] = data['email'].toString();
        request.fields['author'] = data['name'].toString();
        await request.send();
      }
      if (serverConfig['type'] == 'mylisting') {
        var request = http.MultipartRequest(
            'POST', Uri.parse('$url/wp-comments-post.php'));
        request.fields['comment_post_ID'] = productId.toString();
        request.fields['comment'] = data['post_content'];
        request.fields['submit'] = 'Post Comment';
        request.fields['comment_parent'] = '0';
        request.fields['rating_star_rating'] = (data['rating'] * 2).toString();
        request.fields['hospitality_star_rating'] =
            (data['rating'] * 2).toString();
        request.fields['service_star_rating'] = (data['rating'] * 2).toString();
        request.fields['pricing_star_rating'] = (data['rating'] * 2).toString();
        request.fields['email'] = data['email'].toString();
        request.fields['author'] = data['name'].toString();
        await request.send();
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<BookStatus> bookService({userId, value, message}) async {
    try {
      var str = convert.jsonEncode(value);
      var response = await http.post('$url/wp-json/wp/v2/booking', body: {
        'user_id': userId.toString(),
        'value': str,
        'message': message,
      });
      String status = convert.jsonDecode(response.body);
      BookStatus bookStatus;
      switch (status) {
        case 'booked':
          {
            bookStatus = BookStatus.booked;
            break;
          }

        case 'waiting':
          {
            bookStatus = BookStatus.waiting;
            break;
          }

        case 'confirmed':
          {
            bookStatus = BookStatus.confirmed;
            break;
          }

        case 'unavailable':
          {
            bookStatus = BookStatus.unavailable;
            break;
          }

        default:
          {
            bookStatus = BookStatus.error;
            break;
          }
      }
      return bookStatus;
    } catch (e) {
      printLog('bookService error: $e');
      return BookStatus.error;
    }
  }

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
      return list;
    } catch (err) {
      printLog('err at getProductRecents func ${err.toString()}');
      rethrow;
    }
  }

  @override
  Future<List<ListingBooking>> getBooking({userId, page, perPage}) async {
    var endpoint =
        '$url//wp-json/wp/v2/get-bookings?user_id=$userId&page=$page&per_page=$perPage';
    var bookings = <ListingBooking>[];
    try {
      final response = await http.get(endpoint);
      for (var item in convert.jsonDecode(response.body)) {
        var booking = ListingBooking.fromJson(item);
        bookings.add(booking);
      }
    } catch (e) {
      printLog('listing.dart getBooking $e');
    }
    return bookings;
  }

  @override
  Future<Map<String, dynamic>> checkBookingAvailability({data}) async {
    var endpoint = '$url/wp-json/wp/v2/check-availability';
    try {
      final response =
          await http.post(endpoint, body: convert.jsonEncode(data), headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      });

      return convert.jsonDecode(response.body);
    } catch (e) {
      printLog('listing.dart checkBookingAvailability $e');
    }
    return {};
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
      return 'Unknown error: $e';
    }
  }

  @override
  Future<List<Prediction>> getAutoCompletePlaces(
      String term, String sessionToken) {
    throw UnimplementedError();
  }

  @override
  Future<List<ListingLocation>> getLocations() async {
    var list = <ListingLocation>[];
    if (Config().isListingType) {
      var i = 1;
      var locationTag = '';
      switch (Config().typeName) {
        case 'listeo':
          locationTag = 'region';
          break;
        case 'listpro':
          locationTag = 'location';
          break;
        case 'mylisting':
          return [];
      }
      while (true) {
        var endpoint = '$url/wp-json/wp/v2/$locationTag?page=$i&per_page=100';
        printLog(endpoint);
        var response = await http.get(
          endpoint,
        );
        var result = convert.jsonDecode(response.body);
        if (result.isEmpty) {
          return list;
        }
        for (var item in result) {
          list.add(ListingLocation.fromJson(item));
        }
        i++;
      }
    }
    return list;
  }

  @override
  Future<List<Blog>> getBlogs<int>({
    int cursor,
    Function(int) cursorCallback,
  }) async {
    try {
      dynamic page = cursor ?? 1;
      final param = '_embed&page=$page';
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
