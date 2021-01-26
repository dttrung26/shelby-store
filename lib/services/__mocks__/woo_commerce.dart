//import 'package:quiver/strings.dart';
//
//import '../../common/config.dart';
//import '../../common/tools.dart';
//import '../../models/category/category.dart';
//import '../../models/product/product.dart';
//import '../../services/helper/blognews_api.dart';
//import '../../services/woo_commerce.dart';
//import 'blognews_api.dart';
//import 'mock_constants.dart';
//
//class WooCommerceMock extends WooCommerce {
//  static final WooCommerceMock _instance = WooCommerce();
//  factory WooCommerceMock() => _instance;
//
//  @override
//  BlogNewsApi blogApi;
//
//  @override
//  void appConfig(appConfig) {
//    super.appConfig(appConfig);
//    blogApi = BlogNewsApiMock(appConfig["blog"] ?? appConfig["url"]);
//  }
//
//  @override
//  Future<List<Category>> getCategoriesByPage({lang, page}) async {
//    try {
//      List<Category> categories = [];
//      var response =
//          await Utils.parseJsonFromAssets(MockConstants.mockDataCategoryByPage);
//      if (response is Map && isNotBlank(response["message"])) {
//        throw Exception(response["message"]);
//      } else {
//        for (var item in response) {
//          if (item['slug'] != "uncategorized" && item['count'] > 0) {
//            categories.add(Category.fromJson(item));
//          }
//        }
//        return categories;
//      }
//    } catch (e) {
//      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
//      rethrow;
//    }
//  }
//
//  @override
//  Future<List<Product>> fetchProductsByCategory({
//    categoryId,
//    tagId,
//    page,
//    minPrice,
//    maxPrice,
//    orderBy,
//    lang,
//    order,
//    featured,
//    onSale,
//    attribute,
//    attributeTerm,
//  }) async {
//    try {
//      List<Product> list = [];
//      featured ??= 0;
//      onSale ??= 0;
//
//      var response = await Utils.parseJsonFromAssets(
//          MockConstants.mockDataProductByCategory);
//
//      for (var item in response) {
//        if (!kAdvanceConfig['hideOutOfStock'] || item["in_stock"]) {
//          list.add(Product.fromJson(item));
//        }
//      }
//      return list;
//    } catch (e) {
//      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
//      rethrow;
//    }
//  }
//
//  @override
//  Future<List<Product>> fetchProductsLayout({config, lang}) async {
//    try {
//      List<Product> list = [];
//
//      if (kAdvanceConfig['isCaching'] && configCache != null) {
//        var obj;
//        final horizontalLayout = configCache["HorizonLayout"] as List;
//        if (horizontalLayout != null) {
//          obj = horizontalLayout.firstWhere(
//              (o) =>
//                  o["layout"] == config["layout"] &&
//                  ((o["category"] != null &&
//                          o["category"] == config["category"]) ||
//                      (o["tag"] != null && o["tag"] == config["tag"])),
//              orElse: () => null);
//          if (obj != null && obj["data"].length > 0) return obj["data"];
//        }
//
//        final verticalLayout = configCache["VerticalLayout"] as List;
//        if (verticalLayout != null) {
//          obj = verticalLayout.firstWhere(
//              (o) =>
//                  o["layout"] == config["layout"] &&
//                  ((o["category"] != null &&
//                          o["category"] == config["category"]) ||
//                      (o["tag"] != null && o["tag"] == config["tag"])),
//              orElse: () => null);
//          if (obj != null && obj["data"].length > 0) return obj["data"];
//        }
//      }
//      var response =
//          await Utils.parseJsonFromAssets(MockConstants.mockDataProductLayout);
//
//      if (response is Map && isNotBlank(response["message"])) {
//        throw Exception(response["message"]);
//      } else {
//        for (var item in response) {
//          if (!kAdvanceConfig['hideOutOfStock'] || item["in_stock"]) {
//            Product product = Product.fromJson(item);
//            product.categoryId = config["category"];
//            list.add(product);
//          }
//        }
//        return list;
//      }
//    } catch (e) {
//      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
//      return [];
//    }
//  }
//}
