class UserModel {
  final String id;
  final bool isAnonymous;
  final DateTime createdAt;

  UserModel({required this.id, required this.isAnonymous, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();

  UserModel copyWith({String? id, bool? isAnonymous, DateTime? createdAt}) {
    return UserModel(
      id: id ?? this.id,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
