import '../../domain/entities/user_entity.dart';
import '../datasources/mock_data.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String,
    );
  }

  // Factory method trả về dữ liệu mẫu (Hardcoded in MockData)
  static UserModel mockDetailed() {
    final data = MockData.getMockUsers().first;
    return UserModel.fromJson(data);
  }
}
