import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'income_record.dart';
import 'expense_record.dart';
import 'financial_goal_record.dart';
import 'cash_account_record.dart';
import 'debt_record.dart';
import 'payment_record.dart';

final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  
  return Isar.open(
    [IncomeRecordSchema, ExpenseRecordSchema, FinancialGoalRecordSchema, CashAccountRecordSchema, DebtRecordSchema, PaymentRecordSchema],
    directory: dir.path,
  );
});