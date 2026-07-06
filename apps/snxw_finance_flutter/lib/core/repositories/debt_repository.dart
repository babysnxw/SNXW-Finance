import 'package:isar/isar.dart';

import '../../shared/models/models.dart';
import '../database/debt_record.dart';

class DebtRepository {
  const DebtRepository(this._isar);

  final Isar _isar;

  Future<List<Debt>> list() async {
    final List<DebtRecord> records = await _isar.debtRecords.where().sortByName().findAll();

    return records.map(_toDebt).toList(growable: false);
  }

  Future<Debt> save(Debt debt) async {
    final DebtRecord record = _fromDebt(debt);

    await _isar.writeTxn(() async {
      await _isar.debtRecords.put(record);
    });

    return debt;
  }

  Debt _toDebt(DebtRecord record) {
    return Debt(
      id: record.id.toString(),
      name: record.name,
      principal: record.principal,
      outstandingBalance: record.outstandingBalance,
      interestRate: record.interestRate,
      minimumPayment: record.minimumPayment,
      dueDay: record.dueDay,
      status: record.status,
    );
  }

  DebtRecord _fromDebt(Debt debt) {
    return DebtRecord()
      ..name = debt.name
      ..principal = debt.principal
      ..outstandingBalance = debt.outstandingBalance
      ..interestRate = debt.interestRate
      ..minimumPayment = debt.minimumPayment
      ..dueDay = debt.dueDay
      ..status = debt.status;
  }
}