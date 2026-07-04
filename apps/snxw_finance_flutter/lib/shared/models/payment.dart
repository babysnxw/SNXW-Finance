import 'dart:convert';

const Object _unset = Object();

double _doubleFrom(dynamic value) => (value as num).toDouble();

DateTime _dateTimeFrom(dynamic value) {
  if (value is DateTime) {
    return value;
  }

  return DateTime.parse(value as String);
}

class Payment {
  final String id;
  final double amount;
  final DateTime date;
  final String method;
  final String? reference;
  final String sourceAccount;
  final String targetId;
  final String targetType;

  const Payment({
    required this.id,
    required this.amount,
    required this.date,
    required this.method,
    this.reference,
    required this.sourceAccount,
    required this.targetId,
    required this.targetType,
  });

  Payment copyWith({
    String? id,
    num? amount,
    DateTime? date,
    String? method,
    Object? reference = _unset,
    String? sourceAccount,
    String? targetId,
    String? targetType,
  }) {
    return Payment(
      id: id ?? this.id,
      amount: amount?.toDouble() ?? this.amount,
      date: date ?? this.date,
      method: method ?? this.method,
      reference: identical(reference, _unset) ? this.reference : reference as String?,
      sourceAccount: sourceAccount ?? this.sourceAccount,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'method': method,
      'reference': reference,
      'sourceAccount': sourceAccount,
      'targetId': targetId,
      'targetType': targetType,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    final normalized = Map<String, dynamic>.from(map);

    return Payment(
      id: normalized['id'] as String,
      amount: _doubleFrom(normalized['amount']),
      date: _dateTimeFrom(normalized['date']),
      method: normalized['method'] as String,
      reference: normalized['reference'] as String?,
      sourceAccount: normalized['sourceAccount'] as String,
      targetId: normalized['targetId'] as String,
      targetType: normalized['targetType'] as String,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Payment.fromJson(String source) {
    return Payment.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }
}