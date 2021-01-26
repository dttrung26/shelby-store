import '../../../services/service_config.dart';
import '../index.dart';
import 'opencart.dart';

mixin OpencartMixin on ConfigMixin {
  @override
  void configOpencart(appConfig) {
    OpencartApi().setAppConfig(appConfig);
    api = OpencartApi();
    widget = OpencartWidget();
  }
}
