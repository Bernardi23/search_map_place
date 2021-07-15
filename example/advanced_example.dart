///
/// AVANCED EXAMPLE:
/// Screen with map and search box on top. When the user selects a place through autocompletion,
/// the screen is moved to the selected location, a path that demonstrates the route is created, and a "start route"
/// box slides in to the screen.
///

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:search_map_place/search_map_place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'package:flutter/services.dart' show rootBundle;

const String apiKEY = "";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Search Map Place Demo',
      home: MapPage(),
    );
  }
}

class MapPage extends StatefulWidget {
  @override
  State<MapPage> createState() => MapSampleState();
}

class MapSampleState extends State<MapPage> with SingleTickerProviderStateMixin {
  Completer<GoogleMapController> _mapController = Completer();

  String _mapStyle;
  List<LatLng> _polylinePoints = [];
  Set<Marker> _markers = {};

  AnimationController _ac;
  Animation<Offset> _animation;

  Place _selectedPlace;

  final CameraPosition _initialCamera = CameraPosition(
    target: LatLng(-20.3000, -40.2990),
    zoom: 14.0000,
  );

  @override
  void initState() {
    super.initState();

    // Loads MapStyle file
    rootBundle.loadString('assets/maps_style.txt').then((string) {
      _mapStyle = string;
    });

    _ac = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 750),
    );
    _animation = Tween<Offset>(
      begin: Offset(-1.0, 2.75),
      end: Offset(0.05, 2.75),
    ).animate(CurvedAnimation(
      curve: Curves.easeOut,
      parent: _ac,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          // Map widget
          GoogleMap(
            initialCameraPosition: _initialCamera,
            markers: _markers,

            // Adds Path from user to selected location
            polylines: Set()
              ..add(
                Polyline(
                  polylineId: PolylineId('path'),
                  points: _polylinePoints,
                  color: Colors.teal[200].withOpacity(0.8),
                  endCap: Cap.roundCap,
                  geodesic: true,
                  jointType: JointType.round,
                  startCap: Cap.squareCap,
                  width: 5,
                ),
              ),
            onMapCreated: (GoogleMapController controller) async {
              _mapController.complete(controller);

              // Changes the Map Style
              controller.setMapStyle(_mapStyle);

              // Creates Marker on current user location, using a current icon.
              final userLocation = Marker(
                markerId: MarkerId('user-location'),
                icon: await BitmapDescriptor.fromAssetImage(
                  ImageConfiguration(
                    devicePixelRatio: 2.5,
                  ),
                  'assets/user_location.png',
                ),
                position: _initialCamera.target,
              );

              setState(() => _markers.add(userLocation));
            },
          ),

          // SearchMapPlace widget
          Positioned(
            top: 60,
            left: MediaQuery.of(context).size.width * 0.05,
            child: SearchMapPlaceWidget(
              apiKey: apiKEY,
              icon: IconData(0xE8BD, fontFamily: 'feather'),
              // clearIcon: IconData(0xE8F6, fontFamily: 'feather'),
              iconColor: Colors.teal[200].withOpacity(0.8),
              // placeType: PlaceType.establishment,
              location: _initialCamera.target,
              radius: 30000,
              onSelected: (place) async {
                final geolocation = await place.geolocation;

                // Using the `flutter_polyline_points` library to get the needed data to create the path.
                PolylinePoints polylineGetter = PolylinePoints();
                List<PointLatLng> result = await polylineGetter.getRouteBetweenCoordinates(
                  apiKEY,
                  _initialCamera.target.latitude,
                  _initialCamera.target.longitude,
                  geolocation.coordinates.latitude,
                  geolocation.coordinates.longitude,
                );

                List<LatLng> polylineCoordinates = [];

                for (var point in result) {
                  polylineCoordinates.add(LatLng(point.latitude, point.longitude));
                }

                // Adding marker to the selected location using a custom icon.
                final destination = Marker(
                  markerId: MarkerId('user-destination'),
                  icon: await BitmapDescriptor.fromAssetImage(
                    ImageConfiguration(
                      devicePixelRatio: 2.5,
                    ),
                    'assets/pin.png',
                  ),
                  position: geolocation.coordinates,
                );

                final GoogleMapController controller = await _mapController.future;
                setState(() {
                  _selectedPlace = place;
                  _polylinePoints = polylineCoordinates;
                  _markers.add(destination);
                });

                // Animates the Google Maps camera
                controller.animateCamera(CameraUpdate.newLatLng(geolocation.coordinates));
                controller.animateCamera(CameraUpdate.newLatLngBounds(geolocation.bounds, 100));

                // Animates the "start route" box in to the screen
                _ac.forward();
              },
            ),
          ),

          // Box that will be animated in to the screen when user selects place.
          confirmationBox(),
        ],
      ),
    );
  }

  Widget confirmationBox() {
    return SlideTransition(
      position: _animation,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(20),
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black12,
              spreadRadius: 15.0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              (_selectedPlace != null)
                  ? (_selectedPlace.description.length < 25
                      ? "${_selectedPlace.description}"
                      : "${_selectedPlace.description.replaceRange(25, _selectedPlace.description.length, "")} ...")
                  : "",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26.0,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Estimative: 12 minutes",
              style: TextStyle(color: Colors.black54),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  onPressed: () {},
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Text(
                    "Start Route",
                    style: TextStyle(fontSize: 16),
                  ),
                  color: Colors.teal[200].withOpacity(0.8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
