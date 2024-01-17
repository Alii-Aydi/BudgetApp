import 'package:flutter/material.dart';

import '../models/wallet.dart';
import '../services/wallet/wallet_service.dart';

class CreateWalletModal extends StatefulWidget {
  final VoidCallback refreshCallback;

  const CreateWalletModal({required this.refreshCallback});

  @override
  _CreateWalletModalState createState() => _CreateWalletModalState();
}

class _CreateWalletModalState extends State<CreateWalletModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _walletTypeController;
  late TextEditingController _walletBalanceController;

  @override
  void initState() {
    super.initState();
    _walletTypeController = TextEditingController();
    _walletBalanceController = TextEditingController();
  }

  @override
  void dispose() {
    _walletTypeController.dispose();
    _walletBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('New Wallet'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          children: [
            Text(
              'Create Wallet',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _walletTypeController,
              decoration: InputDecoration(labelText: 'Wallet Type'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid wallet type';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _walletBalanceController,
              decoration: InputDecoration(labelText: 'Initial Balance'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid initial balance';
                }
                double? parsedValue = double.tryParse(value);
                if (parsedValue == null || parsedValue < 0) {
                  return 'Please enter a non-negative number';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  String walletType = _walletTypeController.text;
                  double initialBalance =
                      double.tryParse(_walletBalanceController.text) ?? 0.0;

                 await WalletService()
                      .addWalletToFirestore(walletType, initialBalance);
                  widget.refreshCallback();
                  Navigator.pop(context);
                }
              },
              child: Text('Create'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
            ),
          ],
        ),
      ),
    );
  }
}
