import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

const double cameraZoom = 18;
const double cameraTilt = 10;
const double cameraBearing = 30;
const LatLng sourceLocation = LatLng(-6.934719781766648, 107.60480125227897);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Completer<GoogleMapController> _controller = Completer();
  Location? location;
  LocationData? currentLocation;
  final Set<Marker> _markers = <Marker>{};

  @override
  void initState() {
    super.initState();

    location = Location();
    location!.onLocationChanged.listen((event) {
      currentLocation = event;
      updatePinOnMap();
    });
    setInitialLocation();
  }

  void setInitialLocation() async {
    currentLocation = await location!.getLocation();
  }

  void updatePinOnMap() async {
    CameraPosition cPosition = CameraPosition(
      zoom: cameraZoom,
      tilt: cameraTilt,
      bearing: cameraBearing,
      target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));

    setState(() {
      var pinPosition =
          LatLng(currentLocation!.latitude!, currentLocation!.longitude!);

      _markers.removeWhere((m) => m.markerId.value == 'sourcePin');
      _markers.add(Marker(
        markerId: const MarkerId('sourcePin'),
        position: pinPosition,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = const CameraPosition(
        zoom: cameraZoom,
        tilt: cameraTilt,
        bearing: cameraBearing,
        target: sourceLocation);

    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
                myLocationEnabled: true,
                compassEnabled: true,
                tiltGesturesEnabled: false,
                mapType: MapType.normal,
                markers: _markers,
                initialCameraPosition: initialCameraPosition,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  var pinPosition = LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!);
                  _markers.add(Marker(
                    markerId: const MarkerId('sourcePin'),
                    position: pinPosition,
                  ));
                })
          ],
        ),
      ),
    );
  }
}
