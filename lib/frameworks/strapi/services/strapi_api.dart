import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../common/constants.dart';

class StrapiAPI {
  String url;
  StrapiAPI(this.url);

  String apiLink(String endPoint) {
    return '$url$endPoint';
  }

  String _getOAuthURL(String requestMethod, String endpoint) {
    return url + endpoint;
  }

  Future<dynamic> getAsync(String endPoint) async {
    try {
      final url = _getOAuthURL('GET', endPoint);
      printLog(
          "[strapi_api][${DateTime.now().toString().split(' ').last}] getAsync START [endPoint:$endPoint] url:$url");
      final response = await http.get(url);

      return json.decode(response.body);
    } catch (e, trace) {
      printLog(trace);
    }
  }
}
