import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';
import 'mock_user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  FirebaseUserRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    MockUserRepository? mockRepository,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _mockRepository = mockRepository ?? MockUserRepository();

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final MockUserRepository _mockRepository;

  @override
  Future<UserEntity> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return _getUserFromFirestore(user.uid);
    }
    return _mockRepository.getCurrentUser();
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    final normalizedEmail = _normalizeEmail(email);

    // Bước 1: Kiểm tra xem có phải tài khoản mẫu (Mock) không?
    // Điều này giúp bạn đăng nhập được ngay bằng lam.host@email.com / lam1234
    if (_isMockEmail(normalizedEmail)) {
      return _mockRepository.login(normalizedEmail, password);
    }

    // Bước 2: Nếu không phải tài khoản mẫu, thử đăng nhập bằng Firebase thật
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Không thể đăng nhập tài khoản Firebase.');
      }
      return await _getUserFromFirestore(user.uid);
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

      // Default role for new users is customer
      final newUser = UserModel(
        id: user.uid,
        name: name.trim(),
        email: normalizedEmail,
        avatarUrl: '',
        role: UserRole.customer,
      );

      await _firestore.collection('users').doc(user.uid).set(newUser.toJson());
      
      await user.updateDisplayName(name.trim());
      await user.reload();
      
      return newUser;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseAuthError(error));
    }
  }

  Future<UserEntity> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }
    
    // Fallback if user exists in Auth but not in Firestore (should not happen normally)
    final user = _firebaseAuth.currentUser;
    if (user != null && user.uid == uid) {
      return UserModel(
        id: user.uid,
        name: user.displayName ?? user.email ?? 'User',
        email: user.email ?? '',
        avatarUrl: user.photoURL ?? '',
        role: UserRole.customer, // Default fallback
      );
    }
    
    throw const AuthException('Không tìm thấy thông tin người dùng.');
  }

  @override
  Future<String> requestPasswordResetOtp(String email) async {
    final normalizedEmail = _normalizeEmail(email);

    if (_isMockEmail(normalizedEmail)) {
      return _mockRepository.requestPasswordResetOtp(normalizedEmail);
    }

    try {
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
