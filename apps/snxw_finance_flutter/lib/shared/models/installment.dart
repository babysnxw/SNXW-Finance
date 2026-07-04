import 'dart:convert';

const Object _unset = Object();

double _doubleFrom(dynamic value) => (value as num).toDouble();

DateTime _dateTimeFrom(dynamic value) {
  if (value is DateTime) {
    return value;
  }

  return DateTime.parse(value as String);
}

DateTime? _dateTimeOrNull(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is DateTime) {
    return value;
  }

  return DateTime.parse(value as String);
}

class Installment {
  final String id;
  final String debtId;
  final int installmentNumber;
  final double amountDue;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String status;
  final String? paymentId;

  const Installment({
    required this.id,
    required this.debtId,
    required this.installmentNumber,
    required this.amountDue,
    required this.dueDate,
    this.paidDate,
    required this.status,
    this.paymentId,
  });

  Installment copyWith({
    String? id,
    String? debtId,
    int? installmentNumber,
    num? amountDue,
    DateTime? dueDate,
    Object? paidDate = _unset,
    String? status,
    Object? paymentId = _unset,
  }) {
    return Installment(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      amountDue: amountDue?.toDouble() ?? this.amountDue,
      dueDate: dueDate ?? this.dueDate,
      paidDate: identical(paidDate, _unset)
          ? this.paidDate
          : paidDate as DateTime?,
      status: status ?? this.status,
      paymentId: identical(paymentId, _unset) ? this.paymentId : paymentId as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'debtId': debtId,
      'installmentNumber': installmentNumber,
      'amountDue': amountDue,
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'status': status,
      'paymentId': paymentId,
    };
  }

  factory Installment.fromMap(Map<String, dynamic> map) {
    final normalized = Map<String, dynamic>.from(map);

    return Installment(
      id: normalized['id'] as String,
      debtId: normalized['debtId'] as String,
      installmentNumber: (normalized['installmentNumber'] as num).toInt(),
      amountDue: _doubleFrom(normalized['amountDue']),
      dueDate: _dateTimeFrom(normalized['dueDate']),
      paidDate: _dateTimeOrNull(normalized['paidDate']),
      status: normalized['status'] as String,
      paymentId: normalized['paymentId'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Installment.fromJson(String source) {
    return Installment.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }
}