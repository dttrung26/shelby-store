import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/category_model.dart';
import '../../../models/product_model.dart';
import '../../../models/user_model.dart';
import 'widgets/select_image.dart';
import 'widgets/select_info.dart';

class CreateProductScreen extends StatefulWidget {
  @override
  _StateCreateProduct createState() => _StateCreateProduct();
}

class _StateCreateProduct extends State<CreateProductScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, String> infoCategory = {};
  List<String> types = ['simple', 'grouped', 'external', 'variable'];
  List<File> fileImages = [];
  List<String> galleryImages = [];
  List<String> networkImages = [];

  TextEditingController name;
  TextEditingController description;
  TextEditingController regularPrice;
  TextEditingController salePrice;

  String categorySelected;
  String typeSelected;
  bool isLoading = false;
  bool loadingImage = false;

  void _createProduct() async {
    if (name.text.isEmpty) {
      Tools.showSnackBar(
          _scaffoldKey.currentState, 'Please enter the product name');
      return;
    }

    if (infoCategory.containsKey(categorySelected) == false) {
      Tools.showSnackBar(_scaffoldKey.currentState, 'Please choose category');
      return;
    }

    setState(() {
      isLoading = true;
      galleryImages = [...galleryImages, ...networkImages];
    });

    final userModel = Provider.of<UserModel>(context, listen: false);
    await Provider.of<ProductModel>(context, listen: false)
        .createProduct(
      galleryImages,
      fileImages,
      userModel.user.cookie,
      name.text,
      typeSelected,
      infoCategory['$categorySelected'],
      salePrice.text.isNotEmpty ? double.parse(salePrice.text) : null,
      regularPrice.text.isNotEmpty ? double.parse(regularPrice.text) : 0.0,
      description.text,
    )
        .then((onValue) {
      Navigator.pop(context);
    }).catchError((onError) {
      setState(() {
        isLoading = false;
      });
      Tools.showSnackBar(_scaffoldKey.currentState, onError.toString());
    });
  }

  Widget _renderCategoryOption() {
    var list_categorys = Provider.of<CategoryModel>(context, listen: false);
    return ListenableProvider.value(
      value: list_categorys,
      child: Consumer<CategoryModel>(
        builder: (context, value, child) {
          var categorys = <String>[];

          if (value.isLoading == false) {
            if (value?.categories?.isNotEmpty ?? false) {
              infoCategory.clear();

              value.categories.forEach((_category) {
                categorys.add(_category.name);
                infoCategory['${_category.name}'] = _category.id;
              });
            }
          }
          return SelectInfo(
            valueSelected: categorySelected,
            data: categorys,
            title: S.of(context).categories,
            hint: 'Choose category',
            onChanged: (_category) {
              setState(() {
                categorySelected = _category;
              });
            },
          );
        },
      ),
    );
  }

  Widget _renderButtonPostProduct() {
    return GestureDetector(
      onTap: _createProduct,
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(top: 20, bottom: 10),
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 20,
          ),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [const BoxShadow(color: Colors.grey, blurRadius: 10)]),
          child: Text(
            S.of(context).postProduct,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderPrice() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                S.of(context).regularPrice,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    width: 1.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                child: TextField(
                  controller: regularPrice,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 50),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                S.of(context).salePrice,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        width: 1.0, color: Theme.of(context).primaryColor)),
                child: TextField(
                  controller: salePrice,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _renderBody() {
    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            loadingImage
                ? S.of(context).waitForLoad
                : S.of(context).waitForPost,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          SpinKitFadingCircle(color: Theme.of(context).primaryColor, size: 50.0)
        ],
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 30),
            Text(
              S.of(context).productName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      width: 1.0, color: Theme.of(context).primaryColor),
                  color: Theme.of(context).primaryColorLight),
              child: TextField(
                controller: name,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
            const SizedBox(height: 10),
            _renderCategoryOption(),
            const SizedBox(
              height: 5,
            ),
            SelectInfo(
              valueSelected: typeSelected,
              data: types,
              title: S.of(context).productType,
              hint: 'Choose type',
              onChanged: (_type) {
                setState(() {
                  typeSelected = _type;
                });
              },
            ),
            const SizedBox(
              height: 15,
            ),
            _renderPrice(),
            const SizedBox(
              height: 20,
            ),
            SelectImage(
              fileImages: fileImages,
              networkImages: networkImages,
              onSelect: (List<File> _fileImages, List<String> _networkImages) {
                setState(() {
                  fileImages = _fileImages;
                  networkImages = _networkImages;
                });
              },
              isLoading: (_isLoading) {
                setState(() {
                  loadingImage = _isLoading;
                  isLoading = _isLoading;
                });
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  S.of(context).description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      width: 1.0,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  child: TextField(
                    controller: description,
                    decoration: const InputDecoration(border: InputBorder.none),
                    maxLines: 5,
                  ),
                ),
              ],
            ),
            _renderButtonPostProduct()
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    name = TextEditingController();
    description = TextEditingController();
    regularPrice = TextEditingController();
    salePrice = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          S.of(context).createProduct,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: _renderBody(),
    );
  }
}
