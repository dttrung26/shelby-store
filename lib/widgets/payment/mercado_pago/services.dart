import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

import '../../../common/config.dart';

class MercadoPagoServices {
  String accessToken = MercadoPagoConfig['accessToken'];
  String apiUrl = 'https://api.mercadopago.com/checkout/preferences';
  String orderId;
  Future<Map<String, String>> getPaymentUrl(Map order) async {
    var map = <String, String>{};
    try {
      var response = await http.post(apiUrl,
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: convert.jsonEncode(order));
      var result = convert.jsonDecode(response.body);

      map['paymentUrl'] = MercadoPagoConfig['production']
          ? result['init_point']
          : result['sandbox_init_point'];
      map['orderId'] = result['id'];
    } catch (e) {
      rethrow;
    }
    return map;
  }
}
