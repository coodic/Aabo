import 'dart:io';
import 'package:flutter/material.dart';
import 'pages/onboarding_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

Future<void> main() async {
  print("Current Directory: \\${Directory.current.path}"); // Debug current directory

  try {
    await dotenv.dotenv.load(fileName: ".env"); // Explicitly load .env file
    print("Environment variables loaded successfully.");

    // Debugging: Log the API key
    final apiKey = dotenv.dotenv.env['API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print("API_KEY is missing or empty in the .env file.");
    } else {
      print("Loaded API_KEY: $apiKey");
    }
  } catch (e) {
    print("Failed to load .env file: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AABO Ride',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00B0FF),
          primary: const Color(0xFF00B0FF),
        ),
        useMaterial3: true,
      ),
      home: const OnBoardScreen(),
    );
  }
}
