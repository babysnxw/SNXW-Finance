import 'dart:convert';

double _doubleFrom(dynamic value) => (value as num).toDouble();

DateTime _dateTimeFrom(dynamic value) {
  if (value is DateTime) {
    return value;
  }
  return DateTime.parse(value as String);
}

class Payment {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String status;
  final String? notes;

  const Payment({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.status,
    this.notes,
  });

  Payment copyWith({
    String? id,
    String? description,
    num? amount,
    DateTime? date,
    String? status,
    Object? notes,
  }) {
    return Payment(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount?.toDouble() ?? this.amount,
      date: date ?? this.date,
      status: status ?? this.status,
      notes: notes as String? ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as String,
      description: map['description'] as String,
      amount: _doubleFrom(map['amount']),
      date: _dateTimeFrom(map['date']),
      status: map['status'] as String,
      notes: map['notes'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Payment.fromJson(String source) {
    return Payment.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }
}