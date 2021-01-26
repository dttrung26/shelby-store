import 'dart:convert';
import 'dart:convert' as convert;
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:encrypt/encrypt.dart' as encryptor;
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:transparent_image/transparent_image.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:validate/validate.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../common/constants.dart';
import '../generated/l10n.dart';
import '../models/index.dart'
    show AddonsOption, CartModel, Product, ProductModel;
import '../screens/cart/coupon_list.dart';
import '../screens/index.dart' show ProductDetailScreen;
import '../services/index.dart';
import '../tabbar.dart';
import '../widgets/blog/banner/blog_list_view.dart';
import '../widgets/blog/banner/blog_view.dart';
import '../widgets/common/skeleton.dart';
import 'config.dart';
import 'constants.dart';

enum kSize { small, medium, large }

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor != null
        ? hexColor.toUpperCase().replaceAll('#', '')
        : 'FFFFFF';
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static HexColor fromJson(String json) => json != null ? HexColor(json) : null;

  static List<HexColor> fromListJson(List listJson) =>
      listJson.map((e) => HexColor.fromJson(e as String)).toList();

  String toJson() => super.value.toRadixString(16);
}

class Tools {
  static double formatDouble(num value) => value == null ? null : value * 1.0;

  static String formatDateString(String date) {
    var timeFormat = DateTime.parse(date);
    final timeDif = DateTime.now().difference(timeFormat);
    return timeago.format(DateTime.now().subtract(timeDif), locale: 'en');
  }

  static String prestashopImage(String url, [kSize size = kSize.medium]) {
    if (url.contains('?')) {
      switch (size) {
        case kSize.large:
          return url.replaceFirst('?', '/large_default?');
        case kSize.small:
          return url.replaceFirst('?', '/small_default?');
        default: // kSize.medium
          return url.replaceFirst('?', '/medium_default?');
      }
    }
    switch (size) {
      case kSize.large:
        return '$url/large_default';
      case kSize.small:
        return '$url/small_default';
      default: // kSize.medium
        return '$url/medium_default';
    }
  }

  static String formatImage(String url, [kSize size = kSize.medium]) {
    if (serverConfig['type'] == 'presta') {
      return prestashopImage(url, size);
    }

    if (Config().isCacheImage ?? kAdvanceConfig['kIsResizeImage']) {
      var pathWithoutExt = p.withoutExtension(url);
      var ext = p.extension(url);
      var imageURL = url ?? kDefaultImage;

      if (ext == '.jpeg') {
        imageURL = url;
      } else {
        switch (size) {
          case kSize.large:
            imageURL = '$pathWithoutExt-large$ext';
            break;
          case kSize.small:
            imageURL = '$pathWithoutExt-small$ext';
            break;
          default: // kSize.medium:e
            imageURL = '$pathWithoutExt-medium$ext';
            break;
        }
      }

      return imageURL;
    } else {
      return url;
    }
  }

  static NetworkImage networkImage(String url, [kSize size = kSize.medium]) {
    return NetworkImage(formatImage(url, size) ?? kDefaultImage);
  }

  /// Smart image function to load image cache and check empty URL to return empty box
  /// Only apply for the product image resize with (small, medium, large)
  static Widget image({
    String url,
    kSize size,
    double width,
    double height,
    BoxFit fit,
    String tag,
    double offset = 0.0,
    bool isResize = false,
    isVideo = false,
    hidePlaceHolder = false,
  }) {
    if (height == null && width == null) {
      width = 200;
    }
    var ratioImage = kAdvanceConfig['RatioProductImage'] ?? 1.2;

    if (url?.isEmpty ?? true) {
      return FutureBuilder<bool>(
        future: Future.delayed(const Duration(seconds: 10), () => false),
        initialData: true,
        builder: (context, snapshot) {
          final showSkeleton = snapshot.data;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: showSkeleton
                ? Skeleton(
                    width: width,
                    height: height ?? width * ratioImage,
                  )
                : SizedBox(
                    width: width,
                    height: height ?? width * ratioImage,
                    child: const Icon(Icons.error_outline),
                  ),
          );
        },
      );
    }

    if (isVideo) {
      return Stack(
        children: <Widget>[
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(color: Colors.black12.withOpacity(1)),
            child: ExtendedImage.network(
              isResize ? formatImage(url, size) : url,
              width: width,
              height: height ?? width * ratioImage,
              fit: fit,
              cache: true,
              enableLoadState: false,
              alignment: Alignment(
                  (offset >= -1 && offset <= 1)
                      ? offset
                      : (offset > 0)
                          ? 1.0
                          : -1.0,
                  0.0),
            ),
          ),
          Positioned.fill(
            child: Icon(
              Icons.play_circle_outline,
              color: Colors.white70.withOpacity(0.5),
              size: width == null ? 30 : width / 1.7,
            ),
          ),
        ],
      );
    }

    if (kIsWeb) {
      /// temporary fix on CavansKit https://github.com/flutter/flutter/issues/49725
      var imageURL = isResize ? formatImage(url, size) : url;

      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: width * ratioImage),
        child: FadeInImage.memoryNetwork(
          image: '$kImageProxy$imageURL',
          fit: fit,
          width: width,
          height: height,
          placeholder: kTransparentImage,
        ),
      );
    }

    return ExtendedImage.network(
      isResize ? formatImage(url, size) : url,
      width: width,
      height: height,
      fit: fit,
      cache: true,
      enableLoadState: false,
      alignment: Alignment(
        (offset >= -1 && offset <= 1)
            ? offset
            : (offset > 0)
                ? 1.0
                : -1.0,
        0.0,
      ),
      loadStateChanged: (ExtendedImageState state) {
        Widget widget;
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            widget = hidePlaceHolder
                ? const SizedBox()
                : Skeleton(
                    width: width ?? 100,
                    height:
                        width != null ? width * ratioImage : 100 * ratioImage,
                  );
            break;
          case LoadState.completed:
            widget = ExtendedRawImage(
              image: state.extendedImageInfo?.image,
              width: width,
              height: height,
              fit: fit,
            );
            break;
          case LoadState.failed:
            widget = Container(
              width: width,
              height: height ?? width * ratioImage,
              color: const Color(kEmptyColor),
            );
            break;
        }
        return widget;
      },
    );
  }

  static String getAddsOnPriceProductValue(
    Product product,
    List<AddonsOption> selectedOptions,
    Map<String, dynamic> rates,
    String currency, {
    bool onSale,
  }) {
    var price = double.tryParse(onSale == true
            ? (isNotBlank(product.salePrice)
                ? product.salePrice
                : product.price)
            : product.price) ??
        0.0;
    price += selectedOptions
        .map((e) => double.tryParse(e?.price ?? '0.0') ?? 0.0)
        .reduce((a, b) => a + b);

    return getCurrencyFormatted(price, rates, currency: currency);
  }

  static String getVariantPriceProductValue(
    product,
    Map<String, dynamic> rates,
    String currency, {
    bool onSale,
  }) {
    String price = onSale == true
        ? (isNotBlank(product.salePrice) ? product.salePrice : product.price)
        : product.price;
    return getCurrencyFormatted(price, rates, currency: currency);
  }

  static String getPriceProductValue(Product product, String currency,
      {bool onSale}) {
    try {
      var price = onSale == true
          ? (isNotBlank(product.salePrice)
              ? product.salePrice ?? '0'
              : product.price)
          : (isNotBlank(product.regularPrice)
              ? product.regularPrice ?? '0'
              : product.price);
      return price;
    } catch (e, trace) {
      printLog(e.toString());
      printLog(trace.toString());
      return '';
    }
  }

  static String getPriceProduct(
      product, Map<String, dynamic> rates, String currency,
      {bool onSale}) {
    var price = getPriceProductValue(product, currency, onSale: onSale);

    if (price == null || price == '') {
      return '';
    }
    return getCurrencyFormatted(price, rates, currency: currency);
  }

  static String getCurrencyFormatted(price, Map<String, dynamic> rates,
      {currency}) {
    Map<String, dynamic> defaultCurrency = kAdvanceConfig['DefaultCurrency'];
    List currencies = kAdvanceConfig['Currencies'] ?? [];
    var formatCurrency;

    try {
      if (currency != null && currencies.isNotEmpty) {
        currencies.forEach((item) {
          if ((item as Map)['currency'] == currency) {
            defaultCurrency = item;
          }
        });
      }

      if (rates != null && rates[defaultCurrency['currencyCode']] != null) {
        price = getPriceValueByCurrency(
          price,
          defaultCurrency['currencyCode'],
          rates,
        );
      }

      formatCurrency = NumberFormat.currency(
          locale: 'en',
          name: '',
          decimalDigits: defaultCurrency['decimalDigits']);

      var number = '';
      if (price == null) {
        number = '';
      } else if (price is String) {
        final newString = price.replaceAll(RegExp('[^\\d.,]+'), '');
        number = formatCurrency
            .format(newString.isNotEmpty ? double.parse(newString) : 0);
      } else {
        number = formatCurrency.format(price);
      }

      return defaultCurrency['symbolBeforeTheNumber']
          ? defaultCurrency['symbol'] + number
          : number + defaultCurrency['symbol'];
    } catch (err, trace) {
      printLog(trace);
      printLog('getCurrencyFormatted $err');
      return defaultCurrency['symbolBeforeTheNumber']
          ? defaultCurrency['symbol'] + formatCurrency.format(0)
          : formatCurrency.format(0) + defaultCurrency['symbol'];
    }
  }

  static double getPriceValueByCurrency(
      price, String currency, Map<String, dynamic> rates) {
    final _currency = currency.toUpperCase();
    double rate = rates[_currency] ?? 1.0;

    if (price == '' || price == null) {
      return 0;
    }
    return double.parse(price.toString()) * rate;
  }

  /// check tablet screen
  static bool isTablet(MediaQueryData query) {
    if (Config().isBuilder) {
      return false;
    }

    if (kIsWeb) {
      return true;
    }

    if (UniversalPlatform.isWindows || UniversalPlatform.isMacOS) {
      return false;
    }

    var size = query.size;
    var diagonal =
        sqrt((size.width * size.width) + (size.height * size.height));
    var isTablet = diagonal > 1100.0;
    return isTablet;
  }

  /// cache avatar for the chat
  static CachedNetworkImage getCachedAvatar(String avatarUrl) {
    return CachedNetworkImage(
      imageUrl: avatarUrl,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }

  static Future<List<dynamic>> loadStatesByCountry(String country) async {
    try {
      // load local config
      var path = 'lib/config/states/state_${country.toLowerCase()}.json';
      final appJson = await rootBundle.loadString(path);
      return List<dynamic>.from(convert.jsonDecode(appJson));
    } catch (e) {
      return [];
    }
  }

  static dynamic getValueByKey(Map<String, dynamic> json, String key) {
    if (key == null) return null;
    try {
      List keys = key.split('.');
      var data = Map<String, dynamic>.from(json);
      if (keys[0] == '_links') {
        var links = json['listing_data']['_links'] ?? [];
        for (var item in links) {
          if (item['network'] == keys[keys.length - 1]) return item['url'];
        }
      }
      for (var i = 0; i < keys.length - 1; i++) {
        if (data[keys[i]] is Map) {
          data = data[keys[i]];
        } else {
          return null;
        }
      }
      if (data[keys[keys.length - 1]].toString().isEmpty) return null;
      return data[keys[keys.length - 1]];
    } catch (e) {
      printLog(e.toString());
      return 'Error when mapping $key';
    }
  }

  // ignore: always_declare_return_types
  static showSnackBar(ScaffoldState scaffoldState, message) {
    // ignore: deprecated_member_use
    scaffoldState.showSnackBar(SnackBar(content: Text(message)));
  }

  static Future<void> launchURL(String url) async {
    if (await canLaunch(url ?? '')) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class Validator {
  static String validateEmail(String value) {
    try {
      Validate.isEmail(value);
    } catch (e) {
      return 'The E-mail Address must be a valid email address.';
    }

    return null;
  }
}

class Videos {
  static String getVideoLink(String content) {
    if (_getYoutubeLink(content) != null) {
      return _getYoutubeLink(content);
    } else if (_getFacebookLink(content) != null) {
      return _getFacebookLink(content);
    } else {
      return _getVimeoLink(content);
    }
  }

  static String _getYoutubeLink(String content) {
    final regExp = RegExp(
        'https://www.youtube.com/((v|embed))\/?[a-zA-Z0-9_-]+',
        multiLine: true,
        caseSensitive: false);

    String youtubeUrl;

    try {
      if (content?.isNotEmpty ?? false) {
        var matches = regExp.allMatches(content);
        if (matches?.isNotEmpty ?? false) {
          youtubeUrl = matches?.first?.group(0) ?? '';
        }
      }
    } catch (error) {
//      printLog('[_getYoutubeLink] ${error.toString()}');
    }
    return youtubeUrl;
  }

  static String _getFacebookLink(String content) {
    final regExp = RegExp(
        'https://www.facebook.com\/[a-zA-Z0-9\.]+\/videos\/(?:[a-zA-Z0-9\.]+\/)?([0-9]+)',
        multiLine: true,
        caseSensitive: false);

    String facebookVideoId;
    String facebookUrl;
    try {
      if (content?.isNotEmpty ?? false) {
        var matches = regExp.allMatches(content);
        if (matches?.isNotEmpty ?? false) {
          facebookVideoId = matches.first.group(1);
          if (facebookVideoId != null) {
            facebookUrl =
                'https://www.facebook.com/video/embed?video_id=$facebookVideoId';
          }
        }
      }
    } catch (error) {
      printLog(error);
    }
    return facebookUrl;
  }

  static String _getVimeoLink(String content) {
    final regExp = RegExp('https://player.vimeo.com/((v|video))\/?[0-9]+',
        multiLine: true, caseSensitive: false);

    String vimeoUrl;

    try {
      if (content?.isNotEmpty ?? false) {
        var matches = regExp.allMatches(content);
        if (matches?.isNotEmpty ?? false) {
          vimeoUrl = matches.first.group(0);
        }
      }
    } catch (error) {
      printLog(error);
    }
    return vimeoUrl;
  }
}

class Utils {
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static int getListeoTimeSlotDate(DateTime date) {
    return date.weekday - 1;
  }

  // static void setStatusBarWhiteForeground(bool active) {
  //   if (!UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
  //     return;
  //   }
  //
  //   FlutterStatusbarcolor.setStatusBarWhiteForeground(active);
  // }

  static void changeStatusBarColor(ThemeMode themeMode,
      [final Color color = Colors.transparent]) {
    if (Platform.isAndroid) {
      try {
        if (themeMode == ThemeMode.light) {
          FlutterStatusbarcolor.setNavigationBarColor(
            Colors.white,
            animate: true,
          );
          FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);
          FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
        } else {
          FlutterStatusbarcolor.setNavigationBarColor(Colors.transparent,
              animate: true);
          FlutterStatusbarcolor.setNavigationBarWhiteForeground(true);
          FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    } else if (Platform.isIOS) {
      try {
        FlutterStatusbarcolor.setStatusBarColor(color, animate: false);
        if (useWhiteForeground(color)) {
          if (themeMode == ThemeMode.light) {
            FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
          } else {
            FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
          }
        } else {
          FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  static Future<dynamic> parseJsonFromAssets(String assetsPath) async {
    return rootBundle.loadString(assetsPath).then(convert.jsonDecode);
  }

  static Function getLanguagesList = getLanguages;

  static Future onTapNavigateOptions(
      {BuildContext context, Map config, List<Product> products}) async {
    /// support to show the product detail
    if (config['product'] != null) {
      /// for pre-load the product detail
      final _service = Services();
      var product = await _service.api.getProduct(config['product']);

      return Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                ProductDetailScreen(product: product),
            fullscreenDialog: true,
          ));
    }
    if (config['tab'] != null) {
      return MainTabControlDelegate.getInstance().changeTab(config['tab']);
    }
    if (config['screen'] != null) {
      return Navigator.of(context).pushNamed(config['screen']);
    }

    /// Launch the URL from external
    if (config['url_launch'] != null) {
      await launch(config['url_launch']);
    }

    /// support to show blog detail
    if (config['blog'] != null) {
      return Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              BlogView(id: config['blog'].toString()),
          fullscreenDialog: true,
        ),
      );
    }

    /// support to show blog category
    if (config['blog_category'] != null) {
      return Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              BlogListView(id: config['blog_category'].toString()),
          fullscreenDialog: true,
        ),
      );
    }

    if (config['coupon'] != null) {
      return Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => CouponList(
            couponCode: config['coupon'].toString(),
            onSelect: (String couponCode) async {
              final _sharedPrefs = await SharedPreferences.getInstance();

              await _sharedPrefs.setString('saved_coupon', couponCode);
              Provider.of<CartModel>(context, listen: false).loadSavedCoupon();

              Tools.showSnackBar(Scaffold.of(context),
                  S.of(context).couponHasBeenSavedSuccessfully);
            },
          ),
        ),
      );
    }

    /// Navigate to vendor store on Banner Image
    if (config['vendor'] != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              Services().widget.renderVendorScreen(config['vendor']),
        ),
      );
      return;
    }

    /// support to show the post detail
    if (config['url'] != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColorLight,
              leading: GestureDetector(
                child: const Icon(Icons.arrow_back_ios),
                onTap: () => Navigator.pop(context),
              ),
            ),
            body: WebView(
              initialUrl: config['url'],
              javascriptMode: JavascriptMode.unrestricted,
            ),
          ),
        ),
      );
    } else {
      /// For static image
      if (config['category'] == null &&
          config['tag'] == null &&
          products == null &&
          config['location'] == null) {
        return;
      }

      /// Default navigate to show the list products
      await ProductModel.showList(
          context: context, config: config, products: products);
    }
  }

  static String encodeCookie(String cookie) {
    var bytes = convert.utf8.encode(cookie);
    var base64Str = convert.base64.encode(bytes);
    return base64Str;
  }

  static String encodeData(String data) {
    var base64 = encodeCookie(data);
    final key = encryptor.Key.fromLength(32);
    final iv = encryptor.IV.fromLength(16);
    final encrypter = encryptor.Encrypter(encryptor.AES(key));
    final encrypted = encrypter.encrypt(base64, iv: iv);
    return encrypted.base64;
  }

  static String decodeUserData(String data) {
    final key = encryptor.Key.fromLength(32);
    final iv = encryptor.IV.fromLength(16);
    final encrypter = encryptor.Encrypter(encryptor.AES(key));
    final decrypted = encrypter.decrypt64(data, iv: iv);
    var base64Str = convert.base64.decode(decrypted);
    var result = convert.utf8.decode(base64Str);
    return result;
  }

  static String capitalize(String s) =>
      (s.isEmpty ?? true) ? '' : s[0].toUpperCase() + s.substring(1);
}

class ImageTools {
  static Future<String> compressAndConvertImagesForUploading(
      List<dynamic> images) async {
    var base64 = '';
    for (var image in images) {
      base64 += await compressImage(image);
      base64 += ',';
    }
    return base64;
  }

  static Future<String> compressImage(dynamic image) async {
    var base64 = '';
    var quality = 60;
    if (image is Asset) {
      var byteData = await image.getByteData(quality: 100);
      var bytes = byteData.buffer.asUint8List();
      var result = await FlutterImageCompress.compressWithList(
        bytes,
        minHeight: 800,
        minWidth: 800,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      base64 += base64Encode(result);
    }
    if (image is PickedFile) {
      var result = await FlutterImageCompress.compressWithFile(
        File(image.path).absolute.path,
        minWidth: 800,
        minHeight: 800,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      base64 += base64Encode(result);
    }
    if (image is String) {
      if (image.contains('http')) {
        base64 += image;
      }
    }
    return base64;
  }
}
