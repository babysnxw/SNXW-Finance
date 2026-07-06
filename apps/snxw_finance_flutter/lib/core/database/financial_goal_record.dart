import 'package:isar/isar.dart';

part 'financial_goal_record.g.dart';

@collection
class FinancialGoalRecord {
  Id id = Isar.autoIncrement;

  late String name;
  late double targetAmount;
  late double currentAmount;
  late DateTime deadline;
  late String priority;
  late String status;
}