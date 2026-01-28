// ignore_for_file: depend_on_referenced_packages


import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlaceApiProvider {
  final client = http.Client();
  final sessionToken = const Uuid().v4();
  final String apiKey = dotenv.env['API_KEY'] ?? 'YOUR_API_KEY';

  Future<List<Suggestion>> fetchSuggestions(String input, String lang) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=geocode&language=$lang&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        return result['predictions']
            .map<Suggestion>((p) => Suggestion(p['place_id'], p['description']))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<PlaceDetail> getPlaceDetailFromId(String placeId) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        final location = result['result']['geometry']['location'];
        return PlaceDetail(
            result['result']['name'], location['lat'], location['lng']);
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<Map<String, dynamic>> getDirections(double startLat, double startLng, double endLat, double endLng) async {
    const String url = 'https://routes.googleapis.com/directions/v2:computeRoutes';
    
    final body = json.encode({
      "origin": {
        "location": {
          "latLng": {
            "latitude": startLat,
            "longitude": startLng
          }
        }
      },
      "destination": {
        "location": {
          "latLng": {
            "latitude": endLat,
            "longitude": endLng
          }
        }
      },
      "travelMode": "TWO_WHEELER",
      "routingPreference": "TRAFFIC_AWARE",
      "computeAlternativeRoutes": false,
      "routeModifiers": {
        "avoidTolls": false,
        "avoidHighways": false,
        "avoidFerries": false
      },
      "languageCode": "en-US",
      "units": "METRIC"
    });

    final response = await client.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask': 'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline'
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['routes'] != null && (result['routes'] as List).isNotEmpty) {
        final route = result['routes'][0];
        final distance = route['distanceMeters'];
        final duration = route['duration']; 
        final encodedPolyline = route['polyline']['encodedPolyline'];

        return {
          'distance': distance,
          'duration': duration,
          'points': _decodePolyline(encodedPolyline),
        };
      }
      throw Exception('No routes found');
    } else {
      throw Exception('Failed to fetch directions: ${response.body}');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      final p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }
}

class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);
}

class PlaceDetail {
  final String name;
  final double lat;
  final double lng;

  PlaceDetail(this.name, this.lat, this.lng);
}


