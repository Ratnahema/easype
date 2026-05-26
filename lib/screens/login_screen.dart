import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController   = TextEditingController();

  bool _otpSent    = false;
  bool _isLoading  = false;
  String _errorMsg = '';

  // Step 1: Send OTP
  void _sendOTP() {
    setState(() => _errorMsg = '');

    if (!AuthService.validatePhone(_phoneController.text.trim())) {
      setState(() => _errorMsg = 'Enter a valid 10-digit mobile number');
      return;
    }

    setState(() => _isLoading = true);

    // Simulate OTP sending delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _otpSent   = true;
        _isLoading = false;
      });
      Get.snackbar(
        'OTP Sent',
        'Use 1234 as OTP (demo mode)',
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }

  // Step 2: Verify OTP + ✅ Save phone number to Firestore
  void _verifyOTP() async {
    setState(() => _errorMsg = '');

    if (_otpController.text.trim().length != 4) {
      setState(() => _errorMsg = 'Enter 4-digit OTP');
      return;
    }

    if (!AuthService.verifyOTP(_otpController.text.trim())) {
      setState(() => _errorMsg = 'Invalid OTP. Use 1234');
      return;
    }

    setState(() => _isLoading = true);

    // ✅ BUG FIX: savePhoneNumber was defined but never called.
    //    Now we save the phone number to Firestore on successful login.
    await AuthService.savePhoneNumber(_phoneController.text.trim());

    // Show success snackbar
    Get.snackbar(
      'Saved ✓',
      'Phone number saved to Firebase',
      backgroundColor: AppColors.success,
      colorText: AppColors.white,
      snackPosition: SnackPosition.BOTTOM,
    );

    // Navigate to dashboard
    await Future.delayed(const Duration(milliseconds: 800));
    Get.off(() => const DashboardScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top purple header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 50),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft:  Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.currency_rupee_rounded,
                      size: 60,
                      color: AppColors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppConstants.appName,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppConstants.tagline,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Login form
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Welcome Back 👋',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Login to your account',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Phone field
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      enabled: !_otpSent,
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        prefixText: '+91 ',
                        prefixIcon: const Icon(Icons.phone, color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // OTP field (shows after OTP sent)
                    if (_otpSent) ...[
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        decoration: InputDecoration(
                          labelText: 'Enter OTP',
                          hintText: 'Use 1234 (demo)',
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Error message
                    if (_errorMsg.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.failed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.failed, size: 18),
                            const SizedBox(width: 8),
                            Text(_errorMsg, style: const TextStyle(color: AppColors.failed)),
                          ],
                        ),
                      ),

                    // Button
                    _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : CustomButton(
                          label: _otpSent ? 'Verify OTP' : 'Send OTP',
                          icon:  _otpSent ? Icons.verified : Icons.send,
                          onTap: _otpSent ? _verifyOTP : _sendOTP,
                        ),

                    // Change number
                    if (_otpSent)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _otpSent = false;
                            _otpController.clear();
                          });
                        },
                        child: const Text(
                          'Change Number?',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),

                    const SizedBox(height: 30),

                    // Demo hint
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.accent, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Demo Mode: Enter any 10-digit number\nOTP: 1234',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}