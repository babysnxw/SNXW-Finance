import 'dart:convert';

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

class FinancialGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final String priority;
  final String status;
  final List<String> incomeIds;
  final List<String> expenseIds;
  final List<String> debtIds;
  final List<String> budgetIds;

  const FinancialGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.priority,
    required this.status,
    this.incomeIds = const <String>[],
    this.expenseIds = const <String>[],
    this.debtIds = const <String>[],
    this.budgetIds = const <String>[],
  });

  FinancialGoal copyWith({
    String? id,
    String? name,
    num? targetAmount,
    num? currentAmount,
    DateTime? deadline,
    String? priority,
    String? status,
    List<String>? incomeIds,
    List<String>? expenseIds,
    List<String>? debtIds,
    List<String>? budgetIds,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount?.toDouble() ?? this.targetAmount,
      currentAmount: currentAmount?.toDouble() ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      incomeIds: incomeIds ?? this.incomeIds,
      expenseIds: expenseIds ?? this.expenseIds,
      debtIds: debtIds ?? this.debtIds,
      budgetIds: budgetIds ?? this.budgetIds,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline.toIso8601String(),
      'priority': priority,
      'status': status,
      'incomeIds': incomeIds,
      'expenseIds': expenseIds,
      'debtIds': debtIds,
      'budgetIds': budgetIds,
    };
  }

  factory FinancialGoal.fromMap(Map<String, dynamic> map) {
    final normalized = Map<String, dynamic>.from(map);

    return FinancialGoal(
      id: normalized['id'] as String,
      name: normalized['name'] as String,
      targetAmount: _doubleFrom(normalized['targetAmount']),
      currentAmount: _doubleFrom(normalized['currentAmount']),
      deadline: _dateTimeFrom(normalized['deadline']),
      priority: normalized['priority'] as String,
      status: normalized['status'] as String,
      incomeIds: _stringListFrom(normalized['incomeIds']),
      expenseIds: _stringListFrom(normalized['expenseIds']),
      debtIds: _stringListFrom(normalized['debtIds']),
      budgetIds: _stringListFrom(normalized['budgetIds']),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory FinancialGoal.fromJson(String source) {
    return FinancialGoal.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }
}