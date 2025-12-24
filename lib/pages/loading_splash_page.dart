import 'package:flutter/material.dart';
import 'dashboard_page.dart';

class LoadingSplashPage extends StatefulWidget {
  const LoadingSplashPage({super.key});

  @override
  State<LoadingSplashPage> createState() => _LoadingSplashPageState();
}

class _LoadingSplashPageState extends State<LoadingSplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToDashboard();
  }

  Future<void> _navigateToDashboard() async {
    // Simulate a refreshing/loading process
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon/app_icon.png',
              width: 80,
              height: 80,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.location_on_rounded,
                  size: 60,
                  color: Color(0xFF00B0FF),
                );
              },
            ),
            const SizedBox(width: 10),
            const Text(
              "Aabo",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00B0FF),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
