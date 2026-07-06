import 'package:isar/isar.dart';

import '../../shared/models/models.dart';
import '../database/financial_goal_record.dart';

class FinancialGoalRepository {
  const FinancialGoalRepository(this._isar);

  final Isar _isar;

  Future<List<FinancialGoal>> list() async {
    final List<FinancialGoalRecord> records = await _isar.financialGoalRecords.where().sortByDeadline().findAll();

    return records.map(_toFinancialGoal).toList(growable: false);
  }

  Future<FinancialGoal> save(FinancialGoal goal) async {
    final FinancialGoalRecord record = _fromFinancialGoal(goal);

    await _isar.writeTxn(() async {
      await _isar.financialGoalRecords.put(record);
    });

    return goal;
  }

  FinancialGoal _toFinancialGoal(FinancialGoalRecord record) {
    return FinancialGoal(
      id: record.id.toString(),
      name: record.name,
      targetAmount: record.targetAmount,
      currentAmount: record.currentAmount,
      deadline: record.deadline,
      priority: record.priority,
      status: record.status,
    );
  }

  FinancialGoalRecord _fromFinancialGoal(FinancialGoal goal) {
    return FinancialGoalRecord()
      ..name = goal.name
      ..targetAmount = goal.targetAmount
      ..currentAmount = goal.currentAmount
      ..deadline = goal.deadline
      ..priority = goal.priority
      ..status = goal.status;
  }
}