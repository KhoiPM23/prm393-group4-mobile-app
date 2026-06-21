import 'package:flutter/material.dart';
import '../../data/repositories/mock_user_repository.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../widgets/vibe_ui_components.dart';

/// Màn hình Đặt lại mật khẩu VibeLocals
/// Route: /reset-password
/// Source: t_l_i_m_t_kh_u_vibelocals/code.html
/// Design: Floating label inputs, password requirements checklist, blur bg elements
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _userRepository = MockUserRepository();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _receivedEmailArgument = false;

  bool get _hasMinLength => _newPasswordController.text.length >= 8;
  bool get _hasLetter => RegExp(r'[a-zA-Z]').hasMatch(_newPasswordController.text);

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_receivedEmailArgument) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty) {
      _emailController.text = args;
    }
    _receivedEmailArgument = true;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _userRepository.resetPassword(
        email: _emailController.text,
        otp: _otpController.text,
        newPassword: _newPasswordController.text,
      );
      if (!mounted) return;
      setState(() => _isSuccess = true);
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
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
          // Atmospheric bg blobs
          Positioned(
            top: -10,
            right: -10,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryFixedDim.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -10,
            left: -20,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryFixedDim.withValues(alpha: 0.1),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top AppBar
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md),
                  color: AppColors.surface.withValues(alpha: 0.7),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        color: AppColors.onSurfaceVariant,
                        style: IconButton.styleFrom(
                          minimumSize: const Size(
                              AppTouchTarget.minSize, AppTouchTarget.minSize),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Đặt lại mật khẩu',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.titleLg.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTouchTarget.minSize),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Đặt lại mật khẩu',
                            style: AppTextStyles.headlineLgMobile.copyWith(
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Vui lòng nhập OTP đã nhận trong email và mật khẩu mới cho tài khoản của bạn.',
                            style: AppTextStyles.bodyLg.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
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
                          const SizedBox(height: AppSpacing.md),
                          VibeInputField(
                            label: 'Mã OTP',
                            hint: 'Nhập mã OTP',
                            controller: _otpController,
                            prefixIcon: Icons.verified_user_outlined,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Vui lòng nhập OTP';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // New password
                          VibeInputField(
                            label: 'Mật khẩu mới',
                            hint: '••••••••',
                            controller: _newPasswordController,
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscureNew,
                            suffix: IconButton(
                              icon: Icon(
                                _obscureNew
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.outline,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscureNew = !_obscureNew),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Vui lòng nhập mật khẩu mới';
                              }
                              if (!MockUserRepository.isValidPassword(v)) {
                                return 'Mật khẩu ít nhất 8 ký tự và có 1 chữ cái';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Confirm password
                          VibeInputField(
                            label: 'Xác nhận mật khẩu mới',
                            hint: '••••••••',
                            controller: _confirmPasswordController,
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscureConfirm,
                            suffix: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.outline,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                            ),
                            validator: (v) {
                              if (v != _newPasswordController.text) {
                                return 'Mật khẩu không khớp';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Password requirements checklist
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.xl),
                            ),
                            child: Column(
                              children: [
                                _Requirement(
                                  label: 'Ít nhất 8 ký tự',
                                  isMet: _hasMinLength,
                                ),
                                const SizedBox(height: 8),
                                _Requirement(
                                  label: 'Có ít nhất 1 chữ cái',
                                  isMet: _hasLetter,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          // Submit
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            child: _isSuccess
                                ? Container(
                                    height: 52,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.tertiaryContainer,
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.xl),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.check,
                                            color: AppColors.onTertiaryContainer),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Thành công',
                                          style: AppTextStyles.labelLg.copyWith(
                                            color:
                                                AppColors.onTertiaryContainer,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : VibePrimaryButton(
                                    label: 'Cập nhật mật khẩu',
                                    onPressed: _handleUpdate,
                                    isLoading: _isLoading,
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

class _Requirement extends StatelessWidget {
  final String label;
  final bool isMet;

  const _Requirement({required this.label, required this.isMet});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            key: ValueKey(isMet),
            size: 18,
            color: isMet ? AppColors.onTertiaryContainer : AppColors.outline,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            color: isMet
                ? AppColors.onTertiaryContainer
                : AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
