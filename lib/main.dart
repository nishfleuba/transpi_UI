import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(
    const TranspiApp(),
  );
}

class TranspiApp extends StatelessWidget {
  const TranspiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TRANSPI',
      home: const LoginScreen(),
    );
  }
}