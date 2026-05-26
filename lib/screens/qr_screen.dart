import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../services/payment_service.dart';
import '../services/firebase_service.dart';
import '../models/transaction_model.dart';
import 'success_screen.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  Razorpay? _razorpay;
  double _currentAmount = 0;
  String _displayAmount = '0';
  bool _isProcessing = false;
  bool _showQR = false; // QR shows only after amount entered

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR,   _onPaymentError);
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
    }
  }

  @override
  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }

  // ── Number Pad Logic ──────────────────────────────────────────────────────

  void _onNumberTap(String value) {
    setState(() {
      if (value == '⌫') {
        // Backspace
        if (_displayAmount.length > 1) {
          _displayAmount = _displayAmount.substring(0, _displayAmount.length - 1);
        } else {
          _displayAmount = '0';
        }
      } else if (value == '.') {
        // Decimal point — only one allowed
        if (!_displayAmount.contains('.')) {
          _displayAmount += '.';
        }
      } else {
        // Number
        if (_displayAmount == '0') {
          _displayAmount = value;
        } else {
          // Max 7 digits before decimal
          final parts = _displayAmount.split('.');
          if (parts[0].length < 7) {
            _displayAmount += value;
          }
        }
      }
      _currentAmount = double.tryParse(_displayAmount) ?? 0;
      _showQR = _currentAmount > 0;
    });
  }

  void _onQuickAmount(int amount) {
    setState(() {
      _displayAmount = amount.toString();
      _currentAmount = amount.toDouble();
      _showQR = true;
    });
  }

  void _clearAmount() {
    setState(() {
      _displayAmount = '0';
      _currentAmount = 0;
      _showQR = false;
    });
  }

  // ── Payment Handlers ──────────────────────────────────────────────────────

  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isProcessing = false);
    final txnId = response.paymentId ?? PaymentService.generateTransactionId();

    await FirebaseService.saveTransaction(TransactionModel(
      id:       txnId,
      amount:   _currentAmount,
      status:   'SUCCESS',
      receiver: 'Test Customer',
      date:     DateTime.now(),
    ));

    Get.off(() => SuccessScreen(
      amount: _currentAmount,
      transactionId: txnId,
    ));
  }

  void _onPaymentError(PaymentFailureResponse response) async {
    setState(() => _isProcessing = false);

    if (response.code == 0) {
      Get.snackbar('Cancelled', 'Payment was cancelled',
          backgroundColor: Colors.grey.shade700,
          colorText: AppColors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    await FirebaseService.saveTransaction(TransactionModel(
      id:       PaymentService.generateTransactionId(),
      amount:   _currentAmount,
      status:   'FAILED',
      receiver: 'Test Customer',
      date:     DateTime.now(),
    ));

    Get.snackbar('Payment Failed', response.message ?? 'Try again',
        backgroundColor: AppColors.failed,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM);
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    setState(() => _isProcessing = false);
    Get.snackbar('Wallet', 'Redirecting to ${response.walletName}...',
        snackPosition: SnackPosition.BOTTOM);
  }

  // ── Open Payment ──────────────────────────────────────────────────────────

  void _openPayment() {
    if (_currentAmount <= 0) {
      Get.snackbar('Invalid Amount', 'Please enter an amount first',
          backgroundColor: AppColors.failed,
          colorText: AppColors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Web simulation
    if (kIsWeb) {
      _simulateWebPayment();
      return;
    }

    setState(() => _isProcessing = true);
    try {
      _razorpay!.open(PaymentService.buildOptions(
        amount:        _currentAmount,
        customerName:  'Test Customer',
        customerPhone: '9999999999',
        description:   'EasyPe Payment',
      ));
    } catch (e) {
      setState(() => _isProcessing = false);
      Get.snackbar('Error', 'Could not open payment gateway',
          backgroundColor: AppColors.failed,
          colorText: AppColors.white,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _simulateWebPayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isProcessing = false);

    final txnId = PaymentService.generateTransactionId();
    await FirebaseService.saveTransaction(TransactionModel(
      id:       txnId,
      amount:   _currentAmount,
      status:   'SUCCESS',
      receiver: 'Test Customer',
      date:     DateTime.now(),
    ));

    Get.off(() => SuccessScreen(
      amount: _currentAmount,
      transactionId: txnId,
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final String qrData =
        'upi://pay?pa=${AppConstants.upiId}'
        '&pn=${AppConstants.appName}'
        '&am=${_currentAmount.toStringAsFixed(2)}'
        '&cu=INR';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text('Scan & Pay'),
        elevation: 0,
        actions: [
          // Clear button
          if (_currentAmount > 0)
            TextButton.icon(
              onPressed: _clearAmount,
              icon: const Icon(Icons.refresh, color: Colors.white70, size: 18),
              label: const Text('Clear',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // ── Purple header with merchant info + amount display ──────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft:  Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Merchant row
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.store, color: AppColors.white),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('EasyPe Merchant',
                              style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold)),
                          Text(AppConstants.upiId,
                              style: TextStyle(
                                  color: AppColors.white.withOpacity(0.7),
                                  fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('✓ VERIFIED',
                            style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Big amount display
                  Text(
                    _currentAmount > 0
                        ? '₹ ${_displayAmount}'
                        : '₹ 0',
                    style: TextStyle(
                      color: _currentAmount > 0
                          ? AppColors.white
                          : AppColors.white.withOpacity(0.4),
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentAmount > 0
                        ? 'Amount to collect'
                        : 'Enter amount below',
                    style: TextStyle(
                        color: AppColors.white.withOpacity(0.6),
                        fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [

                  // ── Quick Amount Buttons ──────────────────────────────────
                  Row(
                    children: [
                      const Text('Quick Select:',
                          style: TextStyle(
                              color: AppColors.textLight, fontSize: 13)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [100, 200, 500, 1000, 2000].map((amt) {
                              final isSelected =
                                  _currentAmount == amt.toDouble();
                              return GestureDetector(
                                onTap: () => _onQuickAmount(amt),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.grey.shade300,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withOpacity(0.3),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Text(
                                    '₹$amt',
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColors.white
                                          : AppColors.textDark,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Number Pad ────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 8,
                            offset: Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text('Enter Amount',
                            style: TextStyle(
                                color: AppColors.textLight, fontSize: 13)),
                        const SizedBox(height: 16),

                        // Number pad grid
                        ...([
                          ['1', '2', '3'],
                          ['4', '5', '6'],
                          ['7', '8', '9'],
                          ['.', '0', '⌫'],
                        ].map((row) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: row.map((key) {
                                final isBackspace = key == '⌫';
                                final isDot = key == '.';
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => _onNumberTap(key),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 100),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 18),
                                      decoration: BoxDecoration(
                                        color: isBackspace
                                            ? AppColors.failed
                                                .withOpacity(0.1)
                                            : isDot
                                                ? AppColors.accent
                                                    .withOpacity(0.1)
                                                : AppColors.primary
                                                    .withOpacity(0.06),
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isBackspace
                                              ? AppColors.failed
                                                  .withOpacity(0.2)
                                              : Colors.transparent,
                                        ),
                                      ),
                                      child: Center(
                                        child: isBackspace
                                            ? const Icon(
                                                Icons.backspace_outlined,
                                                color: AppColors.failed,
                                                size: 22,
                                              )
                                            : Text(
                                                key,
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDot
                                                      ? AppColors.accent
                                                      : AppColors.textDark,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }).toList()),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── QR Code (shows when amount > 0) ───────────────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _showQR
                        ? Container(
                            key: const ValueKey('qr'),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text('Scan to Pay',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark)),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${_currentAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                QrImageView(
                                  data: qrData,
                                  version: QrVersions.auto,
                                  size: 200,
                                  backgroundColor: AppColors.white,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: AppColors.primary,
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape:
                                        QrDataModuleShape.square,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(AppConstants.upiId,
                                    style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                const Text('Scan with GPay, PhonePe, Paytm',
                                    style: TextStyle(
                                        color: AppColors.textLight,
                                        fontSize: 12)),

                                // Supported apps
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: ['GPay', 'PhonePe', 'Paytm', 'BHIM']
                                      .map((app) => Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 4),
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.background,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color:
                                                      Colors.grey.shade200),
                                            ),
                                            child: Text(app,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color:
                                                        AppColors.textDark)),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            key: const ValueKey('no-qr'),
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.qr_code_2,
                                    size: 60,
                                    color: Colors.grey.shade300),
                                const SizedBox(height: 12),
                                const Text('QR will appear here',
                                    style: TextStyle(
                                        color: AppColors.textLight)),
                                const Text(
                                    'Enter amount above to generate QR',
                                    style: TextStyle(
                                        color: AppColors.textLight,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                  ),

                  const SizedBox(height: 20),

                  // ── Test credentials ──────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.info_outline,
                              color: Colors.blue, size: 16),
                          SizedBox(width: 6),
                          Text('Test Credentials',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ]),
                        SizedBox(height: 8),
                        Text('UPI success:  success@razorpay',
                            style: TextStyle(
                                fontSize: 12, color: Colors.blue)),
                        Text('UPI fail:     failure@razorpay',
                            style: TextStyle(
                                fontSize: 12, color: Colors.blue)),
                        SizedBox(height: 4),
                        Text('Card: 4111 1111 1111 1111',
                            style: TextStyle(
                                fontSize: 12, color: Colors.blue)),
                        Text('Expiry: 12/26  CVV: 123  OTP: 1234',
                            style: TextStyle(
                                fontSize: 12, color: Colors.blue)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── OR divider ────────────────────────────────────────────
                  Row(children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('OR PAY DIRECTLY',
                          style: TextStyle(
                              color: AppColors.textLight, fontSize: 12)),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ]),

                  const SizedBox(height: 20),

                  // ── Razorpay Button ───────────────────────────────────────
                  GestureDetector(
                    onTap: _isProcessing ? null : _openPayment,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isProcessing
                              ? [
                                  Colors.grey.shade400,
                                  Colors.grey.shade500
                                ]
                              : _currentAmount > 0
                                  ? const [
                                      Color(0xFF072654),
                                      Color(0xFF3395FF)
                                    ]
                                  : [
                                      Colors.grey.shade300,
                                      Colors.grey.shade400
                                    ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: _currentAmount > 0 && !_isProcessing
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF072654)
                                      .withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: _isProcessing
                          ? const Center(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: AppColors.white,
                                        strokeWidth: 2),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Opening Payment Gateway...',
                                      style: TextStyle(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.payment,
                                    color: AppColors.white),
                                const SizedBox(width: 10),
                                Text(
                                  _currentAmount > 0
                                      ? kIsWeb
                                          ? 'Simulate ₹${_currentAmount.toStringAsFixed(0)} Payment'
                                          : 'Pay ₹${_currentAmount.toStringAsFixed(0)} via Razorpay'
                                      : 'Enter Amount First',
                                  style: const TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Test mode badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.amber.withOpacity(0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.science_outlined,
                            color: Colors.amber, size: 16),
                        SizedBox(width: 6),
                        Text('TEST MODE — No real money charged',
                            style: TextStyle(
                                color: Colors.amber, fontSize: 12)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}