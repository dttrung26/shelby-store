import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/config.dart';
import '../../../../models/vendor/store_model.dart';
import '../../../../screens/base.dart';

class StoreMap extends StatefulWidget {
  final Store store;
  final bool static;

  StoreMap({this.store, this.static = true});

  @override
  _StoreMapState createState() => _StoreMapState();
}

class _StoreMapState extends BaseScreen<StoreMap> {
  GoogleMapController pageController;
  bool isShowMap = false;
  Uri renderMapURL;

  @override
  void afterFirstLayout(BuildContext context) {
    if (mounted) {
      setState(() {
        isShowMap = true;
      });
    }
  }

  static Future<void> _openMap(lat, long) async {
    var googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$long';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  void _buildUrl() {
    var defaultLocation = <String, String>{
      'latitude': '${widget.store.lat}',
      'longitude': '${widget.store.long}'
    };

    // this should change to your own Google API key
    var googleMapsApiKey;
    if (Platform.isIOS) {
      googleMapsApiKey = kGoogleAPIKey['ios'];
    } else if (Platform.isAndroid) {
      googleMapsApiKey = kGoogleAPIKey['android'];
    } else {
      googleMapsApiKey = kGoogleAPIKey['web'];
    }

    var mapURL = Uri(
        scheme: 'https',
        host: 'maps.googleapis.com',
        port: 443,
        path: '/maps/api/staticmap',
        queryParameters: {
          'size': '800x600',
          'center':
              '${defaultLocation['latitude']},${defaultLocation['longitude']}',
          'zoom': '13',
          'maptype': 'roadmap',
          'markers':
              'color:red|label:C|${widget.store.lat},${widget.store.long}',
          'key': '$googleMapsApiKey'
        });

    if (mounted) {
      setState(() {
        renderMapURL = mapURL;
      });
    }
  }

  Widget getDirection() {
    var lat = widget.store.lat;
    var long = widget.store.long;

    return InkWell(
      onTap: () => _openMap(lat, long),
      child: Container(
        color: Theme.of(context).primaryColorLight.withOpacity(0.7),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          children: <Widget>[
            const SizedBox(width: 5),
            Icon(
              Icons.directions,
              color: Theme.of(context).primaryColor,
              size: 25,
            ),
            const SizedBox(
              width: 5.0,
            ),
            const Text('Direction'),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.store.lat == null || widget.store.long == null) {
      return Container();
    }

    _buildUrl();

    return Flexible(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Stack(
          fit: StackFit.loose,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 4 / 3,
              child: CachedNetworkImage(
                imageUrl: renderMapURL.toString(),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: getDirection(),
            ),
          ],
        ),
      ),
    );
  }
}
