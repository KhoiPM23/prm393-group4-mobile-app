import 'package:flutter/material.dart';
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
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _isSuccess = false;

  bool get _hasMinLength => _newPasswordController.text.length >= 8;
  bool get _hasAlphanumeric =>
      RegExp(r'[a-zA-Z]').hasMatch(_newPasswordController.text) &&
      RegExp(r'[0-9]').hasMatch(_newPasswordController.text);

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
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
                            'Vui lòng nhập mật khẩu mới cho tài khoản của bạn. Đảm bảo mật khẩu của bạn có độ bảo mật cao.',
                            style: AppTextStyles.bodyLg.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
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
                              if (v.length < 8) {
                                return 'Mật khẩu ít nhất 8 ký tự';
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
                                  label: 'Bao gồm chữ cái và chữ số',
                                  isMet: _hasAlphanumeric,
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
