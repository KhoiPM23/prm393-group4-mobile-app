import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class MockUserRepository implements UserRepository {
  @override
  Future<UserEntity> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return UserModel.mockDetailed();
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (email == 'khoi.phan@email.com' && password == 'password') {
      return UserModel.mockDetailed();
    }
    throw Exception('Invalid credentials');
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
