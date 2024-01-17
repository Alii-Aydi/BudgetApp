

import 'package:budgettn/models/transaction.dart' as Local;
import 'package:cloud_firestore/cloud_firestore.dart';

class Wallet {
  String id;
  String type;
  double balance;
  List<Local.Transaction> transactions;

  Wallet({required this.id ,required this.type, required this.balance, List<Local.Transaction>? transactions})
      : transactions = transactions ?? [];

  void addIncome(String name, double amount) {
    _updateBalance(amount);
    transactions.add(Local.Transaction(type: Local.TransactionType.income, name: name, amount: amount, walletType: ''));
  }

  void addExpense(String name, double amount) {
    _updateBalance(-amount);
    transactions.add(Local.Transaction(type: Local.TransactionType.expense, name: name, amount: amount, walletType: ''));
  }

  void _updateBalance(double amount) {
    balance += amount;
  }

  factory Wallet.fromSnapshot(DocumentSnapshot snapshot) {
    return Wallet(
      id: snapshot.id,
      type: snapshot['type'],
      balance: snapshot['balance'].toDouble(),
    );
  }
}