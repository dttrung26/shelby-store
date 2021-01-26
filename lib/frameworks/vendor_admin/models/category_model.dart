import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/entities/category.dart';
import '../services/vendor_admin.dart';

enum VendorAdminCategoryModelState { loading, loaded }

class VendorAdminCategoryModel extends ChangeNotifier {
  /// Service
  final _services = VendorAdminApi();

  /// State
  var state = VendorAdminCategoryModelState.loading;

  /// Your Other Variables Go Here
  Map<String, Map<String, dynamic>> map = {};
  List<Category> categories = [];
  final int _page = 1;
  final int _perPage = 100;
  SharedPreferences _sharedPreferences;

  /// Constructor
  VendorAdminCategoryModel() {
    initLocalStorage().then((value) => getAllCategories());
  }

  /// Update state
  // void _updateState(state) {
  //   this.state = state;
  //   notifyListeners();
  // }

  /// Your Defined Functions Go Here

  Future<void> initLocalStorage() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void> getAllCategories() async {
    var tmp = _sharedPreferences.getString('vendorCategories');
    if (tmp != null) {
      var s = json.decode(tmp);

      s.forEach((key, catMap) {
        map[key] = {};
        catMap.forEach((catKeyName, value) {
          map[key][catKeyName] = value;
        });
      });

      return;
    }

    getCategories('0', '');
  }

  void getCategories(String categoryId, String name) {
    _services
        .getVendorAdminCategoriesByPage(
            categoryId: categoryId, page: _page, perPage: _perPage)
        .then((categoryList) {
      if (map[categoryId] == null) {
        map[categoryId] = {};
        map[categoryId]['name'] = '';
        map[categoryId]['categories'] = [];
      }
      map[categoryId]['name'] = name;
      map[categoryId]['categories'] = categoryList;
      var s = json.encode(map);
      _sharedPreferences.setString('vendorCategories', s);
      if (categoryList.isNotEmpty) {
        for (var category in categoryList) {
          getCategories(category.id, category.name ?? '');
        }
      }
    });
  }
}
