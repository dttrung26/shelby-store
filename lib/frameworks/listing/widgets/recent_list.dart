import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/theme/colors.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart';
import '../../../widgets/home/header/header_view.dart';
import '../widgets/listing_card_view.dart';

/// ProductList
class RecentList extends StatefulWidget {
  @override
  RecentListState createState() => RecentListState();
}

class RecentListState extends State<RecentList> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<RecentModel>(context, listen: false).getRecentProduct();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final heightImage = constraints.maxWidth / 4;
        final widthImage = constraints.maxWidth / 4;

        return Consumer<RecentModel>(
          builder: (builder, value, child) {
            if (value.products.isEmpty) {
              return Container();
            }
            return Container(
              color: Theme.of(context).backgroundColor,
              child: Column(children: <Widget>[
                HeaderView(
                  headerText: S.of(context).recents,
                ),
                const SizedBox(height: 10.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for (var item in value.products)
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: ListingCardView(
                              item: item,
                              layout: 'list',
                              showHeart: true,
                              height: heightImage,
                              width: widthImage)),
                  ],
                ),
              ]),
            );
          },
        );
      },
    );
  }
}

/// RecentSearches
class RecentSearches extends StatelessWidget {
  final Function onTap;

  RecentSearches({this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<SearchModel>.value(
      value: Provider.of<SearchModel>(context),
      child: Consumer<SearchModel>(builder: (context, model, child) {
        return Column(
          children: <Widget>[
            Container(
              height: 45,
              decoration:
                  BoxDecoration(color: Theme.of(context).backgroundColor),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(S.of(context).recentSearches),
                  if (model.keywords.isNotEmpty)
                    InkWell(
                        onTap: () {
                          Provider.of<SearchModel>(context, listen: false)
                              .clearKeywords();
                        },
                        child: const Text('Clear',
                            style:
                                TextStyle(color: Colors.green, fontSize: 13)))
                ],
              ),
            ),
            renderKeywords(model.keywords),
          ],
        );
      }),
    );
  }

//  Widget renderEmpty(context) {
//    return Expanded(
//      child: Column(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: <Widget>[
//          Image.asset(
//            kEmptyIconSearch,
//            width: 120,
//            height: 120,
//          ),
//          SizedBox(height: 10),
//          Container(
//              width: 250,
//              child: Text(
//                S.of(context).youHaveNotYetSearch,
//                style: TextStyle(color: kGrey400),
//                textAlign: TextAlign.center,
//              ))
//        ],
//      ),
//    );
//  }

  Widget renderKeywords(List<String> items) {
    return items.isNotEmpty
        ? Expanded(
            child: ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (context, index) => const Divider(
                      color: kGrey400,
                    ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                      title: Text(items[index]),
                      onTap: () {
                        onTap(items[index]);
                      });
                }),
          )
        : Container(child: null);
  }
}
