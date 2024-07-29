import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_directions/flutter_map_directions.dart';
import 'dart:math';
import 'package:lottie/lottie.dart';

class Flood extends StatefulWidget {
  const Flood({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class ElevationPoint {
  final LatLng point;
  final double elevation;

  ElevationPoint(this.point, this.elevation);
}

class _MapScreenState extends State<Flood> {
  final flutter_map.MapController _mapController = flutter_map.MapController();
  List<ElevationPoint> _elevationPoints = [];
  LatLng? _userLocation;
  double? _userElevation;
  List<DirectionCoordinate> _coordinates = [];
  final DirectionController _directionController = DirectionController();
  bool _isLoadingRoute = false; // Add a loading state

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
      _userLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(_userLocation!, 13);
    });
    await _getElevation(_userLocation!);
    _getElevationPoints();
  }

  Future<void> _getElevation(LatLng point) async {
    final response = await http.get(Uri.parse(
        'https://api.open-elevation.com/api/v1/lookup?locations=${point.latitude},${point.longitude}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _userElevation = data['results'][0]['elevation'];
      setState(() {});
    }
  }

  Future<void> _getElevationPoints() async {
    if (_userLocation == null) return;
    // Generate a grid of points around the user's location
    final points = _generateGrid(_userLocation!, 0.1, 5);
    final response = await http.get(Uri.parse(
        'https://api.open-elevation.com/api/v1/lookup?locations=${points.map((p) => "${p.latitude},${p.longitude}").join('|')}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      setState(() {
        _elevationPoints = results
            .map((r) => ElevationPoint(
                LatLng(r['latitude'], r['longitude']), r['elevation']))
            .where((ep) => ep.elevation > 30)
            .toList();
      });
    }
  }

  List<LatLng> _generateGrid(LatLng center, double spacing, int gridSize) {
    List<LatLng> points = [];
    for (int i = -gridSize; i <= gridSize; i++) {
      for (int j = -gridSize; j <= gridSize; j++) {
        points.add(LatLng(
          center.latitude + i * spacing,
          center.longitude + j * spacing,
        ));
      }
    }
    return points;
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
      _isLoadingRoute = true; // Show the loading animation
    });

    if (_userLocation == null || _elevationPoints.isEmpty) return;

    await Future.delayed(const Duration(seconds: 5));
    var closestPoint = _findClosestElevationPoint(_userLocation!);
    Position position = await Geolocator.getCurrentPosition();
    _coordinates = [
      DirectionCoordinate(
          closestPoint.point.latitude, closestPoint.point.longitude),
      DirectionCoordinate(position.latitude, position.longitude)
    ];
    final bounds = flutter_map.LatLngBounds.fromPoints(_coordinates
        .map((location) => LatLng(location.latitude, location.longitude))
        .toList());
    _mapController.fitCamera(flutter_map.CameraFit.bounds(
        bounds: bounds, padding: const EdgeInsets.all(50)));
    _directionController.updateDirection(_coordinates);
    setState(() {
      _isLoadingRoute = false; // Hide the loading animation
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
                Text("Stay Informed:"),
                Text(
                    "Listen to local radio, TV, or NOAA Weather Radio for updates."),
                Text("Follow instructions from local authorities."),
                SizedBox(height: 10),
                Text("Evacuate If Necessary:"),
                Text("Leave your home immediately if instructed to do so."),
                Text(
                    "Move to higher ground away from rivers, streams, and creeks."),
                Text(
                    "Do not walk, swim, or drive through floodwaters. Turn around, don’t drown."),
                SizedBox(height: 10),
                Text("Stay Safe Indoors:"),
                Text(
                    "Move to the highest level of your home but avoid the attic unless necessary."),
                Text(
                    "Do not touch electrical equipment if you are wet or standing in water."),
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
            top: 55, // Adjust the top and left values to control the position
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
                    initialCenter:
                        LatLng(18.972608, 72.8407215), // Default to London
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
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.person_pin_circle,
                                  color: Colors.blue,
                                  size: 40.0,
                                ),
                                Text(
                                  'You: ${_userElevation?.toStringAsFixed(1) ?? ""}m',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ..._elevationPoints.map((ep) => flutter_map.Marker(
                              width: 80.0,
                              height: 80.0,
                              point: ep.point,
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.green,
                                    size: 30.0,
                                  ),
                                  Text(
                                    '${ep.elevation.toStringAsFixed(1)}m',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                      ],
                    ),
                    flutter_map.CircleLayer(circles: [
                      if (_userLocation != null)
                        flutter_map.CircleMarker(
                          point: _userLocation!,
                          radius: 18000,
                          useRadiusInMeter: true,
                          color: Colors.blue.withOpacity(0.3),
                          borderStrokeWidth: 2,
                          borderColor: Colors.blue,
                        ),
                    ]),
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
            top: 570, // Adjust the top and left values to control the position
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
                  const Positioned(
                    top: 30,
                    left: 20,
                    right: -50,
                    child: Text(
                      'Water Level:  72%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'poppins',
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    right: 250,
                    child: SizedBox(
                      width: 80, // Adjust the width here
                      height: 80, // Adjust the height here
                      child: Lottie.asset(
                        'assets/Lottie/waterl.json', // Path to your Lottie animation file
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 150,
                    child: ElevatedButton(
                      onPressed: _showInfoDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15), // Rounded corners
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
              top: 280, // Adjust the top value to control the vertical position
              left:
                  150, // Adjust the left value to control the horizontal position
              child: Lottie.asset(
                'assets/Lottie/load2.json', // Path to your Lottie animation file
                width: 100, // Adjust the width here
                height: 100, // Adjust the height here
              ),
            ),
          Positioned(
            bottom: 170, // Adjust the bottom value to control the position
            right: 30, // Adjust the right value to control the position
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
