import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/constants.dart';
import '../../../models/index.dart'
    show
        AppModel,
        CategoryModel,
        FilterAttributeModel,
        FilterTagModel,
        SearchModel,
        UserModel;
import '../../../screens/index.dart'
    show FilterSearch, RecentSearchesCustom, SearchBox, SearchResultsCustom;
import '../../common/auto_hide_keyboard.dart';

class HomeSearchPage extends StatefulWidget {
  HomeSearchPage();
  @override
  State<StatefulWidget> createState() => _HomeSearchPageState();
}

class _HomeSearchPageState<T> extends State<HomeSearchPage> {
  // This node is owned, but not hosted by, the search page. Hosting is done by
  // the text field.
  final _searchFieldNode = FocusNode();
  final _searchFieldController = TextEditingController();

  bool isVisibleSearch = false;
  bool _showResult = false;
  List<String> _suggestSearch;

  SearchModel get _searchModel =>
      Provider.of<SearchModel>(context, listen: false);

  String get _searchKeyword => _searchFieldController.text;

//
  List<String> get suggestSearch =>
      _suggestSearch
          ?.where((s) => s.toLowerCase().contains(_searchKeyword.toLowerCase()))
          ?.toList() ??
      <String>[];

  @override
  void initState() {
    super.initState();
    _searchFieldNode.addListener(() {
      if (_searchKeyword.isEmpty && !_searchFieldNode.hasFocus) {
        _showResult = false;
      } else {
        _showResult = !_searchFieldNode.hasFocus;
      }
    });
  }

  @override
  void dispose() {
    _searchFieldNode?.dispose();
    _searchFieldController.dispose();
//    _searchModel.dispose();
    super.dispose();
  }

  void _onSearchTextChange(String value) {
    if (value.isEmpty) {
      _showResult = false;
      setState(() {});
      return;
    }

    if (_searchFieldNode.hasFocus) {
      if (suggestSearch.isEmpty) {
        final _userId = Provider.of<UserModel>(context, listen: false).user?.id;
        setState(() {
          _showResult = true;
          _searchModel.loadProduct(name: value, userId: _userId);
        });
      } else {
        setState(() {
          _showResult = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    var theme = Theme.of(context);
    theme = Theme.of(context).copyWith(
      primaryColor: Colors.white,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
      primaryColorBrightness: Brightness.light,
      primaryTextTheme: theme.textTheme,
    );
    final searchFieldLabel = MaterialLocalizations.of(context).searchFieldLabel;
    final suggestSearch = List<String>.from(
        Provider.of<AppModel>(context).appConfig['searchSuggestion'] ?? ['']);

    var routeName = isIos ? '' : searchFieldLabel;

    final _userId = Provider.of<UserModel>(context, listen: false).user?.id;
    _suggestSearch = List<String>.from(
        Provider.of<AppModel>(context).appConfig['searchSuggestion'] ?? ['']);

    return Semantics(
      explicitChildNodes: true,
      scopesRoute: true,
      namesRoute: true,
      label: routeName,
      child: Scaffold(
        backgroundColor: theme.backgroundColor,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: theme.backgroundColor,
          iconTheme: theme.primaryIconTheme,
          textTheme: theme.primaryTextTheme,
          brightness: Theme.of(context).brightness,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: close,
          ),
          title: SearchBox(
            showSearchIcon: false,
            showCancelButton: false,
            autoFocus: true,
            controller: _searchFieldController,
            focusNode: _searchFieldNode,
            onChanged: _onSearchTextChange,
            onSubmitted: _onSubmit,
          ),
          actions: _buildActions(),
        ),
        body: AutoHideKeyboard(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, top: 8),
                  child: Container(
                    height: 32,
                    child: FilterSearch(
                      onChange: (searchFilter) {
                        _searchModel.searchByFilter(
                          searchFilter,
                          _searchKeyword,
                          userId: _userId,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  reverseDuration: const Duration(milliseconds: 300),
                  child: _showResult
                      ? buildResult()
                      : Align(
                          alignment: Alignment.topCenter,
                          child: Consumer<FilterTagModel>(
                            builder: (context, tagModel, child) {
                              return Consumer<CategoryModel>(
                                builder: (context, categoryModel, child) {
                                  return Consumer<FilterAttributeModel>(
                                    builder: (context, attributeModel, child) {
                                      if (tagModel.isLoading ||
                                          categoryModel.isLoading ||
                                          attributeModel.isLoading) {
                                        return kLoadingWidget(context);
                                      }
                                      var child = _buildRecentSearch();

                                      if (_searchFieldNode.hasFocus &&
                                          suggestSearch.isNotEmpty) {
                                        child = _buildSuggestions();
                                      }

                                      return child;
                                    },
                                  );
                                },
                              );
                            },
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

  Widget _buildRecentSearch() {
    return RecentSearchesCustom(onTap: _onSubmit);
  }

  Widget _buildSuggestions() {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Theme.of(context).primaryColorLight,
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        itemCount: suggestSearch.length,
        itemBuilder: (_, index) {
          final keyword = suggestSearch[index];
          return GestureDetector(
            onTap: () => _onSubmit(keyword),
            child: ListTile(
              title: Text(keyword),
            ),
          );
        },
      ),
    );
  }

  Widget buildResult() {
    return SearchResultsCustom(
      name: _searchKeyword,
    );
  }

  List<Widget> _buildActions() {
    return <Widget>[
      _searchFieldController.text.isEmpty
          ? IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.search),
              onPressed: () {},
            )
          : IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchFieldController.clear();
                _searchFieldNode.requestFocus();
              },
            ),
    ];
  }

  void _onSubmit(String name) {
    final _userId = Provider.of<UserModel>(context, listen: false).user?.id;
    _searchFieldController.text = name;
    setState(() {
      _showResult = true;
      _searchModel.loadProduct(name: name, userId: _userId);
    });

    var currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  void close() {
    var currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    Navigator.of(context).pop();
  }
}
