import 'package:isar/isar.dart';

import '../../shared/models/models.dart';
import '../database/cash_account_record.dart';

class CashAccountRepository {
  const CashAccountRepository(this._isar);

  final Isar _isar;

  Future<List<CashAccount>> list() async {
    final List<CashAccountRecord> records = await _isar.cashAccountRecords.where().sortByName().findAll();

    return records.map(_toCashAccount).toList(growable: false);
  }

  Future<CashAccount> save(CashAccount account) async {
    final CashAccountRecord record = _fromCashAccount(account);

    await _isar.writeTxn(() async {
      await _isar.cashAccountRecords.put(record);
    });

    return account;
  }

  CashAccount _toCashAccount(CashAccountRecord record) {
    return CashAccount(
      id: record.id.toString(),
      name: record.name,
      type: record.type,
      currentBalance: record.currentBalance,
      currency: record.currency,
    );
  }

  CashAccountRecord _fromCashAccount(CashAccount account) {
    return CashAccountRecord()
      ..name = account.name
      ..type = account.type
      ..currentBalance = account.currentBalance
      ..currency = account.currency;
  }
}