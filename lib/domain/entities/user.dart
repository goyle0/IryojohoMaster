class User {
  final String id;
  final String email;
  final String? name;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.lastLoginAt,
  });

  String get displayName => name ?? email;
}
