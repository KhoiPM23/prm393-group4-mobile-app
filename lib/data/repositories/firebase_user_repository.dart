import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

const _googleWebClientId =
    '992573755019-f5glbtqm32qumhp882ca8g6cba3ijhd9.apps.googleusercontent.com';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class FirebaseUserRepository implements UserRepository {
  FirebaseUserRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              serverClientId: _googleWebClientId,
            );

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  @override
  Future<UserEntity> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return _getUserFromFirestore(user.uid);
    }
    throw const AuthException('Chua co nguoi dung dang nhap.');
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    final normalizedEmail = _normalizeEmail(email);

    // Đăng nhập bằng Firebase
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Không thể đăng nhập tài khoản Firebase.');
      }

      // Kiểm tra email đã xác thực chưa
      if (!user.emailVerified) {
        // Tùy chọn: Có thể tự động gửi lại mail xác nhận ở đây
        // await user.sendEmailVerification();
        throw const AuthException(
            'Vui lòng xác thực email của bạn trước khi đăng nhập. Hãy kiểm tra hộp thư đến.');
      }

      return await _getUserFromFirestore(user.uid);
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseAuthError(error));
    }
  }

  @override
  Future<UserEntity?> loginWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user == null) {
        throw const AuthException('Khong the dang nhap Google.');
      }
      return await _getUserFromFirestore(user.uid);
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(_mapFirebaseAuthError(error));
    } catch (error) {
      final message = error.toString();
      if (message.contains('ApiException: 10') ||
          message.contains('DEVELOPER_ERROR')) {
        throw const AuthException(
          'Dang nhap Google that bai. Hay tai lai google-services.json moi tu Firebase va cai dat lai app.',
        );
      }
      throw AuthException('Dang nhap Google that bai. Vui long thu lai.');
    }
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);

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


      // Tự động gửi email xác thực ngay sau khi đăng ký
      await user.sendEmailVerification();

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

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: normalizedEmail);
      return '';
    } on firebase_auth.FirebaseAuthException catch (error) {
      // Lưu ý: Bạn PHẢI tắt 'Email enumeration protection' trong Firebase Console
      // thì Firebase mới trả về lỗi 'user-not-found'.
      if (error.code == 'user-not-found' ||
          error.code == 'invalid-recipient-email') {
        throw const AuthException('Email này chưa được đăng ký trong hệ thống.');
      }
      throw AuthException(_mapFirebaseAuthError(error));
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
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
    await _googleSignIn.signOut();
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

  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email.trim());
  }

  static bool isValidPassword(String password) {
    return password.length >= 8 && RegExp(r'[a-zA-Z]').hasMatch(password);
  }
}
