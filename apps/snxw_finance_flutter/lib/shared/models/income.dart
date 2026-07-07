import 'dart:convert';

class Income {
  final String id;
  final String source;
  final double amount;
  final DateTime date;
  final String? recurrence;
  final String? notes;

  const Income({
    required this.id,
    required this.source,
    required this.amount,
    required this.date,
    this.recurrence,
    this.notes,
  });

  // Eliminar budgetIds y financialGoalIds si no los usas
  // O mantenerlos pero asegurarte de que el repositorio los maneje

  Income copyWith({
    String? id,
    String? source,
    num? amount,
    DateTime? date,
    Object? recurrence,
    Object? notes,
  }) {
    return Income(
      id: id ?? this.id,
      source: source ?? this.source,
      amount: amount?.toDouble() ?? this.amount,
      date: date ?? this.date,
      recurrence: recurrence as String? ?? this.recurrence,
      notes: notes as String? ?? this.notes,
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
    };
  }

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'] as String,
      source: map['source'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      recurrence: map['recurrence'] as String?,
      notes: map['notes'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Income.fromJson(String source) {
    return Income.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }
}