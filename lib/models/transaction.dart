enum TransactionType { income, expense, deptin, deptout }

class Transaction {
  TransactionType type;
  String name;
  double amount;
  DateTime date;
  String walletType;

  Transaction({required this.type, required this.name, required this.amount, required this.walletType})
      : date = DateTime.now();
}