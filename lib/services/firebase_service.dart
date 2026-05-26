import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class FirebaseService {
  // Firestore instance
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ Save transaction to Firestore
  static Future<void> saveTransaction(TransactionModel txn) async {
    try {
      await _db.collection('transactions').doc(txn.id).set({
        'id':       txn.id,
        'amount':   txn.amount,
        'status':   txn.status,
        'receiver': txn.receiver,
        'date':     txn.date.toIso8601String(),
      });
    } catch (e) {
      print('Save error: $e');
    }
  }

  // ✅ Get all transactions from Firestore
  static Future<List<TransactionModel>> getTransactions() async {
    try {
      final snapshot = await _db
          .collection('transactions')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TransactionModel(
          id:       data['id'],
          amount:   (data['amount'] as num).toDouble(),
          status:   data['status'],
          receiver: data['receiver'],
          date:     DateTime.parse(data['date']),
        );
      }).toList();

    } catch (e) {
      print('Fetch error: $e');
      return TransactionModel.dummyList; // fallback to dummy
    }
  }

  // ✅ Add dummy transactions on first load
  static Future<void> seedDummyData() async {
    final existing = await _db.collection('transactions').limit(1).get();
    if (existing.docs.isNotEmpty) return; // already has data

    for (final txn in TransactionModel.dummyList) {
      await saveTransaction(txn);
    }
    print('Dummy data seeded!');
  }
}