import '../../../services/service_config.dart';
import '../index.dart';
import 'vendor_admin.dart';

mixin VendorAdminMixin on ConfigMixin {
  @override
  void configVendorAdmin(appConfig) {
    VendorAdminApi().appConfig(appConfig);
    api = VendorAdminApi();
    widget = VendorAdminWidget();
  }
}
