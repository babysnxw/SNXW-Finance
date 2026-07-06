import 'package:isar/isar.dart';

part 'debt_record.g.dart';

@collection
class DebtRecord {
  Id id = Isar.autoIncrement;

  late String name;
  late double principal;
  late double outstandingBalance;
  late double interestRate;
  late double minimumPayment;
  late int dueDay;
  late String status;
}