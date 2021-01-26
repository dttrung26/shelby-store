import '../frameworks/listing/services/listing_mixin.dart';
import '../frameworks/magento/services/magento_mixin.dart';
import '../frameworks/opencart/services/opencart_mixin.dart';
import '../frameworks/prestashop/services/prestashop_mixin.dart';
import '../frameworks/shopify/services/shopify_mixin.dart';
import '../frameworks/strapi/services/strapi_mixin.dart';
import '../frameworks/vendor/services/vendor_mixin.dart';
import '../frameworks/vendor_admin/services/vendor_admin_mixin.dart';
import '../frameworks/woocommerce/services/woo_mixin.dart';
import 'service_config.dart';
export 'service_config.dart';

class Services
    with
        ConfigMixin,
        WooMixin,
        MagentoMixin,
        OpencartMixin,
        ShopifyMixin,
        StrapiMixin,
        PrestashopMixin,
        VendorMixin,
        ListingMixin,
        VendorAdminMixin {
  static final Services _instance = Services._internal();

  factory Services() => _instance;

  Services._internal();
}
