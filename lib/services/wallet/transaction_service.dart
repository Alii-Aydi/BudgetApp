import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budgettn/models/transaction.dart' as LocalTransaction;

class TransactionService {
  final CollectionReference _transactionCollection =
      FirebaseFirestore.instance.collection('transactions');

  Future<void> saveTransaction(LocalTransaction.Transaction transaction) async {
    await _transactionCollection.add({
      'type': transaction.type.toString(),
      'name': transaction.name,
      'amount': transaction.amount,
      'date': transaction.date,
      'walletType': transaction.walletType,
    });
  }

  Future<List<LocalTransaction.Transaction>> getTransactions() async {
    try {
      QuerySnapshot querySnapshot = await _transactionCollection
          .orderBy('date',
              descending: true) // Order by date in descending order
          .get();

      List<LocalTransaction.Transaction> transactions = [];

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        LocalTransaction.TransactionType type =
            LocalTransaction.TransactionType.values.firstWhere(
          (e) => e.toString() == document['type'],
          orElse: () => LocalTransaction.TransactionType.income,
        );

        String name = document['name'];
        double amount = document['amount'];
        DateTime date = (document['date'] as Timestamp).toDate();
        String walletType = document[
            'walletType']; // Assuming you have a 'walletType' field in your Firestore document

        LocalTransaction.Transaction transaction = LocalTransaction.Transaction(
          type: type,
          name: name,
          amount: amount,
          walletType: walletType,
        );

        transactions.add(transaction);
      }

      return transactions;
    } catch (e) {
      print("Error fetching transactions: $e");
      throw e;
    }
  }

  Future<double> getCreditSum() async {
    try {
      double sumIncomeDeptin = 0.0;
      double sumExpensesDeptout = 0.0;

      // Get sum of income and deptin transactions
      QuerySnapshot incomeDeptinSnapshot = await _transactionCollection
          .where('type', whereIn: [
        LocalTransaction.TransactionType.income.toString(),
        LocalTransaction.TransactionType.deptin.toString(),
      ]).get();

      for (QueryDocumentSnapshot document in incomeDeptinSnapshot.docs) {
        sumIncomeDeptin += double.parse(document['amount'].toString());
      }

      // Get sum of expense and deptout transactions
      QuerySnapshot expenseDeptoutSnapshot = await _transactionCollection
          .where('type', whereIn: [
        LocalTransaction.TransactionType.expense.toString(),
        LocalTransaction.TransactionType.deptout.toString(),
      ]).get();

      for (QueryDocumentSnapshot document in expenseDeptoutSnapshot.docs) {
        sumExpensesDeptout += double.parse(document['amount'].toString());
      }

      // Calculate and return the credit
      return sumIncomeDeptin - sumExpensesDeptout;
    } catch (e) {
      print('Error calculating credit: $e');
      throw e;
    }
  }


  Future<double> getPureCreditSum() async {
    QuerySnapshot querySnapshot =
    await _transactionCollection.where('type', whereIn: [
      LocalTransaction.TransactionType.income.toString(),
      LocalTransaction.TransactionType.deptin.toString(),
    ]).get();
    List<DocumentSnapshot> documents = querySnapshot.docs;
    double sum = 0.0;
    for (var document in documents) {
      sum += double.parse(document['amount'].toString());
    }
    return sum;
  }

  Future<double> getDeptSum() async {
    try {
      double sumDeptin = 0.0;
      double sumDeptout = 0.0;

      // Get sum of deptin transactions
      QuerySnapshot deptinSnapshot = await _transactionCollection
          .where('type',
          isEqualTo: LocalTransaction.TransactionType.deptin.toString())
          .get();

      for (QueryDocumentSnapshot document in deptinSnapshot.docs) {
        sumDeptin += double.parse(document['amount'].toString());
      }

      // Get sum of deptout transactions
      QuerySnapshot deptoutSnapshot = await _transactionCollection
          .where('type',
          isEqualTo: LocalTransaction.TransactionType.deptout.toString())
          .get();

      for (QueryDocumentSnapshot document in deptoutSnapshot.docs) {
        sumDeptout += double.parse(document['amount'].toString());
      }

      // Calculate and return the dept sum
      return sumDeptin - sumDeptout;
    } catch (e) {
      print('Error calculating dept sum: $e');
      throw e;
    }
  }


  Future<double> getSumExpenses() async {
    QuerySnapshot querySnapshot = await _transactionCollection
        .where('type', isEqualTo: 'expense').get();
    double sumExpenses = 0.0;

    for (QueryDocumentSnapshot document in querySnapshot.docs) {
      double amount = document['amount'];
      sumExpenses += amount;
    }
    return sumExpenses;
  }
}

