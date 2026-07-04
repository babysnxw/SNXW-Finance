import 'dart:convert';

const Object _unset = Object();

double _doubleFrom(dynamic value) => (value as num).toDouble();

DateTime _dateTimeFrom(dynamic value) {
  if (value is DateTime) {
    return value;
  }

  return DateTime.parse(value as String);
}

List<String> _stringListFrom(dynamic value) {
  if (value == null) {
    return const <String>[];
  }

  return (value as List<dynamic>)
      .map((item) => item.toString())
      .toList(growable: false);
}

class Income {
  final String id;
  final String source;
  final double amount;
  final DateTime date;
  final String? recurrence;
  final String? notes;
  final List<String> budgetIds;
  final List<String> financialGoalIds;

  const Income({
    required this.id,
    required this.source,
    required this.amount,
    required this.date,
    this.recurrence,
    this.notes,
    this.budgetIds = const <String>[],
    this.financialGoalIds = const <String>[],
  });

  Income copyWith({
    String? id,
    String? source,
    num? amount,
    DateTime? date,
    Object? recurrence = _unset,
    Object? notes = _unset,
    List<String>? budgetIds,
    List<String>? financialGoalIds,
  }) {
    return Income(
      id: id ?? this.id,
      source: source ?? this.source,
      amount: amount?.toDouble() ?? this.amount,
      date: date ?? this.date,
      recurrence: identical(recurrence, _unset)
          ? this.recurrence
          : recurrence as String?,
      notes: identical(notes, _unset) ? this.notes : notes as String?,
      budgetIds: budgetIds ?? this.budgetIds,
      financialGoalIds: financialGoalIds ?? this.financialGoalIds,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'source': source,
      'amount': amount,
      'date': date.toIso8601String(),
      'recurrence': recurrence,
      'notes': notes,
      'budgetIds': budgetIds,
      'financialGoalIds': financialGoalIds,
    };
  }

  factory Income.fromMap(Map<String, dynamic> map) {
    final normalized = Map<String, dynamic>.from(map);

    return Income(
      id: normalized['id'] as String,
      source: normalized['source'] as String,
      amount: _doubleFrom(normalized['amount']),
      date: _dateTimeFrom(normalized['date']),
      recurrence: normalized['recurrence'] as String?,
      notes: normalized['notes'] as String?,
      budgetIds: _stringListFrom(normalized['budgetIds']),
      financialGoalIds: _stringListFrom(normalized['financialGoalIds']),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Income.fromJson(String source) {
    return Income.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }
}