class UserModel {
  final String id;
  final String email;
  final String name;
  final int streak;
  final int points;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.streak,
    required this.points,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    int? streak,
    int? points,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      streak: streak ?? this.streak,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}