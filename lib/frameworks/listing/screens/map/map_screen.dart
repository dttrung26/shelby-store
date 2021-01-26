import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../widgets/listing_card_view.dart';
import 'map_model.dart';

/// Map Screen
class MapScreen extends StatelessWidget {
  Widget _buildCarousel(width, products, MapModel mapModel) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(bottom: 20, top: 10),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.white, Colors.white, Colors.transparent],
          ),
        ),
        child: CarouselSlider(
          items: List.generate(products.length, (index) {
            return ListingCardView(item: products[index], width: width * 0.8);
          }),
          options: CarouselOptions(
            onPageChanged: mapModel.onPageChange,
            enlargeCenterPage: true,
            height: width * 0.6,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var width = constraints.maxWidth;
        return ChangeNotifierProvider<MapModel>(
          create: (_) => MapModel(),
          child: Scaffold(
            body: Consumer<MapModel>(
              builder: (context, mapModel, _) {
                if (mapModel.state == MapModelState.loading) {
                  return Stack(
                    children: <Widget>[
                      Container(
                        width: width,
                        height: MediaQuery.of(context).size.height,
                        color: Colors.grey,
                      ),
                      Positioned(
                        top: 0,
                        left: 10,
                        child: SafeArea(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Theme.of(context).backgroundColor),
                              child: const Center(
                                  child: Icon(
                                Icons.arrow_back,
                                size: 15,
                              )),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                mapModel.markers.add(
                  Marker(
                    markerId: MarkerId('You are here'),
                    infoWindow: InfoWindow(
                      title: 'You are here',
                      onTap: () {},
                    ),
                    position: LatLng(mapModel.currentLocation.latitude,
                        mapModel.currentLocation.longitude),
                  ),
                );
                return Stack(
                  children: <Widget>[
                    Container(
                      width: width,
                      height: MediaQuery.of(context).size.height,
                      child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: mapModel.currentUserLocation,
                        myLocationEnabled: false,
                        onMapCreated: mapModel.onMapCreated,
                        markers: mapModel.markers,
                      ),
                    ),
                    _buildCarousel(constraints.maxWidth,
                        mapModel.nearestProducts, mapModel),
                    Positioned(
                      top: 0,
                      left: 10,
                      child: SafeArea(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: Theme.of(context).backgroundColor),
                            child: const Center(
                                child: Icon(
                              Icons.arrow_back,
                              size: 15,
                            )),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
