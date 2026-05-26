import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/firebase_service.dart';
import '../utils/colors.dart';
import '../widgets/transaction_tile.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String _selectedFilter = 'ALL';
  final List<String> _filters = ['ALL', 'SUCCESS', 'PENDING', 'FAILED'];
  List<TransactionModel> _allTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  // ✅ Load from Firebase
  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    await FirebaseService.seedDummyData(); // seed if empty
    final txns = await FirebaseService.getTransactions();
    setState(() {
      _allTransactions = txns;
      _isLoading = false;
    });
  }

  List<TransactionModel> get _filtered {
    if (_selectedFilter == 'ALL') return _allTransactions;
    return _allTransactions
        .where((t) => t.status == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text('Transactions'),
        elevation: 0,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final isSelected = _selectedFilter == f;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = f),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.white,
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

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '${_filtered.length} Transactions',
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // List or loader
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : _filtered.isEmpty
                    ? const Center(
                        child: Text('No transactions found',
                            style: TextStyle(color: AppColors.textLight)),
                      )
                    : ListView.builder(
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) =>
                            TransactionTile(transaction: _filtered[i]),
                      ),
          ),
        ],
      ),
    );
  }
}