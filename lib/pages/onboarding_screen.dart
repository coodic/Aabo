import 'package:flutter/material.dart';
import 'terms_and_privacy_page.dart';
import 'phone_entry_page.dart';

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({super.key});

  @override
  State<OnBoardScreen> createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: "Welcome to AABO",
      description: "Your reliable ride-hailing partner. Get to your destination safely and comfortably.",
      icon: Icons.directions_car_filled_rounded,
      image: "assets/icon/app_icon.png",
    ),
    OnboardingContent(
      title: "Track Your Ride",
      description: "Real-time tracking of your driver. Know exactly when your ride will arrive.",
      icon: Icons.map_rounded,
    ),
    OnboardingContent(
      title: "Safe & Secure",
      description: "Verified drivers and secure payment options for your peace of mind.",
      icon: Icons.security_rounded,
    ),
  ];

  void _goToNextPage() {
    if (_currentPage < _contents.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToTerms();
    }
  }

  void _navigateToTerms() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TermsAndPrivacyPage(),
      ),
    );

    if (result == true && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PhoneEntryPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _navigateToTerms,
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            
            // Page Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _contents.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon Circle or Image
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B0FF).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: _contents[index].image != null
                              ? Image.asset(
                                  _contents[index].image!,
                                  width: 100,
                                  height: 100,
                                )
                              : Icon(
                                  _contents[index].icon,
                                  size: 100,
                                  color: const Color(0xFF00B0FF),
                                ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          _contents[index].title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'Serif',
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _contents[index].description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Section: Indicators and Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _contents.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index 
                              ? const Color(0xFF00B0FF) 
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _goToNextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE6A100), // Mustard/Orange
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentPage == _contents.length - 1 ? "Get Started" : "Next",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingContent {
  final String title;
  final String description;
  final IconData icon;
  final String? image;

  OnboardingContent({
    required this.title, 
    required this.description, 
    required this.icon,
    this.image,
  });
}