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

class CashAccount {
  final String id;
  final String name;
  final String type;
  final double currentBalance;
  final String currency;
  final List<String> incomeIds;
  final List<String> expenseIds;
  final List<String> paymentIds;

  const CashAccount({
    required this.id,
    required this.name,
    required this.type,
    required this.currentBalance,
    required this.currency,
    this.incomeIds = const <String>[],
    this.expenseIds = const <String>[],
    this.paymentIds = const <String>[],
  });

  CashAccount copyWith({
    String? id,
    String? name,
    String? type,
    num? currentBalance,
    String? currency,
    List<String>? incomeIds,
    List<String>? expenseIds,
    List<String>? paymentIds,
  }) {
    return CashAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      currentBalance: currentBalance?.toDouble() ?? this.currentBalance,
      currency: currency ?? this.currency,
      incomeIds: incomeIds ?? this.incomeIds,
      expenseIds: expenseIds ?? this.expenseIds,
      paymentIds: paymentIds ?? this.paymentIds,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'type': type,
      'currentBalance': currentBalance,
      'currency': currency,
      'incomeIds': incomeIds,
      'expenseIds': expenseIds,
      'paymentIds': paymentIds,
    };
  }

  factory CashAccount.fromMap(Map<String, dynamic> map) {
    final normalized = Map<String, dynamic>.from(map);

    return CashAccount(
      id: normalized['id'] as String,
      name: normalized['name'] as String,
      type: normalized['type'] as String,
      currentBalance: _doubleFrom(normalized['currentBalance']),
      currency: normalized['currency'] as String,
      incomeIds: _stringListFrom(normalized['incomeIds']),
      expenseIds: _stringListFrom(normalized['expenseIds']),
      paymentIds: _stringListFrom(normalized['paymentIds']),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory CashAccount.fromJson(String source) {
    return CashAccount.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }
}