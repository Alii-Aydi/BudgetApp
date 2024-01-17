import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetItemCard extends StatelessWidget {
  final String name;
  final double amount;
  final String type;
  DateTime date;

  BudgetItemCard(
      {required this.name, required this.amount, required this.type, required this.date});

  @override
  Widget build(BuildContext context) {
    IconData arrowIcon;
    Color arrowColor;

    if (type == 'TransactionType.income') {
      arrowIcon = Icons.arrow_back_sharp;
      arrowColor = Colors.green;
    } else if (type == 'TransactionType.expense') {
      arrowIcon = Icons.arrow_forward;
      arrowColor = Colors.red;
    } else if (type == 'TransactionType.deptin') {
      arrowIcon = Icons.arrow_back_sharp;
      arrowColor = Colors.orange;
    } else if (type == 'TransactionType.deptout') {
      arrowIcon = Icons.arrow_forward;
      arrowColor = Colors.orange;
    } else {
      arrowIcon = Icons.arrow_forward;
      arrowColor = Colors.black;
    }

    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(arrowIcon, color: arrowColor),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: \$${amount.toString()}'),
            Text('Date: ${DateFormat('dd/MM/yyyy').format(date)}'), // Add this line for the date
          ],
        ),
      ),
    );

  }
}