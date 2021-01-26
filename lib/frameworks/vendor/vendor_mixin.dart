import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show CartModel, Product, Store, VendorShippingMethodModel, AppModel;
import 'checkout/shipping_method_screen.dart';
import 'featured_vendors_layout.dart';
import 'store/categories_screen.dart';
import 'store_detail/store_detail_screen_from_config.dart';
import 'stores_map/map_screen.dart';
import 'vendor_info.dart';
import 'vendor_orders_screen.dart';

/// The mixin function for Vendor framework
mixin VendorMixin {
  void loadShippingMethods(
      BuildContext context, CartModel cartModel, bool beforehand) {
    Future.delayed(Duration.zero, () {
      var results = <String, Store>{};
      if (kVendorConfig['DisableVendorShipping'] == false) {
        final item = Provider.of<CartModel>(context, listen: false).item;
        item.values.toList().forEach((Product product) {
          if (product.store != null && product.store.id != null) {
            results[product.store.id.toString()] = product.store;
          } else {
            results['-1'] = null;
          }
        });
      } else {
        results['-1'] = null;
      }
      Provider.of<VendorShippingMethodModel>(context, listen: false)
          .getShippingMethods(
              cartModel: cartModel, stores: results.values.toList());
    });
  }

  Widget renderVendorInfo(Product product) => VendorInfo(product);

  Widget renderVendorOrder(BuildContext context) {
    return Card(
      color: Theme.of(context).backgroundColor,
      margin: const EdgeInsets.only(bottom: 2.0),
      elevation: 0,
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VendorOrdersScreen(),
            ),
          );
        },
        leading: Icon(
          Icons.shopping_cart,
          size: 24,
          color: Theme.of(context).accentColor,
        ),
        title: Text(
          S.of(context).shopOrders,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Theme.of(context).accentColor,
        ),
      ),
    );
  }

  Widget renderFeatureVendor(config) {
    return FeaturedVendorsLayout(
      config: config,
      key: config['key'] != null ? Key(config['key']) : null,
    );
  }

  Widget renderShippingMethods(BuildContext context,
      {Function onBack, Function onNext}) {
    return ShippingMethods(onBack: onBack, onNext: onNext);
  }

  Widget renderVendorCategoriesScreen(data) {
    return VendorCategoriesScreen(
      layout: data['categoryLayout'],
      categories: data['categories'],
      images: data['images'],
      showChat: data['showChat'],
    );
  }

  Widget renderMapScreen() => MapScreen();

  Widget renderShippingMethodInfo(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final currencyRate =
        Provider.of<AppModel>(context, listen: false).currencyRate;

    if (kPaymentConfig['EnableShipping']) {
      return Column(
        children: <Widget>[
          for (var i = 0; i < cartModel.selectedShippingMethods.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${cartModel.selectedShippingMethods[i].shippingMethods[0].title}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      if (cartModel.selectedShippingMethods[i].store != null &&
                          cartModel.selectedShippingMethods[i].store.name != '')
                        Text(
                          '${cartModel.selectedShippingMethods[i].store.name}',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                Theme.of(context).accentColor.withOpacity(0.6),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    Tools.getCurrencyFormatted(
                        cartModel
                            .selectedShippingMethods[i].shippingMethods[0].cost,
                        currencyRate,
                        currency: cartModel.currency),
                    style: Theme.of(context).textTheme.subtitle1.copyWith(
                          fontSize: 14,
                          color: Theme.of(context).accentColor,
                        ),
                  )
                ],
              ),
            )
        ],
      );
    } else {
      return Container();
    }
  }

  Widget renderVendorScreen(String storeID) =>
      StoreDetailScreenFromConfig(storeId: storeID);
}
