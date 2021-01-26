import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/config.dart';
import 'cart_mixin.dart';

mixin CurrencyMixin on CartMixin {
  Future getCurrency() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      currency = prefs.getString('currency') ??
          (kAdvanceConfig['DefaultCurrency'] as Map)['currency'];
    } catch (e) {
      currency = (kAdvanceConfig['DefaultCurrency'] as Map)['currency'];
    }
  }

  Future getCurrencyString() async {
    String currency;
    try {
      var prefs = await SharedPreferences.getInstance();
      currency = prefs.getString('currency') ??
          (kAdvanceConfig['DefaultCurrency'] as Map)['currency'];
    } catch (e) {
      currency = (kAdvanceConfig['DefaultCurrency'] as Map)['currency'];
    }
    return currency;
  }

  Future getCurrencyCode() async {
    String currencyCode;
    try {
      var prefs = await SharedPreferences.getInstance();
      currencyCode = prefs.getString('currencyCode') ??
          (kAdvanceConfig['DefaultCurrency'] as Map)['currencyCode'];
    } catch (e) {
      currencyCode = (kAdvanceConfig['DefaultCurrency'] as Map)['currencyCode'];
    }
    return currencyCode;
  }

  void changeCurrency(value) {
    currency = value;
  }

  void changeCurrencyRates(value) {
    currencyRates = value;
  }
}
