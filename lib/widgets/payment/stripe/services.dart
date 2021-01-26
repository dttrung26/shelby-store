import 'dart:async';
import 'dart:convert';
import 'dart:io' show ContentType, HttpHeaders, HttpStatus;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';

class StripeServices {
  Stripe stripe;

  static final StripeServices _instance = StripeServices._internal();

  factory StripeServices() {
    _instance.stripe ??= Stripe(
        kStripeConfig['publishableKey'],
        returnUrlForSca: kStripeConfig['returnUrl'],
      );
    return _instance;
  }

  StripeServices._internal();

  Future<Map<String, dynamic>> createPaymentIntent({
    @required String totalPrice,
    String currencyCode,
    String emailAddress,
    String name,
    StripeCard stripeCard,
  }) async {
    try {
      final paymentMethod =
          await stripe.api.createPaymentMethodFromCard(stripeCard);

      final result = await http.post(
        "${kStripeConfig["serverEndpoint"]}/payment-intent",
        body: jsonEncode(
          {
            'payment_method_id': paymentMethod['id'],
            'email': emailAddress,
            'amount': totalPrice,
            'currencyCode': currencyCode,
            'captureMethod': (kStripeConfig['enableManualCapture'] ?? false) ? 'manual' : 'automatic'
          },
        ),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
        },
      );

      if (result.statusCode == HttpStatus.ok) {
        final body = json.decode(result.body) ?? {};
        final success = body['success'];

        if (success) {
          return await stripe.api.retrievePaymentIntent(
            body['client_secret'],
          );
        }
      }

      return null;
    } catch (e) {
      printLog(e);
      rethrow;
    }
  }

  Future<bool> executePayment({
    @required String totalPrice,
    String currencyCode,
    String emailAddress,
    String name,
    StripeCard stripeCard,
  }) async {
    try {
      var paymentIntentRes = await createPaymentIntent(
        totalPrice: totalPrice,
        currencyCode: currencyCode,
        emailAddress: emailAddress,
        name: name,
        stripeCard: stripeCard,
      );

      if (paymentIntentRes == null) {
        return false;
      }

      final String clientSecret = paymentIntentRes['client_secret'];
      final String paymentMethodId = paymentIntentRes['payment_method'];

      //3D secure is enable in this card
      if (paymentIntentRes['status'] == 'requires_action') {
        paymentIntentRes =
            await confirmPayment3DSecure(clientSecret, paymentMethodId);
      }

      return paymentIntentRes['status'] == 'succeeded';
    } catch (e) {
      printLog(e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> confirmPayment3DSecure(
      String clientSecret, String paymentMethodId) async {
    try {
      await stripe.confirmPayment(clientSecret,
          paymentMethodId: paymentMethodId);
      final paymentIntentRes3dSecure =
          await stripe.api.retrievePaymentIntent(clientSecret);
      return paymentIntentRes3dSecure;
    } catch (e) {
      printLog(e);
      return null;
    }
  }
}
