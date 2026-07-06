import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class SnxwFinanceApp extends StatelessWidget {
  const SnxwFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SNXW Finance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
