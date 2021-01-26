import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../generated/l10n.dart';
import '../product_edit_screen/widgets/category_check_box.dart';
import 'product_add_screen_model.dart';

class VendorAdminProductAddCategoryScreen extends StatelessWidget {
  final Function updateCategories;
  final Function updateSelectedCategoryIds;

  const VendorAdminProductAddCategoryScreen(
      {Key key,
      @required this.updateCategories,
      @required this.updateSelectedCategoryIds})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _textStyle = Theme.of(context).accentTextTheme.bodyText1.copyWith(
          color: Colors.white,
        );
    return Consumer<VendorAdminProductAddScreenModel>(
      builder: (context, model, _) => Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text(
            model.currentPageView == 0
                ? S.of(context).addProduct
                : model.currentCategories.last.name,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).backgroundColor,
          leading: InkWell(
            onTap: () => model.focusNode.hasFocus
                ? model.requestUnFocus()
                : model.currentPageView == 0
                    ? Navigator.pop(context)
                    : model.goBack(),
            child: const Icon(
              Icons.arrow_back_ios_sharp,
            ),
          ),
        ),
        body: Container(
          color: Theme.of(context).backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
          height: model.focusNode.hasFocus
              ? model.searchedCategories.length * 55 + 70.0
              : 50.0 +
                  model.navigatedCategories[model.currentPageView].length * 55,
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                      '${S.of(context).categories} (${model.selectedCategoryIds.length}) '),
                  Expanded(
                    child: InkWell(
                      onTap: () => model.requestFocus(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 0.5),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: _textStyle.color,
                            ),
                            Expanded(
                              child: TextField(
                                controller: model.searchController,
                                focusNode: model.focusNode,
                                textAlign: TextAlign.end,
                                onChanged: (val) => model.searchCategory(),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(5.0),
                                  isDense: true,
                                  hintStyle: _textStyle,
                                ),
                                style: _textStyle,
                              ),
                            ),
                            //if (!model.focusNode.hasFocus)

//                            if (!model.focusNode.hasFocus)
//                              Text(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              model.focusNode.hasFocus
                  ? Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 55.0 * model.searchedCategories.length,
                        child: ListView.builder(
                          itemCount: model.searchedCategories.length,
                          itemBuilder: (context, index) => CategoryCheckBox(
                              selectedCategoryIds: model.selectedCategoryIds,
                              category: model.searchedCategories[index],
                              onCheckBoxTap: model.updateSelectedCategories),
                        ),
                      ),
                    )
                  : Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 55.0 *
                            model.navigatedCategories[model.currentPageView]
                                .length,
                        child: PageView(
                          controller: model.pageController,
                          children: List.generate(
                            model.navigatedCategories.length,
                            (i) => ListView.builder(
                              itemCount: model.navigatedCategories[i].length,
                              itemBuilder: (context, index) => CategoryCheckBox(
                                  selectedCategoryIds:
                                      model.selectedCategoryIds,
                                  category: model.navigatedCategories[i][index],
                                  onTap: () => model.updatePage(
                                      model.navigatedCategories[i][index]),
                                  onCheckBoxTap:
                                      model.updateSelectedCategories),
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
