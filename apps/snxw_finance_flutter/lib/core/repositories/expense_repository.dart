import 'package:isar/isar.dart';

import '../../shared/models/models.dart';
import '../database/expense_record.dart';

class ExpenseRepository {
  const ExpenseRepository(this._isar);

  final Isar _isar;

  Future<List<Expense>> list() async {
    final List<ExpenseRecord> records = await _isar.expenseRecords.where().sortByDateDesc().findAll();

    return records.map(_toExpense).toList(growable: false);
  }

  Future<Expense> save(Expense expense) async {
    final ExpenseRecord record = _fromExpense(expense);

    await _isar.writeTxn(() async {
      await _isar.expenseRecords.put(record);
    });

    return expense;
  }

  Expense _toExpense(ExpenseRecord record) {
    return Expense(
      id: record.id.toString(),
      category: record.category,
      amount: record.amount,
      date: record.date,
      recurrence: record.recurrence,
      notes: record.notes,
      isEssential: record.isEssential,
    );
  }

  ExpenseRecord _fromExpense(Expense expense) {
    return ExpenseRecord()
      ..category = expense.category
      ..amount = expense.amount
      ..date = expense.date
      ..recurrence = expense.recurrence
      ..notes = expense.notes
      ..isEssential = expense.isEssential;
  }
}