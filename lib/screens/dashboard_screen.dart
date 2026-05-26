import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import 'generate_qr_screen.dart';
import 'qr_screen.dart';
import 'transaction_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // ── Top Purple Header ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft:  Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [

                    // App bar row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, Hema 👋',
                              style: TextStyle(
                                color: AppColors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                            const Text(
                              'EasyPe Merchant',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Wallet balance card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Wallet Balance',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${AppConstants.currency}${AppConstants.walletBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Available Balance',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Stats Row ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _statCard(
                      'Transactions',
                      '${AppConstants.totalTransactions}',
                      Icons.swap_horiz,
                      AppColors.accent,
                    ),
                    const SizedBox(width: 12),
                    _statCard(
                      "Today's Collection",
                      '${AppConstants.currency}${AppConstants.todayCollection.toStringAsFixed(0)}',
                      Icons.today,
                      AppColors.success,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Quick Actions ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [

                        // ✅ Scan & Pay → numpad + Razorpay
                        _actionButton(
                          icon:  Icons.qr_code_scanner,
                          label: 'Scan & Pay',
                          color: AppColors.primary,
                          onTap: () => Get.to(() => const QRScreen()),
                        ),

                        // ✅ Generate QR → simple QR only
                        _actionButton(
                          icon:  Icons.qr_code_2,
                          label: 'Generate QR',
                          color: AppColors.accent,
                          onTap: () => Get.to(() => const GenerateQRScreen()),
                        ),

                        // ✅ Transactions list
                        _actionButton(
                          icon:  Icons.receipt_long,
                          label: 'Transactions',
                          color: AppColors.success,
                          onTap: () => Get.to(() => const TransactionScreen()),
                        ),

                        // ✅ Send Money (placeholder)
                        _actionButton(
                          icon:  Icons.send,
                          label: 'Send Money',
                          color: AppColors.pending,
                          onTap: () {
                            Get.snackbar(
                              'Coming Soon',
                              'Send Money feature coming soon!',
                              backgroundColor: AppColors.pending,
                              colorText: AppColors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Recent Transactions Header ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => const TransactionScreen()),
                      child: const Text(
                        'See All',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Recent Transactions List ──────────────────────────────────
              ...List.generate(3, (i) {
                final txn = _dummyTransactions[i];
                return _recentTile(
                  txn['name']!,
                  txn['amount']!,
                  txn['status']!,
                );
              }),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ── Stat Card Widget ────────────────────────────────────────────────────────
  Widget _statCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textLight,
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

  // ── Action Button Widget ────────────────────────────────────────────────────
  Widget _actionButton({
    required IconData  icon,
    required String    label,
    required Color     color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  // ── Recent Transaction Tile ─────────────────────────────────────────────────
  Widget _recentTile(String name, String amount, String status) {
    Color statusColor = status == 'SUCCESS'
        ? AppColors.success
        : status == 'PENDING'
            ? AppColors.pending
            : AppColors.failed;

    IconData statusIcon = status == 'SUCCESS'
        ? Icons.check_circle
        : status == 'PENDING'
            ? Icons.access_time
            : Icons.cancel;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              name[0],
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const Text(
                  'UPI Payment',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),

          // Amount + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹$amount',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: statusColor,
                ),
              ),
              Row(
                children: [
                  Icon(statusIcon, size: 11, color: statusColor),
                  const SizedBox(width: 3),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Dummy Data ──────────────────────────────────────────────────────────────
  final List<Map<String, String>> _dummyTransactions = const [
    {'name': 'Rahul Kumar', 'amount': '500',  'status': 'SUCCESS'},
    {'name': 'Priya Singh', 'amount': '250',  'status': 'PENDING'},
    {'name': 'Amit Shah',   'amount': '1000', 'status': 'SUCCESS'},
  ];
}