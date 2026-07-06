import 'package:isar/isar.dart';

part 'expense_record.g.dart';

@collection
class ExpenseRecord {
  Id id = Isar.autoIncrement;

  late String category;
  late double amount;
  late DateTime date;
  String? recurrence;
  String? notes;
  late bool isEssential;
}