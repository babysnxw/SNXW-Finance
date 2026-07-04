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

class CreditAccount {
  final String id;
  final String issuer;
  final String cardName;
  final double creditLimit;
  final double currentBalance;
  final double minimumPayment;
  final int closingDay;
  final int dueDay;
  final List<String> debtIds;

  const CreditAccount({
    required this.id,
    required this.issuer,
    required this.cardName,
    required this.creditLimit,
    required this.currentBalance,
    required this.minimumPayment,
    required this.closingDay,
    required this.dueDay,
    this.debtIds = const <String>[],
  });

  CreditAccount copyWith({
    String? id,
    String? issuer,
    String? cardName,
    num? creditLimit,
    num? currentBalance,
    num? minimumPayment,
    int? closingDay,
    int? dueDay,
    List<String>? debtIds,
  }) {
    return CreditAccount(
      id: id ?? this.id,
      issuer: issuer ?? this.issuer,
      cardName: cardName ?? this.cardName,
      creditLimit: creditLimit?.toDouble() ?? this.creditLimit,
      currentBalance: currentBalance?.toDouble() ?? this.currentBalance,
      minimumPayment: minimumPayment?.toDouble() ?? this.minimumPayment,
      closingDay: closingDay ?? this.closingDay,
      dueDay: dueDay ?? this.dueDay,
      debtIds: debtIds ?? this.debtIds,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'issuer': issuer,
      'cardName': cardName,
      'creditLimit': creditLimit,
      'currentBalance': currentBalance,
      'minimumPayment': minimumPayment,
      'closingDay': closingDay,
      'dueDay': dueDay,
      'debtIds': debtIds,
    };
  }

  factory CreditAccount.fromMap(Map<String, dynamic> map) {
    final normalized = Map<String, dynamic>.from(map);

    return CreditAccount(
      id: normalized['id'] as String,
      issuer: normalized['issuer'] as String,
      cardName: normalized['cardName'] as String,
      creditLimit: _doubleFrom(normalized['creditLimit']),
      currentBalance: _doubleFrom(normalized['currentBalance']),
      minimumPayment: _doubleFrom(normalized['minimumPayment']),
      closingDay: (normalized['closingDay'] as num).toInt(),
      dueDay: (normalized['dueDay'] as num).toInt(),
      debtIds: _stringListFrom(normalized['debtIds']),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory CreditAccount.fromJson(String source) {
    return CreditAccount.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }
}