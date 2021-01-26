part of '../config.dart';

/// Everything Config about the Product Setting

// FIXME 2.2 - Product Variant Design Layouts (optional) 🎨
/// The product variant config
/// Format: "<attribute-slug>": "<layout type>"
/// Layout type can be: "color", "box", "option" or "image".
const ProductVariantLayout = {
  'color': 'color',
  'size': 'box',
  'height': 'option',
  'color-image': 'image',
};

// FIXME 2.3 - Product Detail Layouts (optional) 🎨
/// use to config the product image height for the product detail
/// height=(percent * width-screen)
const kProductDetail = {
  'height': 0.4,
  'marginTop': 0,
  'safeArea': false,
  'showVideo': true,
  'showBrand': true,
  'showThumbnailAtLeast': 1,
  'layout': 'simpleType',

  /// Enable this to show review in product description.
  'enableReview': false,

  'attributeImagesSize': 50.0,
  'showSku': true,
  'showStockQuantity': true,
  'showProductCategories': true,
  'showProductTags': true,
  'hideInvalidAttributes': false,
};

/// For Product Add-ons plugin.
const kProductAddons = {
  /// Set the allowed file type for file upload.
  /// On iOS will open Photos app.
  'allowImageType': true,
  'allowVideoType': true,

  /// Enable to allow upload files other than image/video.
  /// On iOS will open Files app.
  'allowCustomType': true,

  /// Set allowed file extensions for custom type.
  /// Leave empty ('allowedCustomType': []) to support all extensions.
  'allowedCustomType': [
    'png',
    'pdf',
    'docx',
  ],

  /// Allow selecting multiple files for upload. Default: false.
  'allowMultiple': false,

  /// Set the file size limit (in MB) for upload. Recommended: <15MB.
  'fileUploadSizeLimit': 5.0,
};

const kCartDetail = {
  'minAllowTotalCartValue': 0,
  'maxAllowQuantity': 10,
};

// TODO 4.3- Product Variant Multi-Languages (optional) 🎨
const kProductVariantLanguage = {
  'en': {
    'color': 'Color',
    'size': 'Size',
    'height': 'Height',
    'color-image': 'Color',
  },
  'ar': {
    'color': 'اللون',
    'size': 'بحجم',
    'height': 'ارتفاع',
    'color-image': 'اللون',
  },
  'vi': {
    'color': 'Màu',
    'size': 'Kích thước',
    'height': 'Chiều Cao',
    'color-image': 'Màu',
  },
};

/// Exclude this categories from the list
const kExcludedCategory = 311;

const kSaleOffProduct = {
  /// Show Count Down for product type SaleOff
  'ShowCountDown': true,
  'Color': '#C7222B',
};

/// This is strict mode option to check the `visible` option from product variant
/// https://tppr.me/4DJJs - default value is false
const kNotStrictVisibleVariant = true;
