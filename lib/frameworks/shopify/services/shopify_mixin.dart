import '../../../services/service_config.dart';
import '../index.dart';
import 'shopify.dart';

mixin ShopifyMixin on ConfigMixin {
  @override
  void configShopify(appConfig) {
    ShopifyApi().setAppConfig(appConfig);
    api = ShopifyApi();
    widget = ShopifyWidget();
  }
}
