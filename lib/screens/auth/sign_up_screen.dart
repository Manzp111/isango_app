import 'package:flutter/material.dart';
import 'package:isango_app/core/constants/app_routes.dart';
import 'package:isango_app/core/theme/app_colors.dart';
import 'package:isango_app/core/theme/app_radii.dart';
import 'package:isango_app/core/theme/app_spacing.dart';
import 'package:isango_app/core/theme/app_text_styles.dart';
import 'package:isango_app/core/utils/auth_validators.dart';
import 'package:isango_app/widgets/auth/auth_primary_button.dart';
import 'package:isango_app/widgets/auth/auth_text_field.dart';

typedef SignUpRequest = Future<void> Function({
  required String displayName,
  required String email,
  required String password,
});

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, this.onSignUp, this.onSignUpComplete});

  final SignUpRequest? onSignUp;
  final VoidCallback? onSignUpComplete;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;
  String? _submissionError;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();
    setState(() => _submissionError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final hook = widget.onSignUp ?? _defaultSignUpHook;
      await hook(
        displayName: _displayNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;

      if (widget.onSignUpComplete != null) {
        widget.onSignUpComplete!();
      } else {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.verifyEmail,
          arguments: _emailController.text.trim(),
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _submissionError = _messageForError(error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _defaultSignUpHook({
    required String displayName,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
  }

  String _messageForError(Object error) {
    if (error is SignUpException) return error.message;
    return 'We could not create your account. Please try again.';
  }

  void _goToSignIn() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      _goToSignIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = size.width > 520.0 ? 480.0 : size.width;

    return Scaffold(
      backgroundColor: AppColors.mistBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: _SignUpTopBar(
          onBack: _isSubmitting ? null : _handleBack,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.page,
              vertical: AppSpacing.xl,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: Text(
                        'Join your campus community to never miss an event.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.mutedOperationalInk,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    if (_submissionError != null) ...[
                      _SubmissionErrorBanner(message: _submissionError!),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    AuthTextField(
                      controller: _displayNameController,
                      label: 'Full Name',
                      hint: 'John Doe',
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      validator: AuthValidators.displayName,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    AuthTextField(
                      controller: _emailController,
                      label: 'University Email',
                      hint: 'name_studentid@stud.ur.ac.rw',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: AuthValidators.universityEmail,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    AuthTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: AuthValidators.password,
                      suffix: IconButton(
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.mutedOperationalInk,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    AuthTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: '••••••••',
                      icon: Icons.lock_reset_outlined,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleSubmit(),
                      revalidateOn: _passwordController,
                      validator: (value) => AuthValidators.confirmPassword(
                        value,
                        _passwordController.text,
                      ),
                      suffix: IconButton(
                        tooltip: _obscureConfirm
                            ? 'Show password'
                            : 'Hide password',
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.mutedOperationalInk,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirm = !_obscureConfirm,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    AuthPrimaryButton(
                      label: 'Create Account',
                      isLoading: _isSubmitting,
                      onPressed: _handleSubmit,
                      trailingIcon: Icons.arrow_forward,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: Text(
                        'We will send you a verification link to your email after you sign up.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMuted.copyWith(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: AppTextStyles.bodyMuted.copyWith(
                            color: AppColors.nearBlackInk,
                            fontSize: 15,
                          ),
                        ),
                        GestureDetector(
                          onTap: _isSubmitting ? null : _goToSignIn,
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: AppColors.commandBlue,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpException implements Exception {
  const SignUpException(this.message);
  final String message;
  @override
  String toString() => 'SignUpException: $message';
}

class _SignUpTopBar extends StatelessWidget {
  const _SignUpTopBar({required this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: Row(
              children: [
                _CircularIconButton(
                  icon: Icons.arrow_back,
                  onPressed: onBack,
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.logisticsNavy,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircularIconButton extends StatelessWidget {
  const _CircularIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.logisticsNavy,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _SubmissionErrorBanner extends StatelessWidget {
  const _SubmissionErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('signUpErrorBanner'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.criticalRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(color: AppColors.criticalRed.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.criticalRed),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMuted.copyWith(
                color: AppColors.criticalRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
