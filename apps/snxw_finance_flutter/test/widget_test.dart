import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:snxw_finance_flutter/main.dart';

void main() {
  testWidgets('renders a blank home page', (WidgetTester tester) async {
    await tester.pumpWidget(const SnxwFinanceApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('0'), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);
  });
}
