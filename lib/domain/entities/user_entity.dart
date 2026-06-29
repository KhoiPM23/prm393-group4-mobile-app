enum UserRole { customer, host }

class UserEntity {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final UserRole role;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.role,
  });
}
