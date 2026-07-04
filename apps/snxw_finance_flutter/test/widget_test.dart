import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:snxw_finance_flutter/app/app.dart';

void main() {
  testWidgets('renders the app shell', (WidgetTester tester) async {
    await tester.pumpWidget(const SnxwFinanceApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('SNXW Finance'), findsOneWidget);
  });
}
