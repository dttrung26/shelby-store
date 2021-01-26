import '../../../services/service_config.dart';
import '../index.dart';
import 'magento.dart';

mixin MagentoMixin on ConfigMixin {
  @override
  void configMagento(appConfig) {
    MagentoApi().setAppConfig(appConfig);
    api = MagentoApi();
    widget = MagentoWidget();
  }
}
