import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/mock_data.dart';
import '../models/user_model.dart';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class MockUserRepository implements UserRepository {
  static const String demoOtp = '123456';
  static final List<Map<String, dynamic>> _users =
      MockData.getMockUsers().map((user) => Map<String, dynamic>.from(user)).toList();
  static final Map<String, String> _otpByEmail = {};

  @override
  Future<UserEntity> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return UserModel.fromJson(_users.first);
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final normalizedEmail = _normalizeEmail(email);

    if (!_isValidPassword(password)) {
      throw const AuthException(
        'Mật khẩu phải có ít nhất 8 ký tự và ít nhất 1 chữ cái.',
      );
    }

    final user = _findUserByEmail(normalizedEmail);
    if (user == null) {
      throw const AuthException('Email chưa được đăng ký.');
    }

    if (user['password'] != password) {
      throw const AuthException('Mật khẩu không đúng.');
    }

    return UserModel.fromJson(user);
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final normalizedEmail = _normalizeEmail(email);

    if (name.trim().isEmpty) {
      throw const AuthException('Vui lòng nhập họ tên.');
    }
    if (!_isValidEmail(normalizedEmail)) {
      throw const AuthException('Email không hợp lệ.');
    }
    if (_findUserByEmail(normalizedEmail) != null) {
      throw const AuthException('Email này đã tồn tại trong database.');
    }
    if (!_isValidPassword(password)) {
      throw const AuthException(
        'Mật khẩu phải có ít nhất 8 ký tự và ít nhất 1 chữ cái.',
      );
    }

    final user = {
      'id': 'u${_users.length + 1}',
      'name': name.trim(),
      'email': normalizedEmail,
      'password': password,
      'avatarUrl': '',
    };
    _users.add(user);
    return UserModel.fromJson(user);
  }

  @override
  Future<String> requestPasswordResetOtp(String email) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final normalizedEmail = _normalizeEmail(email);

    if (!_isValidEmail(normalizedEmail)) {
      throw const AuthException('Email không hợp lệ.');
    }
    if (_findUserByEmail(normalizedEmail) == null) {
      throw const AuthException('Mail này chưa tồn tại.');
    }

    _otpByEmail[normalizedEmail] = demoOtp;
    return demoOtp;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final normalizedEmail = _normalizeEmail(email);
    final user = _findUserByEmail(normalizedEmail);

    if (user == null) {
      throw const AuthException('Mail này chưa tồn tại.');
    }
    if (_otpByEmail[normalizedEmail] != otp.trim()) {
      throw const AuthException('Sai OTP.');
    }
    if (!_isValidPassword(newPassword)) {
      throw const AuthException(
        'Mật khẩu phải có ít nhất 8 ký tự và ít nhất 1 chữ cái.',
      );
    }

    user['password'] = newPassword;
    _otpByEmail.remove(normalizedEmail);
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  static bool isValidPassword(String password) => _isValidPassword(password);

  static bool isValidEmail(String email) => _isValidEmail(_normalizeEmail(email));

  static bool hasEmail(String email) =>
      _findUserByEmail(_normalizeEmail(email)) != null;

  static String _normalizeEmail(String email) => email.trim().toLowerCase();

  static Map<String, dynamic>? _findUserByEmail(String email) {
    for (final user in _users) {
      if (_normalizeEmail(user['email'] as String) == email) {
        return user;
      }
    }
    return null;
  }

  static bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }

  static bool _isValidPassword(String password) {
    return password.length >= 8 && RegExp(r'[a-zA-Z]').hasMatch(password);
  }
}
