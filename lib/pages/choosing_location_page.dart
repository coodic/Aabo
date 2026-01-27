import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

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

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied.');
      return;
    }

    // Get the current position
    final position = await Geolocator.getCurrentPosition();
    debugPrint('Current location: ${position.latitude}, ${position.longitude}');

    // Update the map camera position
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14.4746,
        ),
      ),
    );

    // Add a marker for the current location
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId('current-location'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(title: 'Your Location'),
        ),
      );
    });
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
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              markers: _markers,
              onTap: (LatLng position) {
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
                    text: "Enter Destination",
                    isBold: true,
                    icon: Icons.search,
                    onTap: () {
                      // Add functionality for destination input
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating Action Button for Current Location
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.my_location, color: Colors.white),
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
