import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_location/other_page.dart';
import 'package:location/location.dart';

const double cameraZoom = 16;
const double cameraTilt = 10;
const double cameraBearing = 30;
const LatLng sourceLocation = LatLng(-6.934719781766648, 107.60480125227897);

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Completer<GoogleMapController> _controller = Completer();
  Location? _location;
  LocationData? _currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;
  final Set<Marker> _markers = <Marker>{};

  @override
  void initState() {
    super.initState();

    if (_locationSubscription != null) {
      _locationSubscription!.resume();
    }

    _location = Location();
    _locationSubscription = _location!.onLocationChanged.listen((event) {
      _currentLocation = event;
      updatePinOnMap();
    });
    setInitialLocation();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _locationSubscription!.pause();
    super.dispose();
  }

  void setInitialLocation() async {
    _currentLocation = await _location!.getLocation();
  }

  void updatePinOnMap() async {
    CameraPosition cPosition = CameraPosition(
      zoom: 18,
      tilt: cameraTilt,
      bearing: cameraBearing,
      target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));

    setState(() {
      if (_currentLocation != null) {
        var pinPosition =
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);

        _markers.removeWhere((m) => m.markerId.value == 'sourcePin');
        _markers.add(Marker(
          markerId: const MarkerId('sourcePin'),
          position: pinPosition,
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = const CameraPosition(
        zoom: cameraZoom,
        tilt: cameraTilt,
        bearing: cameraBearing,
        target: sourceLocation);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
              myLocationEnabled: true,
              compassEnabled: true,
              tiltGesturesEnabled: false,
              mapType: MapType.normal,
              markers: _markers,
              minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
              initialCameraPosition: initialCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                if (!_controller.isCompleted) {
                  _controller.complete(controller);
                  if (_currentLocation != null) {
                    var pinPosition = LatLng(_currentLocation!.latitude!,
                        _currentLocation!.longitude!);
                    _markers.add(Marker(
                      markerId: const MarkerId('sourcePin'),
                      position: pinPosition,
                    ));
                  }
                }
              }),
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.amber,
            child: ElevatedButton(
              child: const Text('go to jannah'),
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const OtherPage()));
              },
            ),
          )
        ],
      ),
    );
  }
}
