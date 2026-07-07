import 'package:isar/isar.dart';

import '../../shared/models/models.dart';
import '../database/payment_record.dart';

class PaymentRepository {
  const PaymentRepository(this._isar);

  final Isar _isar;

  Future<List<Payment>> list() async {
    final List<PaymentRecord> records = await _isar.paymentRecords.where().sortByDateDesc().findAll();

    return records.map(_toPayment).toList(growable: false);
  }

  Future<Payment> save(Payment payment) async {
    final PaymentRecord record = _fromPayment(payment);

    await _isar.writeTxn(() async {
      await _isar.paymentRecords.put(record);
    });

    return payment;
  }

  Payment _toPayment(PaymentRecord record) {
    return Payment(
      id: record.id.toString(),
      description: record.description,
      amount: record.amount,
      date: record.date,
      status: record.status,
      notes: record.notes,
    );
  }

  PaymentRecord _fromPayment(Payment payment) {
    return PaymentRecord()
      ..description = payment.description
      ..amount = payment.amount
      ..date = payment.date
      ..status = payment.status
      ..notes = payment.notes;
  }
}