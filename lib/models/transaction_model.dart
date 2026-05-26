class TransactionModel {
  final String   id;
  final double   amount;
  final String   status;   // SUCCESS, PENDING, FAILED
  final DateTime date;
  final String   receiver;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.date,
    required this.receiver,
  });

  // Dummy data list
  static List<TransactionModel> dummyList = [
    TransactionModel(
      id: 'TXN001',
      amount: 500,
      status: 'SUCCESS',
      date: DateTime.now().subtract(const Duration(hours: 1)),
      receiver: 'Rahul Kumar',
    ),
    TransactionModel(
      id: 'TXN002',
      amount: 250,
      status: 'PENDING',
      date: DateTime.now().subtract(const Duration(hours: 3)),
      receiver: 'Priya Singh',
    ),
    TransactionModel(
      id: 'TXN003',
      amount: 1000,
      status: 'SUCCESS',
      date: DateTime.now().subtract(const Duration(hours: 5)),
      receiver: 'Amit Shah',
    ),
    TransactionModel(
      id: 'TXN004',
      amount: 750,
      status: 'FAILED',
      date: DateTime.now().subtract(const Duration(days: 1)),
      receiver: 'Sneha Reddy',
    ),
    TransactionModel(
      id: 'TXN005',
      amount: 2000,
      status: 'SUCCESS',
      date: DateTime.now().subtract(const Duration(days: 1)),
      receiver: 'Vikram Nair',
    ),
  ];
}