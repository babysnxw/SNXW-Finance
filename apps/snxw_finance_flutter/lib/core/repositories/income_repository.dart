import 'package:isar/isar.dart';
import '../../shared/models/models.dart';
import '../database/income_record.dart';

class IncomeRepository {
  const IncomeRepository(this._isar);

  final Isar _isar;

  Future<List<Income>> list() async {
    final List<IncomeRecord> records = await _isar.incomeRecords.where().sortByDateDesc().findAll();

    return records.map(_toIncome).toList(growable: false);
  }

  Future<Income> save(Income income) async {
    final IncomeRecord record = _fromIncome(income);

    await _isar.writeTxn(() async {
      await _isar.incomeRecords.put(record);
    });

    return income;
  }

  Income _toIncome(IncomeRecord record) {
    return Income(
      id: record.id.toString(), // Esto es correcto
      source: record.source,
      amount: record.amount,
      date: record.date,
      recurrence: record.recurrence,
      notes: record.notes,
    );
  }

  IncomeRecord _fromIncome(Income income) {
    // Si income.id es numérico, lo usamos como ID de Isar
    final int? recordId = int.tryParse(income.id);
    
    return IncomeRecord()
      ..id = recordId ?? Isar.autoIncrement
      ..source = income.source
      ..amount = income.amount
      ..date = income.date
      ..recurrence = income.recurrence
      ..notes = income.notes;
  }
}