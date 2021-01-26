import '../../../services/service_config.dart';
import '../index.dart';
import 'listing.dart';

mixin ListingMixin on ConfigMixin {
  @override
  void configListing(appConfig) {
    ListingService().appConfig(appConfig);
    api = ListingService();
    widget = ListingWidget();
  }
}
