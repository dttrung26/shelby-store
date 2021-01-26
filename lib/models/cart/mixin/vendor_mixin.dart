import 'cart_mixin.dart';

mixin VendorMixin on CartMixin {
  List<dynamic> selectedShippingMethods = [];

  void setSelectedMethods(List<dynamic> selected) {
    selectedShippingMethods = selected;
  }
}
