import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_directions/flutter_map_directions.dart';
import 'dart:math';
import 'package:lottie/lottie.dart';

class Earthquake extends StatefulWidget {
  const Earthquake({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class ElevationPoint {
  final LatLng point;
  final double elevation;

  ElevationPoint(this.point, this.elevation);
}

class _MapScreenState extends State<Earthquake> {
  final flutter_map.MapController _mapController = flutter_map.MapController();
  List<ElevationPoint> _elevationPoints = [];
  LatLng? _userLocation;
  double? _userElevation;
  List<DirectionCoordinate> _coordinates = [];
  final DirectionController _directionController = DirectionController();
  bool _isLoadingRoute = false;

  final Map<String, dynamic> mockData = {
    'results': [
      {
        'latitude': 18.99921745370157,
        'longitude': 72.83753893009329,
        'elevation': 45
      },
      {
        'latitude': 18.990175477651878,
        'longitude': 72.8421177653802,
        'elevation': 55
      },
      {
        'latitude': 18.965641337366147,
        'longitude': 72.83078928763747,
        'elevation': 35
      },
      {
        'latitude': 18.980576178460748,
        'longitude': 72.8281285365297,
        'elevation': 50
      },
      {
        'latitude': 18.99348075087467,
        'longitude': 72.82512446269835,
        'elevation': 70
      },
      {
        'latitude': 18.948172927773324,
        'longitude': 72.82131816592029,
        'elevation': 25
      },
      {
        'latitude': 18.938536618077972,
        'longitude': 72.83090696263079,
        'elevation': 40
      },
      {
        'latitude': 18.93028594290719,
        'longitude': 72.82917389892292,
        'elevation': 60
      }
    ]
  };

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _userLocation =
          LatLng(position.latitude.toDouble(), position.longitude.toDouble());
      _mapController.move(_userLocation!, 13);
    });
    _getElevationPoints();
  }

  Future<void> _getElevationPoints() async {
    final results = mockData['results'] as List;
    setState(() {
      _elevationPoints = results
          .map((r) => ElevationPoint(
              LatLng((r['latitude'] as num).toDouble(),
                  (r['longitude'] as num).toDouble()),
              (r['elevation'] as num).toDouble()))
          .where((ep) => ep.elevation > 30)
          .toList();
    });

    // Center the map on the first elevation point
    if (_elevationPoints.isNotEmpty) {
      _mapController.move(_elevationPoints[0].point, 13);
    }
  }

  ElevationPoint _findClosestElevationPoint(LatLng userLocation) {
    return _elevationPoints.reduce((a, b) {
      var distanceA = _distanceBetweenPoints(userLocation, a.point);
      var distanceB = _distanceBetweenPoints(userLocation, b.point);
      return distanceA < distanceB ? a : b;
    });
  }

  double _distanceBetweenPoints(LatLng p1, LatLng p2) {
    var dx = p1.latitude - p2.latitude;
    var dy = p1.longitude - p2.longitude;
    return sqrt(dx * dx + dy * dy);
  }

  void _loadNewRoute() async {
    setState(() {
      _isLoadingRoute = true;
    });

    if (_userLocation == null || _elevationPoints.isEmpty) return;

    await Future.delayed(const Duration(seconds: 5));
    var closestPoint = _findClosestElevationPoint(_userLocation!);
    Position position = await Geolocator.getCurrentPosition();
    _coordinates = [
      DirectionCoordinate(closestPoint.point.latitude.toDouble(),
          closestPoint.point.longitude.toDouble()),
      DirectionCoordinate(
          position.latitude.toDouble(), position.longitude.toDouble())
    ];
    final bounds = flutter_map.LatLngBounds.fromPoints(_coordinates
        .map((location) => LatLng(location.latitude, location.longitude))
        .toList());
    _mapController.fitCamera(flutter_map.CameraFit.bounds(
        bounds: bounds, padding: const EdgeInsets.all(50)));
    _directionController.updateDirection(_coordinates);
    setState(() {
      _isLoadingRoute = false;
    });
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Safety Information'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                    "This is safety information about earthquakes and elevation."),
                SizedBox(height: 10),
                Text(
                    "Stay Calm: Panic can cause accidents. Try to stay as calm as possible."),
                SizedBox(height: 10),
                Text("Drop, Cover, and Hold On:"),
                Text("Drop: Get down on your hands and knees."),
                Text(
                    "Cover: Protect your head and neck under a sturdy table or desk."),
                Text(
                    "Hold On: Hold on to your shelter until the shaking stops."),
                SizedBox(height: 10),
                Text("Stay Indoors"),
                SizedBox(height: 10),
                Text("Stay Away from Windows"),
                SizedBox(height: 10),
                Text("If Outdoors: Move to an open area"),
                SizedBox(height: 10),
                Text(
                    "If in a Vehicle: Pull over to a safe location and stay inside the vehicle until the shaking stops.")
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Stack(
        children: [
          Positioned(
            top: 55,
            left: 17.5,
            child: Container(
              width: 350,
              height: 500,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(3, 3),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: flutter_map.FlutterMap(
                  mapController: _mapController,
                  options: const flutter_map.MapOptions(
                    initialCenter: LatLng(18.972608, 72.8407215),
                    initialZoom: 13.0,
                  ),
                  children: [
                    flutter_map.TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    flutter_map.MarkerLayer(
                      markers: [
                        if (_userLocation != null)
                          flutter_map.Marker(
                            width: 80.0,
                            height: 80.0,
                            point: _userLocation!,
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.person_pin_circle,
                                  color: Colors.blue,
                                  size: 40.0,
                                ),
                              ],
                            ),
                          ),
                        ..._elevationPoints.map((ep) => flutter_map.Marker(
                              width: 80.0,
                              height: 80.0,
                              point: ep.point,
                              child: const Column(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.green,
                                    size: 30.0,
                                  ),
                                ],
                              ),
                            ))
                      ],
                    ),
                    DirectionsLayer(
                      coordinates: _coordinates,
                      color: Colors.deepOrange,
                      controller: _directionController,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 570,
            left: 17.5,
            child: Container(
              width: 350,
              height: 130,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.grey, offset: Offset(3, 3), blurRadius: 2)
                  ]),
              child: Stack(
                children: [
                  // const Positioned(
                  //   top: 30,
                  //   left: 20,
                  //   right: -50,
                  //   child: Text(
                  //     'Water Level:  72%',
                  //     style: TextStyle(
                  //       fontSize: 18,
                  //       fontWeight: FontWeight.bold,
                  //       fontFamily: 'poppins',
                  //       color: Colors.black,
                  //     ),
                  //     textAlign: TextAlign.center,
                  //   ),
                  // ),
                  Positioned(
                    bottom: -60,
                    right: 85,
                    child: SizedBox(
                      width: 250,
                      height: 250,
                      child: Lottie.asset(
                        'assets/Lottie/map.json',
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 270,
                    child: ElevatedButton(
                      onPressed: _showInfoDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Info'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoadingRoute)
            Positioned(
              top: 280,
              left: 150,
              child: Lottie.asset(
                'assets/Lottie/load2.json',
                width: 100,
                height: 100,
              ),
            ),
          Positioned(
            bottom: 170,
            right: 30,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _getUserLocation,
                  tooltip: 'Get User Location',
                  elevation: 0.0,
                  foregroundColor: Colors.blue,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _loadNewRoute,
                  tooltip: 'Find Route',
                  elevation: 0.0,
                  foregroundColor: Colors.blue,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.directions),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
