import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PrestashopAPI {
  String url;
  String key;

  PrestashopAPI(this.url, this.key);

  String apiLink(String endPoint) {
    if (endPoint.contains('?')) {
      return '$url/api/$endPoint&ws_key=$key&output_format=JSON';
    } else {
      return '$url/api/$endPoint?ws_key=$key&output_format=JSON';
    }
  }

  Future<dynamic> getAsync(String endPoint) async {
    var response = await http.get(apiLink(endPoint));

    return jsonDecode(utf8.decode(response.bodyBytes));
  }
}
