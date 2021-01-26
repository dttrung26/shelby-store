import 'dart:async';
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

import '../../../common/config.dart';

class TapServices {
  Future<String> getCheckoutUrl(params) async {
    try {
      var response = await http.post(
        'https://api.tap.company/v2/charges',
        body: convert.jsonEncode(params),
        headers: {
          'content-type': 'application/json',
          'Authorization': 'Bearer ' + TapConfig['SecretKey']
        },
      );

      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return body['transaction'] != null ? body['transaction']['url'] : null;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
