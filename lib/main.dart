import 'dart:io';
import 'package:flutter/material.dart';
import 'pages/onboarding_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

Future<void> main() async {
  print("Current Directory: \\${Directory.current.path}"); // Debug current directory
  await dotenv.dotenv.load(fileName: ".env"); // Explicitly load .env file
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
