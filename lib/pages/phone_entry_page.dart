import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'otp_verification_page.dart';

class PhoneEntryPage extends StatefulWidget {
  const PhoneEntryPage({super.key});

  @override
  State<PhoneEntryPage> createState() => _PhoneEntryPageState();
}

class _PhoneEntryPageState extends State<PhoneEntryPage> {
  String _completePhoneNumber = '';
  bool _isPhoneValid = false;

  void _onContinue() {
    if (_isPhoneValid) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationPage(phoneNumber: _completePhoneNumber),
        ),
      );
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Phone Icon
              Icon(
                Icons.phone_in_talk_outlined,
                size: 80,
                color: const Color(0xFF00B0FF),
              ),
              const SizedBox(height: 40),
              
              // Title
              const Text(
                "Enter your phone number",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),

              // International Phone Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: IntlPhoneField(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Phone Number',
                    counterText: "", // Hide character counter
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  initialCountryCode: 'RW', // Default to Rwanda
                  onChanged: (phone) {
                    setState(() {
                      // Format number with spaces for readability (e.g., +250 788 123 456)
                      String formattedNumber = phone.number.replaceAllMapped(
                          RegExp(r".{3}"), (match) => "${match.group(0)} ").trim();
                      _completePhoneNumber = "${phone.countryCode} $formattedNumber";
                      
                      // Basic validation: Check for at least 9 digits
                      _isPhoneValid = phone.number.length >= 9;
                    });
                  },
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    // Removed letterSpacing to allow natural grouping (e.g. 078 888 888)
                  ),
                  dropdownTextStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  dropdownIconPosition: IconPosition.trailing,
                  flagsButtonPadding: const EdgeInsets.only(left: 8),
                  showCountryFlag: true,
                  disableLengthCheck: true, // We handle validation manually or visually
                ),
              ),

              const Spacer(),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isPhoneValid ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE6A100), // Mustard/Orange
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: const Color(0xFFE6A100).withValues(alpha: 0.5), // Faded/Blurred effect
                    disabledForegroundColor: Colors.black.withValues(alpha: 0.3),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Send Code",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
