import 'package:quiver/strings.dart';

import '../../../common/tools.dart';

class MagentoHelper {
  static String getCustomAttribute(customAttributes, attribute) {
    String value;
    if (customAttributes != null && customAttributes.length > 0) {
      for (var item in customAttributes) {
        if (item['attribute_code'] == attribute) {
          value = item['value'];
          break;
        }
      }
    }
    return value;
  }

  static String getProductImageUrlByName(domain, imageName) {
    return '$domain/pub/media/catalog/product/$imageName';
  }

  static String getProductImageUrl(domain, item, [attribute = 'thumbnail']) {
    final imageName = getCustomAttribute(item['custom_attributes'], attribute);
    if (imageName != null) {
      return imageName.contains('http')
          ? imageName
          : getProductImageUrlByName(domain, imageName);
    } else {
      return '';
    }
  }

  static String getCategoryImageUrl(domain, item, [attribute = 'image']) {
    final imageName = getCustomAttribute(item['custom_attributes'], attribute);
    if (imageName != null) {
      return '$domain/pub/media/catalog/category/$imageName';
    }
    return '';
  }

  static String getErrorMessage(body) {
    String message = body['message'];
    if (body['parameters'] != null && body['parameters'].length > 0) {
      final params = body['parameters'];
      final keys = params is List ? params : params.keys.toList();
      for (var i = 0; i < keys.length; i++) {
        if (params is List) {
          message = message.replaceAll('%${i + 1}', keys[i].toString());
        } else {
          message =
              message.replaceAll('%' + keys[i], params[keys[i]].toString());
        }
      }
    }
    return message;
  }

  static String buildUrl(String domain, String endpoint, [String locale]) {
    List<Map<String, dynamic>> languages = Utils.getLanguagesList();
    if (isNotBlank(locale)) {
      var language = languages.firstWhere(
          (o) => o['code'] == locale && isNotBlank(o['storeViewCode']),
          orElse: () => null);
      if (language != null) {
        return "$domain/index.php/rest/${language["storeViewCode"]}/V1/$endpoint";
      }
    }
    return '$domain/index.php/rest/V1/$endpoint';
  }

  static bool isEndLoadMore(body) {
    int total_count = body['total_count'];
    int page_size = body['search_criteria']['page_size'];
    int current_page = body['search_criteria']['current_page'];
    var maxPage = (total_count / page_size).ceil();
    return current_page > maxPage;
  }
}
