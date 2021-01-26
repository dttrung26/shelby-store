import '../../../services/service_config.dart';
import '../index.dart';
import 'prestashop.dart';

mixin PrestashopMixin on ConfigMixin {
  @override
  void configPrestashop(appConfig) {
    Prestashop().appConfig(appConfig);
    api = Prestashop();
    widget = PrestashopWidget();
  }
}
