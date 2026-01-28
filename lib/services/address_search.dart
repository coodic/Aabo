import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'places_service.dart';

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
