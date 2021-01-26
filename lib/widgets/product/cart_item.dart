import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../models/entities/index.dart' show AddonsOption;
import '../../models/index.dart' show AppModel, Product, ProductVariation;
import '../../services/index.dart';
import 'product_variant.dart';

class ShoppingCartRow extends StatelessWidget {
  ShoppingCartRow({
    @required this.product,
    @required this.quantity,
    this.onRemove,
    this.onChangeQuantity,
    this.variation,
    this.options,
    this.addonsOptions,
  });

  final Product product;
  final List<AddonsOption> addonsOptions;
  final ProductVariation variation;
  final Map<String, dynamic> options;
  final int quantity;
  final Function onChangeQuantity;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    var currency = Provider.of<AppModel>(context).currency;
    final currencyRate = Provider.of<AppModel>(context).currencyRate;

    final price = Services().widget.getPriceItemInCart(
        product, variation, currencyRate, currency,
        selectedOptions: addonsOptions);
    final imageFeature = variation != null && variation.imageFeature != null
        ? variation.imageFeature
        : product.imageFeature;
    var maxQuantity = kCartDetail['maxAllowQuantity'] ?? 100;
    var totalQuantity = variation != null
        ? (variation.stockQuantity ?? maxQuantity)
        : (product.stockQuantity ?? maxQuantity);
    var limitQuantity =
        totalQuantity > maxQuantity ? maxQuantity : totalQuantity;

    var theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Row(
              key: ValueKey(product.id),
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (onRemove != null)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: onRemove,
                  ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: constraints.maxWidth * 0.25,
                        height: constraints.maxWidth * 0.3,
                        child: Tools.image(url: imageFeature),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: TextStyle(
                                  color: theme.accentColor,
                                ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 7),
                              Text(
                                price,
                                style: TextStyle(
                                    color: theme.accentColor, fontSize: 14),
                              ),
                              const SizedBox(height: 10),
                              if (variation != null || options != null)
                                Services()
                                    .widget
                                    .renderVariantCartItem(variation, options),
                              if (addonsOptions?.isNotEmpty ?? false)
                                Services().widget.renderAddonsOptionsCartItem(
                                    context, addonsOptions),
                              if (kProductDetail['showStockQuantity'] ?? true)
                                QuantitySelection(
                                  enabled: onChangeQuantity != null,
                                  width: 60,
                                  height: 32,
                                  color: Theme.of(context).accentColor,
                                  limitSelectQuantity: limitQuantity,
                                  value: quantity,
                                  onChanged: onChangeQuantity,
                                  useNewDesign: false,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16.0),
              ],
            ),
            const SizedBox(height: 10.0),
            const Divider(color: kGrey200, height: 1),
            const SizedBox(height: 10.0),
          ],
        );
      },
    );
  }
}
