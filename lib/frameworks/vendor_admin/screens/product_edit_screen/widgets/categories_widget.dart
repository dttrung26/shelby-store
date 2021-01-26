import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../generated/l10n.dart';
import '../../../../../models/entities/product.dart';
import '../product_edit_category_screen.dart';
import '../product_edit_screen_model.dart';

class VendorAdminProductCategoriesWidget extends StatelessWidget {
  final Product product;
  const VendorAdminProductCategoriesWidget({Key key, this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<VendorAdminProductEditScreenModel>(
      builder: (context, model, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).categories,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => ChangeNotifierProvider.value(
                    value: model,
                    child: VendorAdminProductEditCategoryScreen(
                      updateCategories: model.updateCategories,
                      updateSelectedCategoryIds: model.updateSelectedCategories,
                    ),
                  ),
                ),
              ),
              child: Center(
                child: Wrap(
                  children: List.generate(
                    model.selectedCategoryIds.length > 5
                        ? 6
                        : model.selectedCategoryIds.length + 1,
                    (index) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                      margin: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: (index == 5 ||
                              index == model.selectedCategoryIds.length)
                          ? Text(
                              '${S.of(context).more}',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 12.0,
                              ),
                            )
                          : Text(
                              model.map[model.selectedCategoryIds[index]]
                                      ['name']
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
