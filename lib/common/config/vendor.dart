part of '../config.dart';

/// Everything Config about the Vendor Setting

/// Setting for Vendor Feature
const kVendorConfig = {
  /// Show Register by Vendor
  'VendorRegister': true,

  /// Disable show shipping methods by vendor
  'DisableVendorShipping': false,

  /// Enable/Disable showing all vendor markers on Map screen
  'ShowAllVendorMarkers': true,

  /// Enable/Disable native store management
  'DisableNativeStoreManagement': false,

  /// Dokan Vendor Dashboard
  'dokan': 'my-account?vendor_admin=true',
  'wcfm': 'store-manager?vendor_admin=true',
};
