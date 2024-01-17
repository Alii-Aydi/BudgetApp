import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:budgettn/services/wallet/transaction_service.dart';
import 'package:budgettn/components/drawer.dart';
import 'package:budgettn/components/transaction_card.dart';
import 'package:budgettn/components/transaction_modal.dart';
import 'package:budgettn/components/wallet_card.dart';
import 'package:budgettn/components/wallet_modal.dart';
import 'package:budgettn/models/transaction.dart';
import 'package:budgettn/models/wallet.dart';
import 'package:budgettn/services/wallet/wallet_service.dart';

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final WalletService walletService = WalletService();
  final TransactionService _transactionService = TransactionService();
  late Future<List<Wallet>> _walletsFuture;
  late Future<List<Transaction>> _transactionsFuture;
  late Future<double> _creditSumFuture;
  late Future<double> _deptSumFuture;

  @override
  void initState() {
    super.initState();
    _walletsFuture = walletService.getWallets();
    _transactionsFuture = _transactionService.getTransactions();
    _creditSumFuture = _transactionService.getCreditSum();
    _deptSumFuture = _transactionService.getDeptSum();
  }

  Future<void> _refreshData() async {
    setState(() {
      _walletsFuture = walletService.getWallets();
      _transactionsFuture = _transactionService.getTransactions();
      _creditSumFuture = _transactionService.getCreditSum();
      _deptSumFuture = _transactionService.getDeptSum();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerTemp(),
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Budget App"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[800],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _refreshData();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FutureBuilder<double>(
                  future: Future.wait([_creditSumFuture, _deptSumFuture]).then(
                    (List<double> values) {
                      double creditSum = values[0];
                      double deptSum = values[1];
                      return creditSum - deptSum;
                    },
                  ),
                  builder: (context, snapshot) {
                    double balance = snapshot.data ?? 0.0;
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0.0),
                        color: balance < 0 ? Colors.red[600] : Colors.grey[800],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(16.0, 16, 10, 16),
                            child: Text(
                              'Balance:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Container(
                            child: FutureBuilder<double>(
                              future: Future.wait(
                                  [_creditSumFuture, _deptSumFuture]).then(
                                (List<double> values) {
                                  double creditSum = values[0];
                                  double deptSum = values[1];
                                  return creditSum - deptSum;
                                },
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  double balance = snapshot.data ?? 0.0;
                                  return Text(
                                    '$balance TND',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FutureBuilder<double>(
                      future: _creditSumFuture,
                      builder: (context, snapshot) {
                        double creditSum = snapshot.data ?? 0.0;
                        return Container(
                          width: 189.5,
                          padding: EdgeInsets.fromLTRB(16.0, 16, 10, 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0.0),
                            color: Colors.green[600],
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Credit: ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                '$creditSum TND',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    FutureBuilder<double>(
                      future: _deptSumFuture,
                      builder: (context, snapshot) {
                        double deptSum = snapshot.data ?? 0.0;
                        return Container(
                          width: 189.5,
                          padding: EdgeInsets.fromLTRB(16.0, 16, 10, 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0.0),
                            color: Colors.red[400],
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Dept: ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                '$deptSum TND',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Divider(
                  color: Colors.black,
                  thickness: 1.2,
                  height: 17.0,
                ),
                SizedBox(
                  height: 16,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Wallets",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            showCupertinoModalPopup(
                              context: context,
                              builder: (BuildContext context) {
                                return CreateWalletModal(
                                    refreshCallback: _refreshData);
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.grey[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.account_balance_wallet,
                                  color: Colors.white),
                              SizedBox(width: 8.0),
                              Text(
                                'Add Wallet',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                FutureBuilder<List<Wallet>>(
                  future: _walletsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      List<Wallet> wallets = snapshot.data ?? [];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: wallets.map((wallet) {
                          return WalletCard(
                            walletType: wallet.type,
                            balance: wallet.balance,
                            walletId: wallet.id,
                            refreshCallback:
                                _refreshData, // Pass the document ID to WalletCard
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                Divider(
                  color: Colors.black,
                  thickness: 1.2,
                  height: 10.0,
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  "Transactions",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                ),
                FutureBuilder<List<Transaction>>(
                  future: _transactionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      List<Transaction> transactions = snapshot.data ?? [];

                      return Column(
                        children: transactions.map((transaction) {
                          return BudgetItemCard(
                            name: transaction.name,
                            amount: transaction.amount,
                            type: transaction.type.toString(),
                            date: transaction.date.toLocal(),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return TransactionModal(refreshCallback: _refreshData);
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.grey[800],
      ),
    );
  }
}
