import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseBudgetModel {
  final String? id;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FirebaseBudgetModel({
    this.id,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  Map<String, dynamic> toFirebaseMap() {
    return {
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  FirebaseBudgetModel copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FirebaseBudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
