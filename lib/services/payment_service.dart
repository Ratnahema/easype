import 'package:razorpay_flutter/razorpay_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PaymentService — wraps Razorpay SDK
// Replace 'rzp_test_XXXXXXXXXXXXXXXX' with your actual test key from
// https://dashboard.razorpay.com → Settings → API Keys
// ─────────────────────────────────────────────────────────────────────────────

class PaymentService {
  // ✅ Your Razorpay TEST key — replace with your own
  static const String _testKey = 'rzp_test_Stfc70IGSgoCtc';

  // Generate a unique transaction ID
  static String generateTransactionId() {
    final now = DateTime.now();
    return 'TXN${now.millisecondsSinceEpoch}';
  }

  // ─── Build Razorpay options map ───────────────────────────────────────────
  // This is what gets passed to razorpay.open()
  static Map<String, dynamic> buildOptions({
    required double amount,          // in rupees — we convert to paise inside
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    String? description,
  }) {
    return {
      'key':          _testKey,
      'amount':       (amount * 100).toInt(), // Razorpay needs PAISE not rupees
      'name':         'EasyPe',
      'description':  description ?? 'Test Payment',
      'prefill': {
        'contact': customerPhone,
        'email':   customerEmail ?? 'test@easype.com',
        'name':    customerName,
      },
      'theme': {
        'color': '#5f259f',  // matches AppColors.primary
      },
      'external': {
        // ✅ These UPI apps will show as options in Razorpay checkout
        'wallets': ['paytm', 'phonepe', 'googlepay'],
      },
    };
  }
}