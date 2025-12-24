import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Background
          const GoogleMap(
            initialCameraPosition: _kigali,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
              ),
            ),
          ),

          // Bottom Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFE0E0E0), // Light grey background
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // From Input
                  _buildLocationInput(
                    label: "From",
                    text: "Kigali, kimihurura,kacyiru, kicukiro",
                    icon: Icons.back_hand, // Placeholder for the hand icon
                  ),
                  
                  const SizedBox(height: 16),

                  // Where to Input
                  _buildLocationInput(
                    label: "Where to",
                    text: "Use Current Location",
                    isBold: true,
                  ),

                  const SizedBox(height: 24),

                  // Use Map Option
                  Row(
                    children: [
                      const Icon(Icons.map_outlined, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        "Use Map",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Colors.black54, thickness: 1),
                  const SizedBox(height: 20), // Bottom padding
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFAAAAAA).withOpacity(0.5), // Darker grey for input
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Label
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
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
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: Colors.black87,
                overflow: TextOverflow.ellipsis,
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
    );
  }
}
