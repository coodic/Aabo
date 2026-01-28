import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../services/places_service.dart';
import '../services/address_search.dart';

class ChoosingLocationPage extends StatefulWidget {
  const ChoosingLocationPage({super.key});

  @override
  State<ChoosingLocationPage> createState() => _ChoosingLocationPageState();
}

class _ChoosingLocationPageState extends State<ChoosingLocationPage> {
  // Kigali coordinates
  static const CameraPosition _kigali = CameraPosition(
    target: LatLng(-1.9441, 30.0619),
    zoom: 14.4746,
  );

  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  bool _fetchingLocation = false; // Add a flag to prevent overlapping calls

  // Location & Boda Search State
  String _destinationText = "Enter Destination";
  LatLng? _currentPosition;
  LatLng? _destinationPosition;
  bool _isSearching = false;
  bool _driverFound = false;
  Map<String, dynamic>? _mockDriver;
  
  // Trip Details
  String _distanceInfo = "";
  String _durationInfo = "";
  String _costInfo = "";
  Set<Polyline> _polylines = {};
  bool _isTripStarted = false;
  Timer? _tripTimer;

  @override
  void dispose() {
    _tripTimer?.cancel();
    super.dispose();
  }

  Future<void> _calculateTripDetails() async {
    if (_currentPosition == null || _destinationPosition == null) return;

    try {
      final directions = await PlaceApiProvider().getDirections(
        _currentPosition!.latitude, 
        _currentPosition!.longitude,
        _destinationPosition!.latitude, 
        _destinationPosition!.longitude
      );

      // Distance from API is in meters
      int distanceInMeters = directions['distance'];
      double distanceInKm = distanceInMeters / 1000;
      
      // Duration from API is string "1234s"
      String durationStr = directions['duration']; // "300s"
      int durationSeconds = int.tryParse(durationStr.replaceAll('s', '')) ?? 0;
      int durationMinutes = (durationSeconds / 60).ceil();
      
      // Calculate cost (Base 400 RWF + 100 RWF per KM)
      int cost = (400 + (distanceInKm * 100)).round();

      setState(() {
        _distanceInfo = "${distanceInKm.toStringAsFixed(1)} km";
        _durationInfo = "$durationMinutes mins";
        _costInfo = "$cost RWF";

        // Draw the real route polyline
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: directions['points'],
            color: Colors.blue,
            width: 5,
          ),
        };
      });
    } catch (e) {
      debugPrint("Error fetching directions: $e");
      // Fallback to straight line if API fails
      double distanceInMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _destinationPosition!.latitude,
        _destinationPosition!.longitude,
      );
      double distanceInKm = distanceInMeters / 1000;
      int cost = (400 + (distanceInKm * 100)).round();

      setState(() {
        _distanceInfo = "${distanceInKm.toStringAsFixed(1)} km";
        _costInfo = "$cost RWF";
      });
    }
  }

  void _startLivePreview() {
    if (_currentPosition == null || _destinationPosition == null) return;

    setState(() {
      _isTripStarted = true;
      _mockDriver = null; // Hide driver card to show trip status
    });

    // Simple interpolation to simulate movement
    int totalSteps = 100;
    int currentStep = 0;
    
    double startLat = _currentPosition!.latitude;
    double startLng = _currentPosition!.longitude;
    double endLat = _destinationPosition!.latitude;
    double endLng = _destinationPosition!.longitude;

    _tripTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (currentStep >= totalSteps) {
        timer.cancel();
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You have arrived at your destination!")),
           );
           setState(() {
             _isTripStarted = false;
             _destinationText = "Enter Destination";
             _polylines.clear();
             _markers.clear();
             // Reset to just showing current location
             _getCurrentLocation();
           });
        }
        return;
      }

      currentStep++;
      double t = currentStep / totalSteps;
      double newLat = startLat + (endLat - startLat) * t;
      double newLng = startLng + (endLng - startLng) * t;
      LatLng newPos = LatLng(newLat, newLng);

      // Update distance remaining
      double remainingMeters = Geolocator.distanceBetween(
        newLat, newLng, endLat, endLng
      );

      if (mounted) {
        setState(() {
          _distanceInfo = "${(remainingMeters / 1000).toStringAsFixed(1)} km left";
          _markers = {
             Marker(
                markerId: const MarkerId('moving-boda'),
                position: newPos,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                infoWindow: const InfoWindow(title: 'You are here'),
                rotation: 0, // In a real app, calculate bearing
             ),
             Marker(
                markerId: const MarkerId('destination'),
                position: _destinationPosition!,
             )
          };
        });
        
        // Optionally follow camera
        _controller.future.then((c) {
           c.animateCamera(CameraUpdate.newLatLng(newPos));
        });
      }
    });
  }

  Future<void> _searchForDriver() async {
    setState(() {
      _isSearching = true;
      _driverFound = false;
      _mockDriver = null;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    setState(() {
      _isSearching = false;
      _driverFound = true;
      _mockDriver = {
        'name': 'John Doe',
        'rating': '4.8',
        'bike': 'Bajaj Boxer (Red)',
        'plate': 'RAB 123 A',
        'eta': '2 mins'
      };

      if (_currentPosition != null) {
        // Mock driver location near current position
        final driverPos = LatLng(
            _currentPosition!.latitude + 0.002, _currentPosition!.longitude + 0.002);
            
        _markers.add(
          Marker(
            markerId: const MarkerId('driver'),
            position: driverPos,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            infoWindow: const InfoWindow(title: 'Boda Driver: John'),
          ),
        );
      }
    });

    // Zoom out slightly to show both
    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.zoomTo(13.5));
  }

  Future<void> _getCurrentLocation() async {
    if (_fetchingLocation) return; // Prevent overlapping calls
    _fetchingLocation = true;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Location services are disabled. Please enable them.')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied.');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied.')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are permanently denied. Please enable them in settings.')),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      debugPrint('Current location: ${position.latitude}, ${position.longitude}');
      _currentPosition = LatLng(position.latitude, position.longitude);

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 14.4746,
          ),
        ),
      );

      if (!mounted) return;
      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('current-location'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
        };
      });
    } catch (e) {
      debugPrint('Error fetching location: $e');
    } finally {
      _fetchingLocation = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Background
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: _kigali,
              myLocationEnabled: !_isTripStarted, // Disable standard location dot during simulation
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              markers: _markers,
              polylines: _polylines, // Add polyline support
              onTap: (LatLng position) {
                if (_isTripStarted) return; // Disable tapping during trip
                setState(() {
                  _markers.clear();
                  _markers.add(
                    Marker(
                      markerId: MarkerId('selected-location'),
                      position: position,
                      infoWindow: InfoWindow(title: 'Selected Location'),
                    ),
                  );
                });
              },
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                debugPrint("Google Map Created");
              },
            ),
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back, size: 30, color: Colors.black),
            ),
          ),

          // Current Location Button
          Positioned(
            top: 50,
            right: 20,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.blue,
              mini: true,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),

          // Bottom Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Current Location Input
                  _buildLocationInput(
                    label: "From",
                    text: "Use Current Location",
                    isBold: true,
                    icon: Icons.my_location,
                    onTap: _getCurrentLocation,
                  ),

                  const SizedBox(height: 16),

                  // Destination Input
                  _buildLocationInput(
                    label: "To",
                    text: _destinationText,
                    isBold: true,
                    icon: Icons.search,
                    onTap: () async {
                      final Suggestion? result = await showSearch<Suggestion?>(
                        context: context,
                        delegate: AddressSearch(),
                      );

                      if (result != null) {
                         try {
                           final placeDetails = await PlaceApiProvider().getPlaceDetailFromId(result.placeId);
                           
                            final GoogleMapController controller = await _controller.future;
                            controller.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(placeDetails.lat, placeDetails.lng),
                                  zoom: 14.4746,
                                ),
                              ),
                            );

                            if (!mounted) return;
                            setState(() {
                              _destinationText = placeDetails.name;
                              _destinationPosition = LatLng(placeDetails.lat, placeDetails.lng);
                              _driverFound = false; // Reset driver search on new location
                              _markers = {
                                Marker(
                                  markerId: const MarkerId('destination'),
                                  position: LatLng(placeDetails.lat, placeDetails.lng),
                                  infoWindow: InfoWindow(title: placeDetails.name),
                                ),
                              };
                            });
                            _calculateTripDetails();
                         } catch (e) {
                           debugPrint("Error fetching details: $e");
                         }
                      }
                    },
                  ),

                  // Search Action / Status
                  if (_isSearching)
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8),
                            Text("Searching for nearby boda..."),
                          ],
                        ),
                      ),
                    )
                  else if (_driverFound && _mockDriver != null)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.amber,
                            child: Icon(Icons.two_wheeler, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Driver Found: ${_mockDriver!['name']}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text("${_mockDriver!['bike']} • ${_mockDriver!['plate']}"),
                                Text("Rating: ${_mockDriver!['rating']} ⭐ • ETA: $_durationInfo"),
                                const SizedBox(height: 4),
                                Text(
                                  "Est. Dist: $_distanceInfo • Cost: $_costInfo",
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _startLivePreview,
                            icon: const Icon(Icons.navigation, color: Colors.green),
                            tooltip: "Start Trip",
                          )
                        ],
                      ),
                    )
                  else if (_isTripStarted)
                     Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Row(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               const Text("Trip in Progress...", style: TextStyle(fontWeight: FontWeight.bold)),
                               Text(_distanceInfo),
                            ],
                          )
                        ],
                      )
                     )
                  else if (_destinationText != "Enter Destination")
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _searchForDriver,
                          icon: const Icon(Icons.search),
                          label: const Text("Find Boda Nearby"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black, // Dark theme button
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInput({
    required String label,
    required String text,
    IconData? icon,
    bool isBold = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFAAAAAA).withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Label
            SizedBox(
              width: 70,
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            // Vertical Divider
            Container(
              height: 24,
              width: 1,
              color: Colors.black54,
              margin: const EdgeInsets.only(right: 12),
            ),
            // Text
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            // Icon
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 20, color: Colors.black87),
            ],
          ],
        ),
      ),
    );
  }
}
