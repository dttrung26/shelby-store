import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../../common/constants.dart';
import '../../services/index.dart';

class StoreModel with ChangeNotifier {
  final Services _service = Services();
  final String langCode;

  StoreModel({
    this.langCode = '',
  });

  List<Store> _stores;
  List<Store> lstFeaturedStores;
  bool isLoading = true;
  String message;
  int _currentPage = 0;
  String _currentNameSearch = '';
  bool _isEnd = false;

  bool get isEnd => _isEnd;

  List<Store> get stores => _stores;

  Future<List<Store>> getFeaturedStores() async {
    if (lstFeaturedStores != null) {
      if (lstFeaturedStores.isNotEmpty) {
        return lstFeaturedStores;
      }
    }
    try {
      var list = await _service.api.getFeaturedStores();
      lstFeaturedStores = list;
    } catch (err) {
      printLog('err $err');
    }
    return lstFeaturedStores;
  }

  Future<List<Store>> getListStore({lang, page}) async {
    var stores = await _service.api.searchStores(page: page);
    var lstStores = <Store>[];
    stores.forEach((store) {
      if (store.long != null && store.lat != null) {
        lstStores.add(store);
      }
    });
    return lstStores;
  }

  // Can use search
  Future<void> loadStore({String name = '', Function onFinish}) async {
    isLoading = true;
    notifyListeners();
    if (_currentNameSearch != name) {
      _currentPage = 1;
      _currentNameSearch = name;
      _stores = null;
    } else {
      _currentPage++;
    }

    var data = await _service.api.searchStores(
      keyword: name,
      page: _currentPage,
    );

    if (data?.isEmpty ?? true) {
      if (onFinish != null) {
        onFinish();
      }
      _isEnd = true;
      isLoading = false;
      _stores ??= [];
      notifyListeners();
      return;
    }

    _stores = [...stores ?? [], ...data];
    isLoading = false;
    if (onFinish != null) {
      onFinish();
    }
    notifyListeners();
  }
}

class Store {
  int id;
  String name;
  String email;
  double rating;
  String image;
  String address;
  String banner;
  String phone;
  String website;
  bool isFeatured;
  double lat;
  double long;
  Map<String, String> socials;

  Store.fromDokanJson(Map<String, dynamic> parsedJson) {
    id = parsedJson['id'];

    if (parsedJson['first_name'] != null && parsedJson['last_name'] != null) {
      name = '${parsedJson["first_name"]} ${parsedJson["last_name"]}';
    }

    if (parsedJson['name'] != null) {
      name = parsedJson['name'];
    }
    if (parsedJson['shop_name'] != null) {
      name = parsedJson['shop_name'];
    }
    if (parsedJson['store_name'] != null) {
      name = parsedJson['store_name'];
    }
    email = parsedJson['email'] ?? '';
    rating = 0.0;
    if (parsedJson['rating'] != null) {
      if (parsedJson['rating']['count'] != null) {
        rating = double.parse("${parsedJson["rating"]["count"]}");
      }
    }

    //For dokan map demo
//    Random rand = Random();
//
//    String tempLat = '10.${rand.nextInt(100) + 10}00873536';
//    String tempLong = '106.${rand.nextInt(100) + 10}3620042';

//    lat = double.parse(tempLat);
//    long = double.parse(tempLong);

    final String stringLocation = parsedJson['location'];

    if (stringLocation?.isNotEmpty ?? false) {
      final arrLocation = stringLocation?.split(',');
      lat = double.parse(arrLocation[0]);
      long = double.parse(arrLocation[1]);
    }

    if (parsedJson['gravatar'] != null) {
      image = parsedJson['gravatar'] is String ? parsedJson['gravatar'] : null;
    }
    address =
        parsedJson['address'] is Map ? parsedJson['address']['street_1'] : '';
    banner = isNotBlank(parsedJson['banner']) ? parsedJson['banner'] : null;
    phone = parsedJson['phone'];
    isFeatured = parsedJson['featured'] ?? false;
    try {
      if (parsedJson['social'] is Map) {
        Map social = parsedJson['social'];
        final key = social.keys.firstWhere(
            (o) =>
                parsedJson['social'][o] is String &&
                isNotBlank(parsedJson['social'][o]),
            orElse: () => null);
        if (key != null) {
          website = parsedJson['social'][key];
        }
      }
    } catch (e) {
      printLog(e.toString());
    }
  }

  Store.fromWCFMJson(Map<String, dynamic> parsedJson) {
    id = int.parse("${parsedJson["vendor_id"]}");
    name = parsedJson['vendor_shop_name'];
    email = parsedJson['vendor_email'];
    rating = double.parse((parsedJson['store_rating'] != null &&
            parsedJson['store_rating'].toString().isNotEmpty)
        ? parsedJson['store_rating'].toString()
        : '0.0');
    address = parsedJson['vendor_address'];
    if (parsedJson['settings'] != null && parsedJson['settings'] is Map) {
      image = parsedJson['settings']['gravatar'].toString().isNotEmpty &&
              parsedJson['settings']['gravatar'].toString().contains('http')
          ? parsedJson['settings']['gravatar']
          : null;
      banner = parsedJson['settings']['mobile_banner'].toString().isNotEmpty &&
              parsedJson['settings']['mobile_banner']
                  .toString()
                  .contains('http')
          ? parsedJson['settings']['mobile_banner']
          : null;
      if (isBlank(banner)) {
        banner = parsedJson['settings']['banner'].toString().isNotEmpty &&
                parsedJson['settings']['banner'].toString().contains('http')
            ? parsedJson['settings']['banner']
            : null;
      }
      if (isBlank(banner)) {
        banner = parsedJson['mobile_banner'] ??
            parsedJson['vendor_banner'] ??
            parsedJson['vendor_list_banner'];
      }
      if (isBlank(image)) {
        image = parsedJson['vendor_shop_logo'];
      }
      try {
        lat = double.parse(parsedJson['settings']['store_lat']);
        long = double.parse(parsedJson['settings']['store_lng']);
      } catch (e) {
        lat = null;
        long = null;
      }

      phone = '';
      if (parsedJson['settings']['phone'] is List) {
        if (parsedJson['settings']['phone'].isNotEmpty) {
          phone = parsedJson['settings']['phone'][0];
        }
      }
      if (parsedJson['settings']['phone'] is String) {
        phone = parsedJson['settings']['phone'];
      }
      final _socials = parsedJson['settings']['social'];
      if (_socials != null && _socials is Map) {
        socials = Map<String, String>.from(_socials);
        if (socials['fb'] != null) {
          socials['facebook'] = "${socials["fb"]}";
          socials.remove('fb');
        }
      }
    } else {
      banner = parsedJson['mobile_banner'] ??
          parsedJson['vendor_shop_logo'] ??
          parsedJson['vendor_banner'] ??
          parsedJson['vendor_list_banner'];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'rating': rating,
      'image': image,
      'address': address,
      'banner': banner,
      'phone': phone,
      'website': website
    };
  }

  Store.fromLocalJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      name = json['name'];
      email = json['email'];
      rating = json['rating'];
      image = json['image'];
      address = json['address'];
      banner = json['banner'];
      phone = json['phone'];
      website = json['website'];
    } catch (e, trace) {
      printLog(e.toString());
      printLog(trace.toString());
    }
  }
}
