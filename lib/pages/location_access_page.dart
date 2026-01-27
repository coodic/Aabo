import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'loading_splash_page.dart';

class LocationAccessPage extends StatefulWidget {
  const LocationAccessPage({super.key});

  @override
  State<LocationAccessPage> createState() => _LocationAccessPageState();
}

class _LocationAccessPageState extends State<LocationAccessPage> {
  bool _isLoading = false;

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
    });

    debugPrint("Requesting location services...");

    // Check if location services are enabled.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    debugPrint("Location services enabled: $serviceEnabled");
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled. Please enable them.')),
        );
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    debugPrint("Checking location permissions...");
    LocationPermission permission = await Geolocator.checkPermission();
    debugPrint("Initial permission status: $permission");
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      debugPrint("Permission after request: $permission");
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint("Permission permanently denied.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')),
        );
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    debugPrint("Permissions granted. Navigating to LoadingSplashPage...");
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoadingSplashPage()),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00B0FF), // Brand Blue
      body: SafeArea(
        child: Stack(
          children: [
            // Close Button
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black, size: 32),
                onPressed: () {
                  // Skip location access and go to dashboard
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoadingSplashPage()),
                  );
                },
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Location Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      // color: Colors.black, // The icon in screenshot is black pin, maybe no circle bg?
                    ),
                    child: const Icon(
                      Icons.location_on,
                      size: 120,
                      color: Color(0xFF1A1A1A), // Dark/Black color
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Title
                  const Text(
                    "Enabling Your Location",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Subtitle
                  const Text(
                    "This will help Aabo to get the nearest Aabo Car or Aabo Motor",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _requestLocationPermission,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE6A100), // Mustard/Orange
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Slightly less rounded than previous buttons based on image
                        ),
                      ),
                      child: _isLoading 
                        ? const SizedBox(
                            height: 24, 
                            width: 24, 
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                          )
                        : const Text(
                            "CONTINUE",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
