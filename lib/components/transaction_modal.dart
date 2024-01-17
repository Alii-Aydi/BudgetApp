import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import '../services/wallet/transaction_service.dart';
import '../services/wallet/wallet_service.dart';

class TransactionModal extends StatefulWidget {
  final VoidCallback refreshCallback;

  const TransactionModal({required this.refreshCallback});

  @override
  _TransactionModalState createState() => _TransactionModalState();
}

class _TransactionModalState extends State<TransactionModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TransactionType _selectedType = TransactionType.income;
  String _selectedWallet = '';
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  final TransactionService _transactionService = TransactionService();
  final WalletService _walletService = WalletService();

  List<Wallet> _wallets = [];
  bool _isLoadingWallets = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _amountController = TextEditingController();
    _fetchWallets();
  }

  Future<void> _fetchWallets() async {
    try {
      List<Wallet> wallets = await _walletService.getWallets();
      setState(() {
        _wallets = wallets;
        _selectedWallet = _wallets.isNotEmpty ? _wallets[0].type : '';
        _isLoadingWallets = false;
      });
    } catch (e) {
      // Handle error, if any
      print('Error fetching wallets: $e');
      setState(() {
        _isLoadingWallets = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Transaction'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create Transaction',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                DropdownButtonFormField<TransactionType>(
                  value: _selectedType,
                  onChanged: (TransactionType? value) {
                    setState(() {
                      _selectedType = value ?? TransactionType.income;
                    });
                  },
                  items: TransactionType.values
                      .map<DropdownMenuItem<TransactionType>>(
                    (TransactionType value) {
                      return DropdownMenuItem<TransactionType>(
                        value: value,
                        child: Text(value.toString().split('.').last),
                      );
                    },
                  ).toList(),
                  decoration: InputDecoration(labelText: 'Transaction Type'),
                ),
                _isLoadingWallets
                    ? Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<String>(
                        value: _selectedWallet,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedWallet = value ?? '';
                          });
                        },
                        items: _wallets.map<DropdownMenuItem<String>>(
                          (Wallet wallet) {
                            return DropdownMenuItem<String>(
                              value: wallet.type,
                              child: Text(wallet.type),
                            );
                          },
                        ).toList(),
                        decoration: InputDecoration(labelText: 'Choose Wallet'),
                      ),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Transaction Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name for the transaction';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Amount'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the transaction amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      saveTransaction();
                      widget.refreshCallback();
                    }
                  },
                  child: Text('Save'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> saveTransaction() async {
    try {
      double currentCredit = await _walletService.getWalletBalance(_selectedWallet);
      double expenseAmount = double.parse(_amountController.text);

      if ((_selectedType == TransactionType.expense ||
              _selectedType == TransactionType.deptout) &&
          currentCredit - expenseAmount < 0) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content:
                  Text('Insufficient funds. Cannot complete the transaction.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      Transaction newTransaction = Transaction(
        type: _selectedType,
        name: _nameController.text,
        amount: expenseAmount,
        walletType: _selectedWallet,
      );

      // Update credit and save transaction
      await _walletService.updateCredit(
          _selectedWallet, newTransaction.amount, newTransaction.type);
      await _transactionService.saveTransaction(newTransaction);

      widget.refreshCallback();

      Navigator.of(context).pop();
    } catch (e) {
      print('Error saving transaction: $e');
    }
  }
}
