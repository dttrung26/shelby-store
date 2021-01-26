import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../common/config.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart' show AppModel, Store, UserModel;
import '../../../screens/chat/chat_screen.dart';
import '../../../screens/custom/smartchat.dart';
import 'products.dart';
import 'widgets/contact.dart';
import 'widgets/reviews.dart';

class StoreDetailArgument {
  final Store store;
  StoreDetailArgument({this.store});
}

class StoreDetailScreen extends StatefulWidget {
  final Store store;

  StoreDetailScreen({this.store});

  @override
  _StoreDetailState createState() => _StoreDetailState();
}

class _StoreDetailState extends State<StoreDetailScreen> {
  int selected = 0;

  List getSmartChatOptions() {
    var opions = [];
    if (isNotBlank(widget.store.phone)) {
      opions.add({
        'app': 'https://wa.me/${widget.store.phone}',
        'iconData': FontAwesomeIcons.whatsapp
      });
      opions.add({
        'app': 'tel:${widget.store.phone}',
        'iconData': FontAwesomeIcons.phone
      });
      opions.add({
        'app': 'sms://${widget.store.phone}',
        'iconData': FontAwesomeIcons.sms
      });
    }
    if (widget.store.socials != null &&
        widget.store.socials['facebook'] != null) {
      opions.add({
        'app': widget.store.socials['facebook'].contains('http')
            ? widget.store.socials['facebook']
            : 'https://tawk.to/chat/${widget.store.socials["facebook"]}/default',
        'iconData': FontAwesomeIcons.facebookMessenger
      });
    }
    return opions;
  }

  @override
  Widget build(BuildContext context) {
    final bannerUrl = widget.store.banner ?? 'https://media.istockphoto.com/photos/vintage-retro-grungy-background-design-and-pattern-texture-picture-id656453072?k=6&m=656453072&s=612x612&w=0&h=4TW6UwMWJrHwF4SiNBwCZfZNJ1jVvkwgz3agbGBihyE=';

    final userModel = Provider.of<UserModel>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      floatingActionButton: userModel.user != null &&
              widget.store.email != null &&
              kAdvanceConfig['EnableFirebase']
          ? FloatingActionButton(
              heroTag: null,
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      senderUser: userModel.user,
                      receiverEmail: widget.store.email,
                      receiverName: widget.store.name,
                    ),
                  ),
                ); //
              },
              child: const Icon(
                Icons.chat,
                size: 22,
                color: Colors.white,
              ),
            )
          : kConfigChat['EnableSmartChat']
              ? SmartChat(
                  options: getSmartChatOptions(),
                  margin: EdgeInsets.only(
                      right: Provider.of<AppModel>(context, listen: false)
                                  .langCode ==
                              'ar'
                          ? 30.0
                          : 0.0),
                )
              : Container(),
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                leading: IconButton(
                  icon: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).accentColor.withOpacity(0.5),
                    child: const Icon(Icons.arrow_back),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(widget.store.name,
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(color: Colors.white)),
                    background: Stack(
                      children: <Widget>[
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Image.network(
                            bannerUrl,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        Positioned(
                            child: Container(
                          color: Colors.black12.withOpacity(0.2),
                        ))
                      ],
                    )),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelColor: Theme.of(context).accentColor,
                    unselectedLabelColor: Theme.of(context).primaryColor,
                    onTap: (index) {
                      setState(() {
                        selected = index;
                      });
                    },
                    tabs: [
                      Tab(text: S.of(context).product),
                      Tab(text: S.of(context).readReviews),
                      Tab(text: S.of(context).contact),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: renderContent(),
        ),
      ),
    );
  }

  Widget renderContent() {
    switch (selected) {
      case 0:
        return ProductList(
          storeId: widget.store.id,
        );
      case 1:
        return Reviews(
          storeId: widget.store.id,
        );
      case 2:
        return Contact(
          store: widget.store,
        );
      default:
        return Container();
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
