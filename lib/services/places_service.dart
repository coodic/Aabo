// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
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

class AddressSearch extends SearchDelegate<Suggestion?> {
  final sessionToken = const Uuid().v4();
  PlaceApiProvider apiClient = PlaceApiProvider();

  AddressSearch();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(); // No separate results page needed for autocomplete
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<Suggestion>>(
      future: query.isEmpty
          ? Future.value([])
          : apiClient.fetchSuggestions(query, Localizations.localeOf(context).languageCode),
      builder: (context, snapshot) {
        if (query.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: const Text('Enter your address'),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
           return Container(
            padding: const EdgeInsets.all(16.0),
            child: const Text('Loading...'),
          );
        }

        return ListView.builder(
          itemBuilder: (context, index) => ListTile(
            title: Text((snapshot.data![index]).description),
            onTap: () {
              close(context, snapshot.data![index]);
            },
          ),
          itemCount: snapshot.data!.length,
        );
      },
    );
  }
}
