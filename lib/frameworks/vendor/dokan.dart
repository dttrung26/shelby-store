import 'package:flutter/material.dart';

import '../../common/config.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show Product, Store;
import '../../widgets/common/webview.dart';
import '../woocommerce/index.dart';
import 'vendor_mixin.dart';

class DokanWidget extends WooWidget with VendorMixin {
  @override
  Product updateProductObject(Product product, Map json) {
    if (json['store'] != null && json['store']['id'] != null) {
      product.store = Store.fromDokanJson(json['store']);
    }
    return product;
  }

  @override
  Widget getAdminVendorScreen(context, dynamic user) {
    var base64Str = Utils.encodeCookie(user.cookie);
    var vendorURL =
        '${serverConfig['url']}/${kVendorConfig['dokan']}&cookie=$base64Str';

    return WebView(url: vendorURL, title: S.of(context).vendorAdmin);
  }
}
