import '../../../services/service_config.dart';
import '../index.dart';
import 'strapi.dart';

mixin StrapiMixin on ConfigMixin {
  @override
  void configTrapi(appConfig) {
    Strapi().appConfig(appConfig);
    api = Strapi();
    widget = StrapiWidget();
  }
}
