import 'package:budgettn/services/wallet/transaction_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/transaction.dart' as Local;
import '../../models/wallet.dart';

class WalletService {
  final _transactionService = TransactionService();
  final CollectionReference walletsCollection =
      FirebaseFirestore.instance.collection('wallets');

  Future<String> addWalletToFirestore(
      String walletType, double initialBalance) async {
    try {
      DocumentReference walletReference = await walletsCollection.add({
        'type': walletType,
        'balance': initialBalance,
      });

      if (initialBalance > 0) {
        // Create an income transaction for the initial balance
        await _transactionService.saveTransaction(
          Local.Transaction(
            type: Local.TransactionType.income,
            name: 'New Wallet',
            amount: initialBalance,
            walletType: walletType,
          ),
        );
      }

      return walletReference.id;
    } catch (e) {
      throw Exception('Failed to add wallet');
    }
  }


  Future<List<Wallet>> getWallets() async {
    try {
      QuerySnapshot querySnapshot = await walletsCollection.get();
      return querySnapshot.docs.map((doc) => Wallet.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Failed to retrieve wallets');
    }
  }

  Future<void> deleteWallet(String walletId) async {
    try {
      // Get the wallet details before deleting
      DocumentSnapshot walletSnapshot = await walletsCollection.doc(walletId).get();
      double walletBalance = walletSnapshot['balance'];

      await _transactionService.saveTransaction(
        Local.Transaction(
          type: Local.TransactionType.expense,
          name: 'Wallet Deletion',
          amount: walletBalance,
          walletType: walletSnapshot['type'],
        ),
      );

      // Delete the wallet after creating the expense transaction
      await walletsCollection.doc(walletId).delete();
    } catch (e) {
      print('Error deleting wallet: $e');
      throw Exception('Failed to delete wallet');
    }
  }

  Future<double> getWalletBalance(String walletType) async {
    try {
      QuerySnapshot walletSnapshot = await walletsCollection
          .where('type', isEqualTo: walletType)
          .get();

      if (walletSnapshot.docs.isNotEmpty) {
        // Assuming there is only one wallet with the given type
        return walletSnapshot.docs.first['balance'].toDouble();
      } else {
        throw Exception('Wallet not found');
      }
    } catch (e) {
      print('Error getting wallet balance: $e');
      throw e;
    }
  }


  Future<void> updateCredit(String walletType, double transactionAmount, Local.TransactionType transactionType) async {
    try {
      QuerySnapshot querySnapshot = await walletsCollection.where('type', isEqualTo: walletType).get();

      // Check if any document matches the query
      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference walletDoc = querySnapshot.docs.first.reference;
        await FirebaseFirestore.instance.runTransaction((Transaction tx) async {
          DocumentSnapshot walletSnapshot = await tx.get(walletDoc);

          // Check if wallet exists
          if (walletSnapshot.exists) {
            double currentBalance = walletSnapshot['balance'];
            double updatedBalance;

            if (transactionType == Local.TransactionType.income || transactionType == Local.TransactionType.deptin) {
              // Add amount for income or deptin transactions
              updatedBalance = currentBalance + transactionAmount;
            } else {
              // Subtract amount for expense or deptout transactions
              updatedBalance = currentBalance - transactionAmount;
            }

            // Update the wallet's balance
            tx.update(walletDoc, {'balance': updatedBalance});
          }
        });
      } else {
        print('No document found for walletType: $walletType');
      }
    } catch (e) {
      print('Error updating credit: $e');
      throw e;
    }
  }


}
