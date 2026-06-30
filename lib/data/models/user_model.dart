import '../../domain/entities/user_entity.dart';
import '../datasources/mock_data.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.avatarUrl,
    required super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String,
      role: json['role'] == 'host' ? UserRole.host : UserRole.customer,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'role': role.name,
    };
  }

  // Factory method trả về dữ liệu mẫu (Hardcoded in MockData)
  static UserModel mockDetailed() {
    final data = MockData.getMockUsers().first;
    // Gán mặc định là customer cho dữ liệu cũ
    return UserModel(
      id: data['id'],
      name: data['name'],
      email: data['email'],
      avatarUrl: data['avatarUrl'],
      role: UserRole.customer,
    );
  }
}
