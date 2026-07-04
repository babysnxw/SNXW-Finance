import 'package:flutter/material.dart';

void main() {
  runApp(const SnxwFinanceApp());
}

class SnxwFinanceApp extends StatelessWidget {
  const SnxwFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SNXW Finance',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(),
    );
  }
}
