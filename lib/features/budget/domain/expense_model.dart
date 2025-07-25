import 'package:budget/common/utils/date_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String name;
  final double amount;
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.createdAt,
  });

  ExpenseModel copyWith({
    String? id,
    String? name,
    double? amount,
    DateTime? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toFirebaseMap() {
    return {
      'name': name,
      'amount': amount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ExpenseModel(
      id: documentId,
      name: map['name'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateUtils.parseFirebaseTimestamp(map['createdAt']),
    );
  }
}
