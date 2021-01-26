import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../../../../common/constants.dart';
import '../../../../models/entities/index.dart';
import '../../../../services/index.dart';

enum MapModelState { loading, loaded }

class MapModel extends ChangeNotifier {
  List<Product> nearestProducts = [];
  final _services = Services();
  LocationData currentLocation;
  MapModelState state = MapModelState.loading;
  Set<Marker> markers = <Marker>{};
  GoogleMapController mapController;
  CameraPosition currentUserLocation = const CameraPosition(
    target: LatLng(
      0.0,
      0.0,
    ),
    zoom: 11.0,
  );

  void _updateState(state) {
    this.state = state;
    notifyListeners();
  }

  MapModel() {
    getNearestProducts();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> getUserCurrentLocation() async {
    var location = Location();
    currentLocation = await location.getLocation();
    currentUserLocation = CameraPosition(
      target: LatLng(
        currentLocation.latitude,
        currentLocation.longitude,
      ),
      zoom: 16.0,
    );
  }

  Future<void> getNearestProducts() async {
    if (state != MapModelState.loading) {
      _updateState(MapModelState.loading);
    }
    if (currentLocation == null) {
      await getUserCurrentLocation();
    }
    printLog('getNearestProducts start');
    var list = await _services.api.getProductNearest(currentLocation);
    nearestProducts.addAll(list);
    _updateState(MapModelState.loaded);
    printLog('getNearestProducts done');
  }

  void onPageChange(index, reason) {
    markers.clear();
    markers.add(
      Marker(
        markerId: MarkerId('map-$index'),
        infoWindow: InfoWindow(
          title: '',
          onTap: () {},
        ),
        position:
            LatLng(nearestProducts[index].lat, nearestProducts[index].long),
      ),
    );
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(nearestProducts[index].lat, nearestProducts[index].long),
        zoom: 16.0,
      )),
    );
    notifyListeners();
  }
}
