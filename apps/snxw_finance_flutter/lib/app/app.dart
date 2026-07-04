import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class SnxwFinanceApp extends StatelessWidget {
  const SnxwFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SNXW Finance',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routes: appRoutes,
      home: const AppShell(),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('SNXW Finance'),
      ),
    );
  }
}