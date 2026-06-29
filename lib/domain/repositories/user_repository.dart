import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity> getCurrentUser();
  Future<UserEntity> login(String email, String password);
  Future<UserEntity?> loginWithGoogle();
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
  });
  Future<String> requestPasswordResetOtp(String email);
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });
  Future<void> logout();
}
