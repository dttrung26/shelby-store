import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/vendor/store_model.dart';
import '../../../widgets/common/start_rating.dart';
import '../store_detail/store_detail_screen.dart';

class StoreItem extends StatelessWidget {
  final Store store;

  StoreItem({this.store});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, RouteList.storeDetail,
            arguments: StoreDetailArgument(store: store));
      },
      child: Container(
        margin: const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 10.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.0),
            color: Theme.of(context).backgroundColor,
            boxShadow: [
              const BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 2),
                blurRadius: 6,
              )
            ]),
        child: Column(
          children: [
            const SizedBox(height: 12),
            if (isNotBlank(store.banner))
              ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: Tools.image(
                  url: store.banner,
                  size: kSize.medium,
                  isResize: false,
                  fit: BoxFit.fitWidth,
                  height: 120,
                ),
              ),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.0),
                color: Theme.of(context).backgroundColor,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          store.name,
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).accentColor),
                        ),
                        if (isNotBlank(store.address))
                          const SizedBox(height: 3),
                        if (isNotBlank(store.address))
                          Text(
                            store.address,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      SmoothStarRating(
                          allowHalfRating: true,
                          starCount: 5,
                          rating: store.rating ?? 0.0,
                          size: 15.0,
                          color: theme.primaryColor,
                          borderColor: theme.primaryColor,
                          label: const Text(''),
                          spacing: 0.0),
                      const SizedBox(height: 10),
                      Text(
                        S.of(context).visitStore,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .subtitle1
                            .copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.w700,
                            ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
