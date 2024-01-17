import 'package:flutter/material.dart';

import '../../components/drawer.dart';
import '../../services/auth/google_auth.dart';

class LogIn extends StatelessWidget {
  const LogIn({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerTemp(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Budget App"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.purple[600],
      ),
      body: Stack(
        children: [
          Container(
            height: double.maxFinite,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage("https://img.freepik.com/free-vector/user-verification-unauthorized-access-prevention-private-account-authentication-cyber-security-people-entering-login-password-safety-measures_335657-3530.jpg?w=740&t=st=1705335347~exp=1705335947~hmac=7024efcf0d72d65e494b319b39a765770e28c92745d2bad0817c719170b5e3cd"),
                fit: BoxFit.cover,
              ),
            )
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.5),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: SignInDemo(),
            ),
          ),
        ]
      ),
    );
  }
}
