import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../models/vendor/store_model.dart';
import 'store_map.dart';

class Contact extends StatelessWidget {
  final Store store;

  Contact({this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      margin: const EdgeInsets.symmetric(vertical: 18.0),
      child: Column(
        children: <Widget>[
          if (isNotBlank(store.address))
            InfoItem(
              icon: const Icon(
                Icons.location_on,
                size: 20,
              ),
              value: store.address,
            ),
          if (isNotBlank(store.phone))
            InfoItem(
              icon: const Icon(
                Icons.phone,
                size: 20,
              ),
              value: store.phone,
              onTap: () async {
                final url = 'tel:' + store.phone;
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
          if (isNotBlank(store.email))
            InfoItem(
              icon: const Icon(
                Icons.email,
                size: 20,
              ),
              value: store.email,
              onTap: () async {
                final url = 'mailto:' + store.email;
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
          if (isNotBlank(store.website))
            InfoItem(
              icon: const Icon(
                Icons.web,
                size: 20,
              ),
              value: store.website,
              onTap: () async {
                final url = store.website;
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
          renderSocials(),
          if (store.lat != null && store.long != null) StoreMap(store: store),
        ],
      ),
    );
  }

  Widget renderSocials() {
    if (store.socials != null && store.socials.keys.isNotEmpty) {
      var items = <Widget>[];
      store.socials.keys.forEach((key) {
        if (store.socials[key] != null && store.socials[key].isNotEmpty) {
          items.add(
            InfoItem(
              label: key,
              value: store.socials[key],
              onTap: () async {
                final url = store.socials[key];
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
          );
        }
      });
      return Column(children: items);
    }
    return Container();
  }
}

class InfoItem extends StatelessWidget {
  final Icon icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  InfoItem({this.icon, this.label, this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) icon,
          if (label != null)
            Text(
              '$label: ',
              style: Theme.of(context).primaryTextTheme.subtitle1.copyWith(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.bold),
            ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Text(
                value.trimLeft(),
                style: Theme.of(context).primaryTextTheme.subtitle1.copyWith(
                    color: onTap != null
                        ? Colors.blue
                        : Theme.of(context).accentColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
