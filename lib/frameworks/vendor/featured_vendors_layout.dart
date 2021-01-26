import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../models/vendor/store_model.dart';
import '../../widgets/common/start_rating.dart';
import '../../widgets/home/header/header_view.dart';
import 'store_detail/store_detail_screen.dart';

class FeaturedVendorsLayout extends StatefulWidget {
  final config;

  FeaturedVendorsLayout({this.config, Key key}) : super(key: key);

  @override
  _FeaturedVendorsLayoutState createState() => _FeaturedVendorsLayoutState();
}

class _FeaturedVendorsLayoutState extends State<FeaturedVendorsLayout> {
  int displayColumnCount;
  @override
  void initState() {
    super.initState();
    displayColumnCount = widget.config['columnCount'] ?? 3;
  }

  Widget featuredItem(
      {String name, double rating, String imgUrl, Size size, int flex = 3}) {
    final theme = Theme.of(context);
    final isTablet = Tools.isTablet(MediaQuery.of(context));

    var titleFontSize = isTablet ? 20.0 : (flex == 2 ? 14 : 12);
    var ratingCountFontSize = isTablet ? 16.0 : 12.0;
    var starSize = isTablet ? 16.0 : 10.0;
    var _defaultImage = imgUrl ??
        'https://media.istockphoto.com/photos/vintage-retro-grungy-background-design-and-pattern-texture-picture-id656453072?k=6&m=656453072&s=612x612&w=0&h=4TW6UwMWJrHwF4SiNBwCZfZNJ1jVvkwgz3agbGBihyE=';
    return Container(
      width: size.width,
      height: size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.black26,
              child: Image.network(
                _defaultImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                name,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SmoothStarRating(
                  allowHalfRating: true,
                  starCount: 5,
                  label: Text(
                    '0',
                    style: TextStyle(fontSize: ratingCountFontSize),
                  ),
                  rating: 5.0,
                  size: starSize,
                  color: theme.primaryColor,
                  spacing: 0.0),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(FeaturedVendorsLayout oldWidget) {
    int countColumnOld = oldWidget.config['columnCount'] ?? 3;
    int countColumnNew = widget.config['columnCount'] ?? 3;
    if (countColumnOld != countColumnNew) {
      setState(() {
        displayColumnCount = countColumnNew;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var column = displayColumnCount;
    return FutureBuilder(
        future:
            Provider.of<StoreModel>(context, listen: false).getFeaturedStores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  HeaderView(headerText: widget.config['name']),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final widthCard =
                          constraints.maxWidth / displayColumnCount -
                              5 * displayColumnCount;
                      final heightCard = widthCard * 0.9;
                      return Container(
                        height: heightCard * 1.2,
                        color: Colors.transparent,
                        child: Swiper(
                          itemBuilder: (ct, swiperIndex) {
                            var listCardLength = column;
                            if (snapshot.data.length % column != 0) {
                              if (swiperIndex ==
                                  (snapshot.data.length / column).floor()) {
                                listCardLength = snapshot.data.length % column;
                              }
                            }

                            return Center(
                              child: Wrap(
                                spacing: 10.0,
                                runSpacing: 10.0,
                                children: List.generate(
                                  listCardLength,
                                  (index) {
                                    Store store = snapshot
                                        .data[index + column * swiperIndex];
                                    return InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          RouteList.storeDetail,
                                          arguments:
                                              StoreDetailArgument(store: store),
                                        );
                                      },
                                      child: featuredItem(
                                        flex: displayColumnCount,
                                        size: Size(widthCard, heightCard),
                                        name: store.name,
                                        rating: store.rating,
                                        imgUrl: store.image,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          itemCount: (snapshot.data.length % column) == 0
                              ? (snapshot.data.length / column).round()
                              : (snapshot.data.length / column).floor() + 1,
                        ),
                      );
                    },
                  ),
                ],
              );
            } else {
              return Container();
            }
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              HeaderView(headerText: widget.config['name']),
            ],
          );
        });
  }
}
