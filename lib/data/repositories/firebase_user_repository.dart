import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';
import 'mock_user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  FirebaseUserRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    MockUserRepository? mockRepository,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _mockRepository = mockRepository ?? MockUserRepository();

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final MockUserRepository _mockRepository;

  @override
  Future<UserEntity> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return _toUserModel(user);
    }
    return _mockRepository.getCurrentUser();
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    final normalizedEmail = _normalizeEmail(email);

    if (_isMockEmail(normalizedEmail)) {
      return _mockRepository.login(normalizedEmail, password);
    }

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Khong the dang nhap tai khoan Firebase.');
      }
      return _toUserModel(user);
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseAuthError(error));
    }
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);

    if (_isMockEmail(normalizedEmail)) {
      throw const AuthException('Email nay da ton tai trong mock data.');
    }

    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Khong the tao tai khoan Firebase.');
      }
      await user.updateDisplayName(name.trim());
      await user.reload();
      return _toUserModel(_firebaseAuth.currentUser ?? user, fallbackName: name);
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseAuthError(error));
    }
  }

  @override
  Future<String> requestPasswordResetOtp(String email) async {
    final normalizedEmail = _normalizeEmail(email);

    if (_isMockEmail(normalizedEmail)) {
      return _mockRepository.requestPasswordResetOtp(normalizedEmail);
    }

    try {
      final methods = await _firebaseAuth.fetchSignInMethodsForEmail(normalizedEmail);
      if (methods.isEmpty) {
        throw const AuthException('Mail nay chua ton tai.');
      }
      await _firebaseAuth.sendPasswordResetEmail(email: normalizedEmail);
      return '';
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseAuthError(error));
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final normalizedEmail = _normalizeEmail(email);

    if (_isMockEmail(normalizedEmail)) {
      return _mockRepository.resetPassword(
        email: normalizedEmail,
        otp: otp,
        newPassword: newPassword,
      );
    }

    try {
      final resetEmail = await _firebaseAuth.verifyPasswordResetCode(otp.trim());
      if (_normalizeEmail(resetEmail) != normalizedEmail) {
        throw const AuthException('Ma dat lai mat khau khong thuoc email nay.');
      }
      await _firebaseAuth.confirmPasswordReset(
        code: otp.trim(),
        newPassword: newPassword,
      );
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseAuthError(error));
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _mockRepository.logout();
  }

  bool _isMockEmail(String email) => MockUserRepository.hasEmail(email);

  UserModel _toUserModel(
    firebase_auth.User user, {
    String? fallbackName,
  }) {
    final email = user.email ?? '';
    final displayName = user.displayName?.trim();
    final fallbackDisplayName = fallbackName?.trim();

    return UserModel(
      id: user.uid,
      name: displayName?.isNotEmpty == true
          ? displayName!
          : fallbackDisplayName?.isNotEmpty == true
              ? fallbackDisplayName!
              : email,
      email: email,
      avatarUrl: user.photoURL ?? '',
    );
  }

  String _mapFirebaseAuthError(firebase_auth.FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Email khong hop le.';
      case 'user-not-found':
      case 'invalid-credential':
        return 'Email chua duoc dang ky hoac mat khau khong dung.';
      case 'wrong-password':
        return 'Mat khau khong dung.';
      case 'email-already-in-use':
        return 'Email nay da ton tai tren Firebase.';
      case 'weak-password':
        return 'Mat khau qua yeu. Vui long dung mat khau manh hon.';
      case 'user-disabled':
        return 'Tai khoan nay da bi vo hieu hoa.';
      case 'expired-action-code':
        return 'Ma dat lai mat khau da het han.';
      case 'invalid-action-code':
        return 'Ma dat lai mat khau khong hop le.';
      case 'missing-email':
        return 'Vui long nhap email.';
      default:
        return error.message ?? 'Co loi Firebase Auth xay ra.';
    }
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();
}
