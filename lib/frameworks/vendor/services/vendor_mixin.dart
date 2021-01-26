import '../../../services/service_config.dart';
import '../dokan.dart';
import '../wcfm.dart';
import 'dokan.dart';
import 'wcfm.dart';

mixin VendorMixin on ConfigMixin {
  @override
  void configWCFM(appConfig) {
    WCFMApi().appConfig(appConfig);
    api = WCFMApi();
    widget = WCFMWidget();
  }

  @override
  void configDokan(appConfig) {
    DokanApi().appConfig(appConfig);
    api = DokanApi();
    widget = DokanWidget();
  }
}
