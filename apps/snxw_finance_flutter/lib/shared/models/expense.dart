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

class Expense {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String? recurrence;
  final String? notes;
  final bool isEssential;
  final String? budgetId;
  final List<String> financialGoalIds;

  const Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.recurrence,
    this.notes,
    required this.isEssential,
    this.budgetId,
    this.financialGoalIds = const <String>[],
  });

  Expense copyWith({
    String? id,
    String? category,
    num? amount,
    DateTime? date,
    Object? recurrence = _unset,
    Object? notes = _unset,
    bool? isEssential,
    Object? budgetId = _unset,
    List<String>? financialGoalIds,
  }) {
    return Expense(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount?.toDouble() ?? this.amount,
      date: date ?? this.date,
      recurrence: identical(recurrence, _unset)
          ? this.recurrence
          : recurrence as String?,
      notes: identical(notes, _unset) ? this.notes : notes as String?,
      isEssential: isEssential ?? this.isEssential,
      budgetId: identical(budgetId, _unset) ? this.budgetId : budgetId as String?,
      financialGoalIds: financialGoalIds ?? this.financialGoalIds,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'recurrence': recurrence,
      'notes': notes,
      'isEssential': isEssential,
      'budgetId': budgetId,
      'financialGoalIds': financialGoalIds,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    final normalized = Map<String, dynamic>.from(map);

    return Expense(
      id: normalized['id'] as String,
      category: normalized['category'] as String,
      amount: _doubleFrom(normalized['amount']),
      date: _dateTimeFrom(normalized['date']),
      recurrence: normalized['recurrence'] as String?,
      notes: normalized['notes'] as String?,
      isEssential: normalized['isEssential'] as bool? ?? false,
      budgetId: normalized['budgetId'] as String?,
      financialGoalIds: _stringListFrom(normalized['financialGoalIds']),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Expense.fromJson(String source) {
    return Expense.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }
}