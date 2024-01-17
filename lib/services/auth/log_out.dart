import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LogOut extends StatelessWidget {
  const LogOut({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> _signOut(BuildContext context) async {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        print("Error during logout: $e");
      }
    }

    return ListTile(
      title: Text(
        'Logout',
        style: TextStyle(color: Colors.red[600]),
      ),
      onTap: () async {
        Navigator.pop(context);
        await _signOut(context);
        Navigator.pushNamed(context, "/");
      },
    );
  }
}
