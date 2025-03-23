class User {
  final String id;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
    this.lastLoginAt,
  });
}

