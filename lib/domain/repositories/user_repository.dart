import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity> getCurrentUser();
  Future<UserEntity> login(String email, String password);
  Future<void> logout();
}
