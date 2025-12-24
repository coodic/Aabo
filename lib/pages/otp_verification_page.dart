import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'location_access_page.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationPage({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isError = false;
  int _timeLeft = 59;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp(String code) {
    // Mock verification logic
    if (code.length == 6) {
      if (code != "123456") {
        // Invalid Code Logic
        setState(() {
          _isError = true;
        });
        // Optional: Clear the field or shake animation could go here
      } else {
        // Success Logic
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LocationAccessPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Icon
              const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 80,
                color: Color(0xFF00B0FF),
              ),
              const SizedBox(height: 24),
              
              // Title
              const Text(
                "Verify number",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                "Enter code sent via SMS to ${widget.phoneNumber}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),

              // OTP Input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                  border: _isError ? Border.all(color: Colors.red) : null,
                ),
                child: TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 16, // Wide spacing for digits
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "------",
                    hintStyle: TextStyle(
                      color: Colors.black38,
                      letterSpacing: 16,
                    ),
                    counterText: "",
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(6),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    if (_isError) {
                      setState(() {
                        _isError = false;
                      });
                    }
                    if (value.length == 6) {
                      _verifyOtp(value);
                    }
                  },
                ),
              ),
              
              // Error Message
              if (_isError) ...[
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Invalid Verification Code",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),
              
              // Timer
              Text(
                "waiting for the code ($_timeLeft)",
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
