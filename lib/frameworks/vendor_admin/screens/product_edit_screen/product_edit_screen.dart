import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/config.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/index.dart';
import '../../colors_config/theme.dart';
import '../../common_widgets/index.dart';
import '../../models/authentication_model.dart';
import '../../models/category_model.dart';
import 'product_edit_screen_model.dart';
import 'widgets/categories_widget.dart';
import 'widgets/choose_image_widget/choose_image_widget.dart';
import 'widgets/gallery_images/gallery_images.dart';
import 'widgets/gallery_images/gallery_images_model.dart';

class VendorAdminProductEditScreen extends StatelessWidget {
  final Product product;

  const VendorAdminProductEditScreen({Key key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user =
        Provider.of<VendorAdminAuthenticationModel>(context, listen: false)
            .user;
    final map =
        Provider.of<VendorAdminCategoryModel>(context, listen: false).map;
    Map<String, dynamic> defaultCurrency = kAdvanceConfig['DefaultCurrency'];

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChooseImageWidgetModel>(
          create: (_) => ChooseImageWidgetModel(user),
        ),
        ChangeNotifierProvider<VendorAdminGalleryImagesModel>(
          create: (_) => VendorAdminGalleryImagesModel(product, user),
        ),
        ChangeNotifierProvider<VendorAdminProductEditScreenModel>(
          create: (_) => VendorAdminProductEditScreenModel(product, user, map),
        ),
      ],
      child: Consumer<VendorAdminProductEditScreenModel>(
        builder: (_, model, __) => Stack(
          children: [
            Scaffold(
              backgroundColor: Theme.of(context).backgroundColor,
              appBar: CupertinoNavigationBar(
                backgroundColor: Theme.of(context).primaryColorLight,
                middle: Text(
                  '${S.of(context).edit}${product.name}',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                trailing: InkWell(
                  onTap: () => model.updateProduct(product),
                  child: Text(
                    S.of(context).update,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    VendorAdminProductCategoriesWidget(
                      product: product,
                    ),
                    EditProductInfoWidget(
                      controller: model.productNameController,
                      label: S.of(context).name,
                    ),
                    EditProductInfoWidget(
                      controller: model.regularPriceController,
                      label: S.of(context).regularPrice,
                      keyboardType: TextInputType.number,
                      prefixIcon: Container(
                          width: 1,
                          height: 1,
                          padding:
                              const EdgeInsets.only(bottom: 4.0, right: 5.0),
                          margin: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          decoration: const BoxDecoration(
                            border: Border(
                                right:
                                    BorderSide(color: Colors.grey, width: 0.5)),
                          ),
                          child: Center(
                              child: Text(
                            defaultCurrency['symbol'],
                            style: Theme.of(context).textTheme.bodyText1,
                          ))),
                    ),
                    EditProductInfoWidget(
                      controller: model.salePriceController,
                      label: S.of(context).salePrice,
                      keyboardType: TextInputType.number,
                      prefixIcon: Container(
                          width: 1,
                          height: 1,
                          padding:
                              const EdgeInsets.only(bottom: 4.0, right: 5.0),
                          margin: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          decoration: const BoxDecoration(
                            border: Border(
                                right:
                                    BorderSide(color: Colors.grey, width: 0.5)),
                          ),
                          child: Center(
                              child: Text(
                            defaultCurrency['symbol'],
                            style: Theme.of(context).textTheme.bodyText1,
                          ))),
                    ),
                    EditProductInfoWidget(
                      controller: model.SKUController,
                      label: S.of(context).sku,
                    ),
                    if (model.product.manageStock)
                      EditProductInfoWidget(
                        controller: model.stockQuantity,
                        label: S.of(context).stockQuantity,
                        keyboardType: TextInputType.number,
                      ),
                    Row(
                      children: [
                        Checkbox(
                          value: model.product.manageStock,
                          onChanged: (val) => model.updateManageStock(),
                          activeColor: ColorsConfig.activeCheckedBoxColor,
                        ),
                        Text(S.of(context).manageStock),
                      ],
                    ),
                    const SizedBox(height: 10),
                    //SaleDatePickers(),
                    ChooseImageWidget(),
                    VendorAdminProductGalleryImages(),
                    EditProductInfoWidget(
                      controller: model.shortDescription,
                      label: S.of(context).shortDescription,
                    ),
                    EditProductInfoWidget(
                      controller: model.description,
                      label: S.of(context).description,
                      isMultiline: true,
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            if (model.state == VendorAdminProductEditScreenModelState.loading)
              Container(
                width: size.width,
                height: size.height,
                color: Colors.grey.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
