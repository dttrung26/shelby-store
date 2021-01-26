import '../../../services/service_config.dart';
import '../index.dart';
import 'woo_commerce.dart';

mixin WooMixin on ConfigMixin {
  @override
  void configWoo(appConfig) {
    api = WooCommerce();
    widget = WooWidget();
    api = (WooCommerce()..appConfig(appConfig));
  }
}
