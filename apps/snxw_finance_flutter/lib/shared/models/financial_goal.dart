import 'dart:convert';

class FinancialGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final String priority;
  final String status;

  const FinancialGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.priority,
    required this.status,
  });

  FinancialGoal copyWith({
    String? id,
    String? name,
    num? targetAmount,
    num? currentAmount,
    DateTime? deadline,
    String? priority,
    String? status,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount?.toDouble() ?? this.targetAmount,
      currentAmount: currentAmount?.toDouble() ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      status: status ?? this.status,
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
    };
  }

  factory FinancialGoal.fromMap(Map<String, dynamic> map) {
    return FinancialGoal(
      id: map['id'] as String,
      name: map['name'] as String,
      targetAmount: (map['targetAmount'] as num).toDouble(),
      currentAmount: (map['currentAmount'] as num).toDouble(),
      deadline: DateTime.parse(map['deadline'] as String),
      priority: map['priority'] as String,
      status: map['status'] as String,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory FinancialGoal.fromJson(String source) {
    return FinancialGoal.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }
}