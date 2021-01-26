import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';

import '../../../../models/entities/category.dart';
import '../../../../models/entities/product.dart';
import '../../../../models/entities/user.dart';
import '../../services/vendor_admin.dart';

enum VendorAdminProductEditScreenModelState { loading, loaded }

class VendorAdminProductEditScreenModel extends ChangeNotifier {
  /// Service
  final _services = VendorAdminApi();

  /// State
  var state = VendorAdminProductEditScreenModelState.loading;

  /// Your Other Variables Go Here
  Product product;
  User user;
  var featuredImage;
  List<dynamic> galleryImages = [];
  List<Category> categories = [];
  Map<String, Map<String, dynamic>> map = {};
  List<Category> currentCategories = [];
  List<Category> searchedCategories = [];
  List<List<Category>> navigatedCategories = [];
  int currentPageView = 0;
  List<String> selectedCategoryIds = [];

  final FocusNode focusNode = FocusNode();
  final PageController pageController = PageController();
  final searchController = TextEditingController();
  final productNameController = TextEditingController();
  final regularPriceController = TextEditingController();
  final salePriceController = TextEditingController();
  final SKUController = TextEditingController();
  final stockQuantity = TextEditingController();
  final shortDescription = TextEditingController();
  final description = TextEditingController();

  /// Constructor
  VendorAdminProductEditScreenModel(this.product, this.user, this.map) {
    _setControllersText();
    getCategories();
  }

  /// Update state
  void _updateState(state) {
    this.state = state;
    notifyListeners();
  }

  /// Your Defined Functions Go Here
  void _setControllersText() {
    productNameController.text = product.name ?? '';
    regularPriceController.text = product.regularPrice ?? '';
    salePriceController.text = product.salePrice ?? '';
    SKUController.text = product.sku ?? '';
    stockQuantity.text = product.stockQuantity?.toString() ?? '0';
    featuredImage = product.vendorAdminImageFeature ?? '';
    galleryImages.addAll(product.images);
    shortDescription.text = product.shortDescription;
    description.text = product.description;
    selectedCategoryIds.addAll(product.categoryIds);
    _updateState(VendorAdminProductEditScreenModelState.loaded);
  }

  Future<void> getCategories() async {
    for (var category in map['0']['categories']) {
      if (category is Category) {
        categories.add(category);
      } else {
        categories.add(Category.fromJson(category));
      }
    }
    navigatedCategories.add(categories);
    _updateState(VendorAdminProductEditScreenModelState.loaded);
  }

  /// Image parameter will be either PickedFile or String(url)
  void updateFeaturedImage(dynamic image) {
    featuredImage = image;
    _updateState(VendorAdminProductEditScreenModelState.loaded);
  }

  /// Image parameter will be either PickedFile or List or String(url) or Asset(from multi picker)
  void updateGalleryImages(dynamic image) {
    if (image is List) {
      for (var item in image) {
        galleryImages.add(item);
      }
    } else {
      galleryImages.add(image);
    }
    _updateState(VendorAdminProductEditScreenModelState.loaded);
  }

  void removeImageFromGallery(dynamic image) {
    galleryImages.remove(image);
    _updateState(VendorAdminProductEditScreenModelState.loaded);
  }

  void updateSelectedCategories(String id) {
    if (selectedCategoryIds.contains(id)) {
      selectedCategoryIds.remove(id);
    } else {
      selectedCategoryIds.add(id);
    }
    _updateState(VendorAdminProductEditScreenModelState.loaded);
  }

  void updateCategories(List<Category> categories) {
    this.categories = categories;
    _updateState(VendorAdminProductEditScreenModelState.loaded);
  }

  Future<void> updateProduct(Product p) async {
    _updateState(VendorAdminProductEditScreenModelState.loading);
    product.name = productNameController.text;
    product.regularPrice = regularPriceController.text;
    product.salePrice = salePriceController.text;
    product.sku = SKUController.text;
    product.stockQuantity = int.parse(stockQuantity.text);
    product.shortDescription = shortDescription.text;
    product.description = description.text;
    product.categoryIds = selectedCategoryIds;
    product = await _services.updateProduct(
        cookie: user.cookie,
        product: product,
        images: galleryImages,
        featuredImage: featuredImage);
    galleryImages.clear();
    galleryImages.addAll(product.images);
    featuredImage = product.vendorAdminImageFeature;
    p.vendorAdminImageFeature = product.vendorAdminImageFeature;
    p.images = product.images;
    _updateState(VendorAdminProductEditScreenModelState.loaded);
  }

  /// Vendor Product Category Edit Screen
  void searchCategory() {
    EasyDebounce.cancel('searchCategory');
    if (searchController.text != '') {
      EasyDebounce.debounce('searchCategory', const Duration(milliseconds: 300),
          () async {
        searchedCategories = await _services.searchCategory(
            page: 1, name: searchController.text);
        notifyListeners();
      });
    } else {
      searchedCategories.clear();
      notifyListeners();
    }
  }

  void requestFocus() {
    focusNode.requestFocus();
    searchedCategories.clear();
  }

  void updatePage(Category category) async {
    focusNode.unfocus();
    await loadSubCategories(category.id);
    if (navigatedCategories.length > currentPageView + 1) {
      currentCategories.add(category);
      notifyListeners();
      currentPageView++;
      await pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  void goBack() {
    if (currentPageView > 0) {
      currentPageView--;
      pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      navigatedCategories.removeLast();
      currentCategories.removeLast();
      notifyListeners();
    }
  }

  Future<void> loadSubCategories(String categoryId) async {
    var list = <Category>[];
    map[categoryId]['categories'].forEach((category) {
      list.add(Category.fromJson(category));
    });
    if (list.isNotEmpty) {
      navigatedCategories.add(list);
    }
  }

  void requestUnFocus() {
    focusNode.unfocus();
    searchedCategories.clear();
    searchController.clear();
  }

  void updateManageStock() {
    product.manageStock = !product.manageStock;
    notifyListeners();
  }
}
