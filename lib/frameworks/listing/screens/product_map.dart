import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/entities/index.dart';
import '../../../screens/base.dart';
import '../../../widgets/common/expansion_info.dart';

class ProductMap extends StatefulWidget {
  final Product product;
  final bool static;

  ProductMap({this.product, this.static = true});

  @override
  _ProductMapState createState() => _ProductMapState();
}

class _ProductMapState extends BaseScreen<ProductMap> {
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

  void _onMapCreated(GoogleMapController controllerParam) {
    if (mounted) {
      setState(() {
        pageController = controllerParam;
      });
    }
  }

  Set<Marker> _createMarker() {
    var _kMapCenter = LatLng(widget.product.lat, widget.product.long);

    // https://github.com/flutter/flutter/issues/28312
    // ignore: prefer_collection_literals
    return <Marker>[
      Marker(
        markerId: MarkerId('marker_1'),
        position: _kMapCenter,
        infoWindow: InfoWindow(title: widget.product.location, snippet: '*'),
      ),
    ].toSet();
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

  Widget getRegion() {
    var lat = widget.product.lat;
    var long = widget.product.long;

    var type = DataMapping().kTaxonomies['region'];
    if (widget.product.pureTaxonomies == null) return Container();
    if (widget.product.pureTaxonomies[type] != null) {
      var taxonomies = widget.product.pureTaxonomies[type];
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
              const SizedBox(width: 10),
              for (var item in taxonomies)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    item['name'],
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    return Container();
  }

  void _buildUrl() {
    var defaultLocation = <String, String>{
      'latitude': '${widget.product.lat}',
      'longitude': '${widget.product.long}'
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
              'color:red|label:C|${widget.product.lat},${widget.product.long}',
          'key': '$googleMapsApiKey'
        });

    if (mounted) {
      setState(() {
        renderMapURL = mapURL;
      });
    }

    printLog(mapURL.toString());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.product.lat == null || widget.product.long == null) {
      return Container();
    }

    var _kMapCenter = LatLng(widget.product.lat, widget.product.long);
    _buildUrl();
    var lat = widget.product.lat;
    var long = widget.product.long;
    if (widget.static) {
      return Column(
        children: <Widget>[
          ExpansionInfo(
            title: S.of(context).map,
            children: [
              InkWell(
                onTap: () => _openMap(lat, long),
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width / 2 + 20,
                      child: Image.network(
                        renderMapURL.toString(),
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: getRegion(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10)
            ],
            expand: true,
          ),
        ],
      );
    }

    // this is use for the MapView plugins

    return Column(
      children: <Widget>[
        const SizedBox(height: 15),
        ExpansionInfo(
          title: S.of(context).map,
          children: [
            getRegion(),
            InkWell(
              onTap: () => _openMap(lat, long),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width / 2 + 20,
                child: isShowMap
                    ? GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                          target: _kMapCenter,
                          zoom: 11.0,
                        ),
                        markers: _createMarker(),
                        onMapCreated: _onMapCreated,
                      )
                    : Container(),
              ),
            ),
          ],
          expand: true,
        ),
      ],
    );
  }
}
