import 'package:isar/isar.dart';

part 'cash_account_record.g.dart';

@collection
class CashAccountRecord {
  Id id = Isar.autoIncrement;

  late String name;
  late String type;
  late double currentBalance;
  late String currency;
}