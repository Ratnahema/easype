import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../services/firebase_service.dart';
import '../models/transaction_model.dart';
import 'dashboard_screen.dart';

class SuccessScreen extends StatefulWidget {
  final double amount;
  final String transactionId;

  const SuccessScreen({
    super.key,
    required this.amount,
    required this.transactionId,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();

    // ✅ Save transaction to Firebase
    _saveToFirebase();
  }

  // ✅ Save to Firebase Firestore
  void _saveToFirebase() {
    FirebaseService.saveTransaction(
      TransactionModel(
        id:       widget.transactionId,
        amount:   widget.amount,
        status:   'SUCCESS',
        receiver: 'Test Customer',
        date:     DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // ✅ Animated success icon
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.success, width: 3),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 70,
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Payment Successful! 🎉',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your transaction was completed',
                style: TextStyle(color: AppColors.textLight),
              ),
              const SizedBox(height: 32),

              // ✅ Transaction details card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [

                    // Amount
                    Text(
                      '${AppConstants.currency}${widget.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Details rows
                    _detailRow('Transaction ID', widget.transactionId),
                    const SizedBox(height: 12),
                    _detailRow('Date',
                        DateFormat('dd MMM yyyy').format(DateTime.now())),
                    const SizedBox(height: 12),
                    _detailRow('Time',
                        DateFormat('hh:mm a').format(DateTime.now())),
                    const SizedBox(height: 12),
                    _detailRow('Status', 'SUCCESS'),
                    const SizedBox(height: 12),
                    _detailRow('Payment Mode', 'UPI'),
                    const SizedBox(height: 12),
                    _detailRow('Receiver', 'Test Customer'),

                    const SizedBox(height: 20),

                    // ✅ Saved to Firebase badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_done,
                              color: AppColors.success, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Saved to Firebase ✓',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ✅ Back to home button
              GestureDetector(
                onTap: () => Get.offAllNamed('/dashboard'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home, color: AppColors.white),
                      SizedBox(width: 8),
                      Text(
                        'Back to Home',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ✅ View transactions button
              GestureDetector(
                onTap: () => Get.offAllNamed('/transactions'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'View All Transactions',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Detail row widget
  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 14,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}