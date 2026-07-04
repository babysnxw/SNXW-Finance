import 'dart:convert';

double _doubleFrom(dynamic value) => (value as num).toDouble();

List<String> _stringListFrom(dynamic value) {
  if (value == null) {
    return const <String>[];
  }

  return (value as List<dynamic>)
      .map((item) => item.toString())
      .toList(growable: false);
}

class Budget {
  final String id;
  final String period;
  final String category;
  final double plannedAmount;
  final double spentAmount;
  final double remainingAmount;
  final List<String> incomeIds;
  final List<String> expenseIds;

  const Budget({
    required this.id,
    required this.period,
    required this.category,
    required this.plannedAmount,
    required this.spentAmount,
    required this.remainingAmount,
    this.incomeIds = const <String>[],
    this.expenseIds = const <String>[],
  });

  Budget copyWith({
    String? id,
    String? period,
    String? category,
    num? plannedAmount,
    num? spentAmount,
    num? remainingAmount,
    List<String>? incomeIds,
    List<String>? expenseIds,
  }) {
    return Budget(
      id: id ?? this.id,
      period: period ?? this.period,
      category: category ?? this.category,
      plannedAmount: plannedAmount?.toDouble() ?? this.plannedAmount,
      spentAmount: spentAmount?.toDouble() ?? this.spentAmount,
      remainingAmount: remainingAmount?.toDouble() ?? this.remainingAmount,
      incomeIds: incomeIds ?? this.incomeIds,
      expenseIds: expenseIds ?? this.expenseIds,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'period': period,
      'category': category,
      'plannedAmount': plannedAmount,
      'spentAmount': spentAmount,
      'remainingAmount': remainingAmount,
      'incomeIds': incomeIds,
      'expenseIds': expenseIds,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    final normalized = Map<String, dynamic>.from(map);

    return Budget(
      id: normalized['id'] as String,
      period: normalized['period'] as String,
      category: normalized['category'] as String,
      plannedAmount: _doubleFrom(normalized['plannedAmount']),
      spentAmount: _doubleFrom(normalized['spentAmount']),
      remainingAmount: _doubleFrom(normalized['remainingAmount']),
      incomeIds: _stringListFrom(normalized['incomeIds']),
      expenseIds: _stringListFrom(normalized['expenseIds']),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Budget.fromJson(String source) {
    return Budget.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }
}