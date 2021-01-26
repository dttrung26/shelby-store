import 'package:flutter/material.dart';

import '../../common/config.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show Product, ProductVariation;

class SaleProgressBar extends StatelessWidget {
  final Product product;
  final ProductVariation productVariation;
  final double width;

  const SaleProgressBar({
    Key key,
    this.product,
    this.width,
    this.productVariation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// If empty product we don't need to show
    if (product.price == '0.0' || product.price == null) {
      return Container();
    }

    var almostSoldOut = false;
    final stockQuantity =
        productVariation?.stockQuantity ?? product.stockQuantity;
    final inStock = productVariation?.inStock ?? product.inStock;

    var progress = 0.9;

    var progressBackground = kSaleOffProduct['Color'] != null
        ? HexColor(kSaleOffProduct['Color']).withOpacity(0.6)
        : Theme.of(context).primaryColor.withOpacity(0.6);
    var progressColor = kSaleOffProduct['Color'] != null
        ? HexColor(kSaleOffProduct['Color'])
        : Theme.of(context).primaryColor;

    try {
      progress = product.totalSales / (product.totalSales + stockQuantity);
    } catch (_) {
      /// In case [stockQuantity] is null.
      /// Display total sales with 90 percent progress by default.
      progress = 0.9;
    }

    /// Apply 'Almost sold out' for product has less than 10% products in stock.
    if (inStock && stockQuantity != null && progress >= 0.5) {
      almostSoldOut = true;
    }

    var _progressText = '';

    /// In stock. Display total sales.
    if (inStock || (stockQuantity != null && stockQuantity > 0)) {
      _progressText = '${S.of(context).sold(product.totalSales)}';
    }

    /// Almost Sold Out.
    if (almostSoldOut) {
      _progressText = '${S.of(context).almostSoldOut}';
    }

    /// Out of stock.
    if ((!inStock) || (stockQuantity != null && stockQuantity == 0)) {
      _progressText = '${S.of(context).outOfStock}';
    }

    return Container(
      width: width - 22,
      height: 20.0,
      margin: const EdgeInsets.only(bottom: 8.0),
      constraints: const BoxConstraints(maxWidth: 160),
      child: Stack(
        children: [
          Positioned(
            top: 6,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 20.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: LinearProgressIndicator(
                  minHeight: 20.0,
                  value: progress,
                  backgroundColor: progressBackground,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressColor,
                  ),
                ),
              ),
            ),
          ),
          if (almostSoldOut)
            const Positioned(
              left: -3,
              top: 0,
              bottom: 0,
              child: _FireIcon(),
            ),
          Positioned(
            top: 6,
            bottom: 2,
            left: 0,
            right: 0,
            child: Container(
              height: 10.0,
              child: Center(
                child: Text(
                  _progressText,
                  style: Theme.of(context).textTheme.caption.apply(
                        color: Colors.white,
                        fontSizeFactor: 0.8,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FireIcon extends StatelessWidget {
  const _FireIcon({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24.0,
      width: 24.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(
            child: Icon(
              Icons.local_fire_department_rounded,
              size: 24.0,
              color: Colors.redAccent,
            ),
          ),
          const Positioned.fill(
            child: Icon(
              Icons.local_fire_department,
              size: 18.0,
              color: Colors.orangeAccent,
            ),
          ),
        ],
      ),
    );
  }
}
