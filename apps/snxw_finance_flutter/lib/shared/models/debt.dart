import 'dart:convert';

const Object _unset = Object();

double _doubleFrom(dynamic value) => (value as num).toDouble();

List<String> _stringListFrom(dynamic value) {
  if (value == null) {
    return const <String>[];
  }

  return (value as List<dynamic>)
      .map((item) => item.toString())
      .toList(growable: false);
}

class Debt {
  final String id;
  final String name;
  final double principal;
  final double outstandingBalance;
  final double interestRate;
  final double minimumPayment;
  final int dueDay;
  final String status;
  final String? creditAccountId;
  final List<String> installmentIds;
  final List<String> paymentIds;

  const Debt({
    required this.id,
    required this.name,
    required this.principal,
    required this.outstandingBalance,
    required this.interestRate,
    required this.minimumPayment,
    required this.dueDay,
    required this.status,
    this.creditAccountId,
    this.installmentIds = const <String>[],
    this.paymentIds = const <String>[],
  });

  Debt copyWith({
    String? id,
    String? name,
    num? principal,
    num? outstandingBalance,
    num? interestRate,
    num? minimumPayment,
    int? dueDay,
    String? status,
    Object? creditAccountId = _unset,
    List<String>? installmentIds,
    List<String>? paymentIds,
  }) {
    return Debt(
      id: id ?? this.id,
      name: name ?? this.name,
      principal: principal?.toDouble() ?? this.principal,
      outstandingBalance: outstandingBalance?.toDouble() ?? this.outstandingBalance,
      interestRate: interestRate?.toDouble() ?? this.interestRate,
      minimumPayment: minimumPayment?.toDouble() ?? this.minimumPayment,
      dueDay: dueDay ?? this.dueDay,
      status: status ?? this.status,
      creditAccountId: identical(creditAccountId, _unset)
          ? this.creditAccountId
          : creditAccountId as String?,
      installmentIds: installmentIds ?? this.installmentIds,
      paymentIds: paymentIds ?? this.paymentIds,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'principal': principal,
      'outstandingBalance': outstandingBalance,
      'interestRate': interestRate,
      'minimumPayment': minimumPayment,
      'dueDay': dueDay,
      'status': status,
      'creditAccountId': creditAccountId,
      'installmentIds': installmentIds,
      'paymentIds': paymentIds,
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    final normalized = Map<String, dynamic>.from(map);

    return Debt(
      id: normalized['id'] as String,
      name: normalized['name'] as String,
      principal: _doubleFrom(normalized['principal']),
      outstandingBalance: _doubleFrom(normalized['outstandingBalance']),
      interestRate: _doubleFrom(normalized['interestRate']),
      minimumPayment: _doubleFrom(normalized['minimumPayment']),
      dueDay: (normalized['dueDay'] as num).toInt(),
      status: normalized['status'] as String,
      creditAccountId: normalized['creditAccountId'] as String?,
      installmentIds: _stringListFrom(normalized['installmentIds']),
      paymentIds: _stringListFrom(normalized['paymentIds']),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Debt.fromJson(String source) {
    return Debt.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }
}