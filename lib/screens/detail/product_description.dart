import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../common/config.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show Product;
import '../../widgets/common/expansion_info.dart';
import 'additional_information.dart';
import 'review.dart';

class ProductDescription extends StatelessWidget {
  final Product product;

  ProductDescription(this.product);

  bool get enableBrand => kProductDetail['showBrand'] ?? false;

  bool get enableReview => kProductDetail['enableReview'] ?? false;

  String get brand {
    final brands = product.infors.where((element) => element.name == 'Brand');
    if (brands?.isEmpty ?? true) return 'Unknown';
    return brands.first.options?.first ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 15),
        if (product.description != null && product.description.isNotEmpty)
          ExpansionInfo(
            title: S.of(context).description,
            children: <Widget>[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: HtmlWidget(
                  product.description.replaceAll('src="//', 'src="https://'),
                  webView: true,
                  textStyle: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(
                        color: Theme.of(context).accentColor,
                        height: 1.5,
                      )
                      .apply(
                        fontSizeFactor: 1.1,
                      ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            expand: true,
          ),
        if (enableBrand) ...[
          buildBrand(context),
        ],
        if (enableReview)
          ExpansionInfo(
            title: S.of(context).readReviews,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Reviews(
                  product.id,
                  allowRating: false,
                ),
              ),
            ],
          ),
        if (product.infors?.isNotEmpty ?? false)
          ExpansionInfo(
            expand: true,
            title: S.of(context).additionalInformation,
            children: <Widget>[
              AdditionalInformation(
                listInfo: product.infors,
              ),
            ],
          ),
      ],
    );
  }

  Widget buildBrand(context) {
    if (brand == null || brand == 'Unknown') {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            S.of(context).brand,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Text(
            brand ?? 'Unknown',
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
