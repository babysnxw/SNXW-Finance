import 'package:isar/isar.dart';

part 'payment_record.g.dart';

@collection
class PaymentRecord {
  Id id = Isar.autoIncrement;

  late String description;
  late double amount;
  late DateTime date;
  late String status;
  String? notes;
}