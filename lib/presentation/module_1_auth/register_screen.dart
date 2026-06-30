import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../../data/repositories/firebase_user_repository.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../widgets/vibe_ui_components.dart';

/// Màn hình Đăng ký tài khoản VibeLocals Premium Light
/// Route: /register
/// Design: Form đăng ký với validation real-time, atmospheric gradient bg
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _userRepository = FirebaseUserRepository();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _agreedToTerms = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vui lòng đồng ý với Điều khoản dịch vụ',
            style: AppTextStyles.bodyMd.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl)),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = await _userRepository.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      
      // Update global Auth state
      context.read<AuthBloc>().add(AuthUserChanged(user));

      // Navigate based on role (default is customer for register)
      if (user.role == UserRole.host) {
        Navigator.of(context).pushReplacementNamed('/inbox');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      _showMessage(error.message, isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMd.copyWith(color: Colors.white),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
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
          // Atmospheric blobs
          Positioned(
            top: -80,
            left: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryFixed.withValues(alpha: 0.2),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -40,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryFixedDim.withValues(alpha: 0.12),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        color: AppColors.onSurface,
                        iconSize: 24,
                        style: IconButton.styleFrom(
                          minimumSize: const Size(
                              AppTouchTarget.minSize, AppTouchTarget.minSize),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tạo tài khoản',
                        style: AppTextStyles.titleLg.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Scrollable form
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'Chào mừng bạn!',
                              style:
                                  AppTextStyles.headlineLgMobile.copyWith(
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tạo tài khoản để khám phá những trải nghiệm độc đáo.',
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            // Full Name
                            VibeInputField(
                              label: 'Họ và tên',
                              hint: 'Nguyễn Văn A',
                              controller: _nameController,
                              prefixIcon: Icons.person_outline,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Vui lòng nhập họ tên';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            // Email
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
                                if (!FirebaseUserRepository.isValidEmail(v)) {
                                  return 'Email không hợp lệ';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            // Password
                            VibeInputField(
                              label: 'Mật khẩu',
                              hint: 'Ít nhất 8 ký tự',
                              controller: _passwordController,
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.outline,
                                  size: 20,
                                ),
                                onPressed: () => setState(() =>
                                    _obscurePassword = !_obscurePassword),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Vui lòng nhập mật khẩu';
                                }
                                if (!FirebaseUserRepository.isValidPassword(v)) {
                                  return 'Mật khẩu ít nhất 8 ký tự và có 1 chữ cái';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            // Confirm Password
                            VibeInputField(
                              label: 'Xác nhận mật khẩu',
                              hint: 'Nhập lại mật khẩu',
                              controller: _confirmController,
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
                                if (v != _passwordController.text) {
                                  return 'Mật khẩu không khớp';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            // Password requirements
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.xl),
                              ),
                              child: Column(
                                children: [
                                  _PasswordRequirement(
                                      label: 'Ít nhất 8 ký tự',
                                      isMet: _passwordController.text.length >=
                                          8),
                                  const SizedBox(height: 6),
                                  _PasswordRequirement(
                                      label: 'Có ít nhất 1 chữ cái',
                                      isMet: RegExp(r'[a-zA-Z]').hasMatch(
                                          _passwordController.text)),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            // Terms agreement
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _agreedToTerms,
                                    onChanged: (v) => setState(
                                        () => _agreedToTerms = v ?? false),
                                    activeColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(
                                        () => _agreedToTerms = !_agreedToTerms),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Tôi đồng ý với ',
                                            style: AppTextStyles.bodyMd
                                                .copyWith(
                                              color:
                                                  AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Điều khoản dịch vụ',
                                            style: AppTextStyles.labelLg
                                                .copyWith(
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' và ',
                                            style: AppTextStyles.bodyMd
                                                .copyWith(
                                              color:
                                                  AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Chính sách bảo mật',
                                            style: AppTextStyles.labelLg
                                                .copyWith(
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            VibePrimaryButton(
                              label: 'Tạo tài khoản',
                              onPressed: _handleRegister,
                              isLoading: _isLoading,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            // Login link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Đã có tài khoản? ',
                                  style: AppTextStyles.bodyMd.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      Navigator.of(context).pop(),
                                  child: Text(
                                    'Đăng nhập',
                                    style: AppTextStyles.labelLg.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                          ],
                        ),
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

class _PasswordRequirement extends StatelessWidget {
  final String label;
  final bool isMet;

  const _PasswordRequirement({required this.label, required this.isMet});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isMet ? AppColors.onTertiaryContainer : AppColors.outline,
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
