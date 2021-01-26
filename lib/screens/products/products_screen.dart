import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show
        AppModel,
        Category,
        CategoryModel,
        FilterAttributeModel,
        Product,
        ProductModel,
        UserModel;
import '../../services/index.dart';
import '../../widgets/asymmetric/asymmetric_view.dart';
import '../../widgets/backdrop/backdrop.dart';
import '../../widgets/backdrop/backdrop_menu.dart';
import '../../widgets/common/countdown_timer.dart';
import '../../widgets/product/product_bottom_sheet.dart';
import '../../widgets/product/product_list.dart';
import 'products_backdrop.dart';

class ProductsScreen extends StatefulWidget {
  final List<Product> products;
  final String categoryId;
  final String tagId;
  final Map<String, dynamic> config;
  final bool onSale;
  final bool showCountdown;
  final Duration countdownDuration;
  final String title;
  final String listingLocation;

  ProductsScreen({
    this.products,
    this.categoryId,
    this.config,
    this.tagId,
    this.onSale,
    this.showCountdown = false,
    this.countdownDuration = Duration.zero,
    this.title,
    this.listingLocation,
  });

  @override
  State<StatefulWidget> createState() {
    return ProductsPageState();
  }
}

class ProductsPageState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  String newTagId;
  String newCategoryId;
  String newListingLocationId;
  double minPrice;
  double maxPrice;
  String orderBy;
  String orDer;
  String attribute;

//  int attributeTerm;
  bool featured;
  bool onSale;

  bool isFiltering = false;
  List<Product> products = [];
  String errMsg;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    setState(() {
      newCategoryId = widget.categoryId ?? '-1';
      newTagId = widget.tagId;
      onSale = widget.onSale;
      newListingLocationId = widget.listingLocation;
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: 1.0,
    );

    /// only request to server if there is empty config params
    /// If there is config, load the products one
    onRefresh(false);
  }

  void onFilter(
      {minPrice,
      maxPrice,
      categoryId,
      tagId,
      attribute,
      currentSelectedTerms,
      listingLocationId}) {
    _controller.forward();

    final productModel = Provider.of<ProductModel>(context, listen: false);
    final filterAttr =
        Provider.of<FilterAttributeModel>(context, listen: false);
    newCategoryId = categoryId;
    newTagId = tagId;
    newListingLocationId = listingLocationId;
    this.minPrice = minPrice;
    this.maxPrice = maxPrice;
    if (attribute != null && !attribute.isEmpty) this.attribute = attribute;
    var terms = '';

    if (currentSelectedTerms != null) {
      for (var i = 0; i < currentSelectedTerms.length; i++) {
        if (currentSelectedTerms[i]) {
          terms += '${filterAttr.lstCurrentAttr[i].id},';
        }
      }
    }

    productModel.setProductsList([]);
    final _userId = Provider.of<UserModel>(context, listen: false).user?.id;
    productModel.getProductsList(
      categoryId: categoryId == -1 ? null : categoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      page: 1,
      lang: Provider.of<AppModel>(context, listen: false).langCode,
      orderBy: orderBy,
      order: orDer,
      featured: featured,
      onSale: onSale,
      tagId: tagId,
      attribute: attribute,
      attributeTerm: terms.isEmpty ? null : terms,
      userId: _userId,
      listingLocation: newListingLocationId,
    );
  }

  void onSort(order) {
    if (order == 'date') {
      featured = null;
      onSale = null;
    } else {
      featured = order == 'featured';
      onSale = order == 'on_sale';
    }

    final filterAttr =
        Provider.of<FilterAttributeModel>(context, listen: false);
    var terms = '';
    for (var i = 0; i < filterAttr.lstCurrentSelectedTerms.length; i++) {
      if (filterAttr.lstCurrentSelectedTerms[i]) {
        terms += '${filterAttr.lstCurrentAttr[i].id},';
      }
    }
    final _userId = Provider.of<UserModel>(context, listen: false).user?.id;
    Provider.of<ProductModel>(context, listen: false).getProductsList(
      categoryId: newCategoryId == '-1' ? null : newCategoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      lang: Provider.of<AppModel>(context, listen: false).langCode,
      page: 1,
      orderBy: 'date',
      order: 'desc',
      featured: featured,
      onSale: onSale,
      attribute: attribute,
      attributeTerm: terms,
      tagId: newTagId,
      userId: _userId,
      listingLocation: newListingLocationId,
    );
  }

  Future<void> onRefresh([loadingConfig = true]) async {
    _page = 1;

    /// Important:
    /// The config is determine to load category/tag from config
    /// Or load from Caching ProductsLayout
    if (widget.config == null) {
      final filterAttr =
          Provider.of<FilterAttributeModel>(context, listen: false);
      var terms = '';
      for (var i = 0; i < filterAttr.lstCurrentSelectedTerms.length; i++) {
        if (filterAttr.lstCurrentSelectedTerms[i]) {
          terms += '${filterAttr.lstCurrentAttr[i].id},';
        }
      }
      final _userId = Provider.of<UserModel>(context, listen: false).user?.id;
      await Provider.of<ProductModel>(context, listen: false).getProductsList(
        categoryId: newCategoryId == '-1' ? null : newCategoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        lang: Provider.of<AppModel>(context, listen: false).langCode,
        page: 1,
        orderBy: orderBy,
        order: orDer,
        attribute: attribute,
        attributeTerm: terms,
        tagId: newTagId,
        listingLocation: newListingLocationId,
        userId: _userId,
      );
      return;
    }

    /// Loading product from the config if it is exist
    if (loadingConfig) {
      try {
        var newProducts = await Services().api.fetchProductsLayout(
            config: widget.config,
            lang: Provider.of<AppModel>(context, listen: false).langCode);
        setState(() {
          products = newProducts;
        });
      } catch (err) {
        setState(() {
          errMsg = err;
        });
      }
    }
  }

  Widget renderCategoryAppbar() {
    final category = Provider.of<CategoryModel>(context);
    var parentCategory = newCategoryId;
    if (category.categories != null && category.categories.isNotEmpty) {
      parentCategory =
          getParentCategories(category.categories, parentCategory) ??
              parentCategory;
      final listSubCategory =
          getSubCategories(category.categories, parentCategory);

      if (listSubCategory.length < 2) return null;

      return ListenableProvider.value(
        value: category,
        child: Consumer<CategoryModel>(builder: (context, value, child) {
          if (value.isLoading) {
            return Center(child: kLoadingWidget(context));
          }

          if (value.categories != null) {
            var _renderListCategory = <Widget>[];
            _renderListCategory.add(const SizedBox(width: 10));

            _renderListCategory.add(
              _renderItemCategory(
                  categoryId: parentCategory,
                  categoryName: S.of(context).seeAll),
            );

            _renderListCategory.addAll([
              for (var category
                  in getSubCategories(value.categories, parentCategory))
                _renderItemCategory(
                  categoryId: category.id,
                  categoryName: category.name,
                )
            ]);

            return Container(
              color: Theme.of(context).primaryColor,
              height: 50,
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _renderListCategory,
                  ),
                ),
              ),
            );
          }

          return Container();
        }),
      );
    }
    return null;
  }

  List<Category> getSubCategories(categories, id) {
    return categories.where((o) => o.parent == id).toList();
  }

  String getParentCategories(categories, id) {
    for (var item in categories) {
      if (item.id == id) {
        return (item.parent == null || item.parent == '0') ? null : item.parent;
      }
    }
    return '0';
    // return categories.where((o) => ((o.id == id) ? o.parent : null));
  }

  Widget _renderItemCategory({String categoryId, String categoryName}) {
    return GestureDetector(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color:
              newCategoryId == categoryId ? Colors.white24 : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          categoryName.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      onTap: () {
        _page = 1;
        final _userId = Provider.of<UserModel>(context, listen: false).user?.id;
        Provider.of<ProductModel>(context, listen: false).getProductsList(
          categoryId: categoryId,
          page: _page,
          onSale: onSale,
          lang: Provider.of<AppModel>(context, listen: false).langCode,
          tagId: newTagId,
          userId: _userId,
        );

        setState(() {
          newCategoryId = categoryId;
          onFilter(
              minPrice: minPrice,
              maxPrice: maxPrice,
              categoryId: newCategoryId,
              tagId: newTagId,
              listingLocationId: newListingLocationId);
        });
      },
    );
  }

  void onLoadMore() {
    _page = _page + 1;
    final filterAttr =
        Provider.of<FilterAttributeModel>(context, listen: false);
    var terms = '';
    for (var i = 0; i < filterAttr.lstCurrentSelectedTerms.length; i++) {
      if (filterAttr.lstCurrentSelectedTerms[i]) {
        terms += '${filterAttr.lstCurrentAttr[i].id},';
      }
    }
    final _userId = Provider.of<UserModel>(context, listen: false).user?.id;
    Provider.of<ProductModel>(context, listen: false).getProductsList(
      categoryId: newCategoryId == '-1' ? null : newCategoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      lang: Provider.of<AppModel>(context, listen: false).langCode,
      page: _page,
      orderBy: orderBy,
      order: orDer,
      featured: featured,
      onSale: onSale,
      attribute: attribute,
      attributeTerm: terms,
      tagId: widget.tagId,
      userId: _userId,
      listingLocation: newListingLocationId,
    );
  }

  @override
  void dispose() {
    FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarWhiteForeground(true);

    final product = Provider.of<ProductModel>(context, listen: true);
    final title =
        widget.title ?? product.categoryName ?? S.of(context).products;
    final layout = widget.config != null && widget.config['layout'] != null
        ? widget.config['layout']
        : Provider.of<AppModel>(context, listen: false).productListLayout;

    final ratioProductImage =
        Provider.of<AppModel>(context, listen: false).ratioProductImage;

    final isListView = layout != 'horizontal';

    /// load the product base on default 2 columns view or AsymmetricView
    /// please note that the AsymmetricView is not ready support for loading per page.
    final backdrop =
        ({products, isFetching, errMsg, isEnd, width}) => ProductBackdrop(
              backdrop: Backdrop(
                frontLayer: isListView
                    ? ProductList(
                        products: products,
                        onRefresh: onRefresh,
                        onLoadMore: onLoadMore,
                        isFetching: isFetching,
                        errMsg: errMsg,
                        isEnd: isEnd,
                        layout: layout,
                        ratioProductImage: ratioProductImage,
                        width: width,
                        showProgressBar: widget.showCountdown,
                      )
                    : AsymmetricView(
                        products: products,
                        isFetching: isFetching,
                        isEnd: isEnd,
                        onLoadMore: onLoadMore,
                        width: width),
                backLayer: BackdropMenu(
                  onFilter: onFilter,
                  categoryId: newCategoryId,
                  tagId: newTagId,
                  listingLocationId: newListingLocationId,
                ),
                frontTitle: widget.showCountdown
                    ? Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title),
                              CountDownTimer(
                                widget.countdownDuration,
                                color: Colors.white24,
                                textColor: Colors.white,
                              )
                            ],
                          ),
                        ],
                      )
                    : Text(title),
                backTitle: Text(S.of(context).filter),
                controller: _controller,
                onSort: onSort,
                appbarCategory: renderCategoryAppbar(),
              ),
              expandingBottomSheet: (!Config().isListingType)
                  ? ExpandingBottomSheet(hideController: _controller)
                  : null,
            );

    Widget buildMain = LayoutBuilder(
      builder: (context, constraint) {
        return FractionallySizedBox(
          widthFactor: 1.0,
          child: ListenableProvider.value(
            value: product,
            child: Consumer<ProductModel>(builder: (context, value, child) {
              return backdrop(
                  products: value.productsList,
                  isFetching: value.isFetching,
                  errMsg: value.errMsg,
                  isEnd: value.isEnd,
                  width: constraint.maxWidth);
            }),
          ),
        );
      },
    );
    return kIsWeb
        ? WillPopScope(
            onWillPop: () async {
              eventBus.fire(const EventOpenCustomDrawer());
              // LayoutWebCustom.changeStateMenu(true);
              Navigator.of(context).pop();
              return false;
            },
            child: buildMain,
          )
        : buildMain;
  }
}
