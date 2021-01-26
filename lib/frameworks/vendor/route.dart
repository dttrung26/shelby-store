import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../../screens/chat/conversations.dart';
import 'products/create_product_screen.dart';
import 'products/product_sell_screen.dart';
import 'store/categories_screen.dart';
import 'store_detail/store_detail_screen.dart';
import 'stores_map/map_screen.dart';

class VendorRoute {
  static Map<String, WidgetBuilder> getAll() {
    return {
      RouteList.vendorCategory: (context) => VendorCategoriesScreen(),
      RouteList.createProduct: (context) => CreateProductScreen(),
      RouteList.productSell: (context) => ProductSellScreen(),
      RouteList.listChat: (_) => ListChatScreen(),
      RouteList.map: (_) => MapScreen(),
    };
  }

  static Map<String, WidgetBuilder> getRoutesWithSettings(
      RouteSettings settings) {
    return {
      RouteList.storeDetail: (context) {
        final StoreDetailArgument arguments = settings.arguments;
        return StoreDetailScreen(store: arguments.store);
      }
    };
  }
}
