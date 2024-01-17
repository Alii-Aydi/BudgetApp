import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/transaction.dart';
import '../services/wallet/transaction_service.dart';

class DashboardScreen extends StatelessWidget {
  final TransactionService _transactionService = TransactionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.grey[800],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: FutureBuilder<List<Transaction>>(
              future: _transactionService.getTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<Transaction> transactions = snapshot.data ?? [];
                  return PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 0,
                      sections: getSections(transactions),
                      borderData: FlBorderData(show: false),
                    ),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder<List<Transaction>>(
                    future: _transactionService.getTransactions(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        List<Transaction> transactions = snapshot.data ?? [];
                        double totalAmount = transactions
                            .map((transaction) => transaction.amount)
                            .fold(0, (a, b) => a + b);

                        return Column(
                          children: [
                            Text(
                              'Total Amount: $totalAmount',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Percentages:',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: TransactionType.values.map((type) {
                                double sumOfType = transactions
                                    .where((transaction) => transaction.type == type)
                                    .map((transaction) => transaction.amount)
                                    .fold(0, (a, b) => a + b);

                                double percentage = (sumOfType / totalAmount) * 100;

                                return Column(
                                  children: [
                                    Text(
                                      '${type.toString().split('.').last}:',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    Text(
                                      '${percentage.toStringAsFixed(2)}%',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> getSections(List<Transaction> transactions) {
    List<PieChartSectionData> sections = [];
    double totalAmount = transactions
        .map((transaction) => transaction.amount)
        .fold(0, (a, b) => a + b);

    for (TransactionType type in TransactionType.values) {
      double sumOfType = transactions
          .where((transaction) => transaction.type == type)
          .map((transaction) => transaction.amount)
          .fold(0, (a, b) => a + b);

      double percentage = (sumOfType / totalAmount) * 100;

      sections.add(PieChartSectionData(
        color: getColorForType(type),
        value: percentage,
        title: type.toString().split('.').last,
        radius: 120,
        titleStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        badgeWidget: Container(),
      ));
    }

    return sections;
  }

  Color getColorForType(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Colors.green;
      case TransactionType.expense:
        return Colors.red;
      case TransactionType.deptin:
        return Colors.orange;
      case TransactionType.deptout:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
