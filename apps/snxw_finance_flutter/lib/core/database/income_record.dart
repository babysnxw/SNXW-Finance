import 'package:isar/isar.dart';

part 'income_record.g.dart';

@collection
class IncomeRecord {
  Id id = Isar.autoIncrement;

  late String source;
  late double amount;
  late DateTime date;
  String? recurrence;
  String? notes;

  // Si necesitas estos campos, descoméntalos
  // List<String>? budgetIds;
  // List<String>? financialGoalIds;
}