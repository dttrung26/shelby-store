import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/search_model.dart';
import '../../../models/user_model.dart';
import '../../../widgets/home/vertical/vertical_simple_list.dart';

class SearchResultsCustom extends StatefulWidget {
  final String name;

  const SearchResultsCustom({@required this.name});

  @override
  _SearchResultsCustomState createState() => _SearchResultsCustomState();
}

class _SearchResultsCustomState extends State<SearchResultsCustom> {
  final _refreshController = RefreshController();

  SearchModel get _searchModel =>
      Provider.of<SearchModel>(context, listen: false);

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _userId = Provider.of<UserModel>(context, listen: false).user?.id;
    return Consumer<SearchModel>(
      builder: (_, model, __) {
        final _products = model.products;

        if (_products == null) {
          return kLoadingWidget(context);
        }

        if (_products.isEmpty) {
          return Center(
            child: Text(S.of(context).noProduct),
          );
        }

        return SmartRefresher(
          header: MaterialClassicHeader(
            backgroundColor: Theme.of(context).primaryColor,
          ),
          controller: _refreshController,
          enablePullUp: !model.isEnd,
          enablePullDown: false,
          onRefresh: () => _searchModel.refresh(userId: _userId),
          onLoading: () =>
              _searchModel.loadProduct(name: widget.name, userId: _userId),
          footer: kCustomFooter(context),
          child: ListView.builder(
            itemCount: _products?.length,
            itemBuilder: (context, index) {
              final product = _products[index];
              return SimpleListView(item: product);
            },
          ),
        );
      },
    );
  }
}
