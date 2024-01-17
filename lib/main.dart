import 'package:budgettn/screens/dashboard.dart';
import 'package:budgettn/screens/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    routes: {
      '/': (context) => Wrapper(),
      '/dash':(context)=> DashboardScreen(),
    },
  ));
}


