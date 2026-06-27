import 'package:flutter/material.dart';
import '../../data/repositories/firebase_user_repository.dart';
import '../../data/repositories/mock_user_repository.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../widgets/vibe_ui_components.dart';

/// Màn hình Quên mật khẩu - Gửi OTP qua email
/// Route: /forgot-password
/// Source: qu_n_m_t_kh_u_vibelocals/code.html
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _userRepository = FirebaseUserRepository();
  bool _isLoading = false;
  bool _isSent = false;
  String? _demoOtp;
  bool _isFirebaseFlow = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final otp = await _userRepository.requestPasswordResetOtp(
        _emailController.text,
      );
      if (!mounted) return;
      setState(() {
        _isSent = true;
        _demoOtp = otp.isEmpty ? null : otp;
        _isFirebaseFlow = otp.isEmpty;
      });
    } on AuthException catch (error) {
      if (!mounted) return;
      _showError(error.message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMd.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Atmospheric background elements
          Positioned(
            top: 0,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryFixedDim.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryFixedDim.withValues(alpha: 0.12),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top AppBar - glassmorphic
                Container(
                  height: 64,
                  color: AppColors.surface.withValues(alpha: 0.7),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back,
                            color: AppColors.primary),
                        iconSize: 24,
                        style: IconButton.styleFrom(
                          minimumSize: const Size(
                              AppTouchTarget.minSize, AppTouchTarget.minSize),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Khôi phục mật khẩu',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.titleLg.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      // Spacer to center title
                      const SizedBox(width: AppTouchTarget.minSize),
                    ],
                  ),
                ),
                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.lg,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.xxl),
                          // Icon badge
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primaryFixed,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.12),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.lock_reset_outlined,
                              size: 42,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Khôi phục mật khẩu',
                            style: AppTextStyles.headlineLgMobile.copyWith(
                              color: AppColors.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Nhập email của bạn để nhận mã xác thực OTP',
                            style: AppTextStyles.bodyLg.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          // Form
                          if (!_isSent) ...[
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  VibeInputField(
                                    label: 'Email',
                                    hint: 'example@vibelocals.com',
                                    controller: _emailController,
                                    prefixIcon: Icons.mail_outline,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Vui lòng nhập email';
                                      }
                                      if (!MockUserRepository.isValidEmail(v)) {
                                        return 'Email không hợp lệ';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Chúng tôi sẽ gửi mã OTP tới hòm thư của bạn.',
                                    style: AppTextStyles.labelMd.copyWith(
                                      color: AppColors.outline,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  VibePrimaryButton(
                                    label: 'Gửi mã OTP',
                                    onPressed: _handleSendOtp,
                                    isLoading: _isLoading,
                                    trailingIcon: Icons.arrow_forward,
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            // Success state
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: AppColors.tertiaryFixed.withValues(alpha: 0.3),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.card),
                                border: Border.all(
                                    color: AppColors.onTertiaryContainer
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    size: 48,
                                    color: AppColors.onTertiaryContainer,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    'Đã gửi thành công!',
                                    style: AppTextStyles.titleLg.copyWith(
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _isFirebaseFlow
                                        ? 'Vui lòng kiểm tra hộp thư ${_emailController.text} và mở link Firebase để đổi mật khẩu.'
                                        : 'Vui lòng kiểm tra hộp thư ${_emailController.text} và lấy mã OTP để đổi mật khẩu.',
                                    style: AppTextStyles.bodyMd.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (_demoOtp != null) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      'OTP mock để test: $_demoOtp',
                                      style: AppTextStyles.labelMd.copyWith(
                                        color: AppColors.outline,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                  const SizedBox(height: AppSpacing.md),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pushNamed(
                                            '/reset-password',
                                            arguments:
                                                _emailController.text.trim()),
                                    child: Text(
                                      'Đặt lại mật khẩu ngay',
                                      style: AppTextStyles.labelLg.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xxl),
                          // Support link
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Bạn cần hỗ trợ? ',
                                  style: AppTextStyles.bodyMd.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Text(
                                      'Liên hệ bộ phận CSKH',
                                      style: AppTextStyles.labelLg.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
