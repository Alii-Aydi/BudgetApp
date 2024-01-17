import 'package:flutter/material.dart';

import '../services/wallet/wallet_service.dart';

class WalletCard extends StatelessWidget {
  final String walletType;
  final double balance;
  final WalletService walletService = WalletService();
  String walletId;
  final VoidCallback refreshCallback;

  WalletCard({required this.walletType, required this.balance, required  this.walletId, required this.refreshCallback});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: Colors.grey[800],
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  walletType,
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[400]),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Delete Wallet'),
                          content: Text(
                              'Are you sure you want to delete this wallet?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                walletService.deleteWallet(walletId);
                                refreshCallback();
                                Navigator.pop(context); // Close the dialog
                              },
                              child: Text('Delete'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
                              },
                              child: Text('Cancel'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            Text(
              '\$${balance.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 14.0, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}