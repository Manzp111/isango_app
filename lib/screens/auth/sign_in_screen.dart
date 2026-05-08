import 'package:flutter/material.dart';
import 'package:isango_app/core/constants/app_routes.dart';
import 'package:isango_app/core/theme/app_colors.dart';
import 'package:isango_app/core/theme/app_radii.dart';
import 'package:isango_app/core/theme/app_spacing.dart';
import 'package:isango_app/core/theme/app_text_styles.dart';
import 'package:isango_app/core/utils/auth_validators.dart';
import 'package:isango_app/widgets/auth/auth_primary_button.dart';
import 'package:isango_app/widgets/auth/auth_text_field.dart';

typedef SignInRequest = Future<void> Function({
  required String email,
  required String password,
});

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, this.onSignIn, this.onForgotPassword});

  final SignInRequest? onSignIn;
  final VoidCallback? onForgotPassword;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _submissionError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();
    setState(() => _submissionError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final hook = widget.onSignIn ?? _defaultSignInHook;
      await hook(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (error) {
      if (!mounted) return;
      setState(() => _submissionError = _messageForError(error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _defaultSignInHook({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
  }

  String _messageForError(Object error) {
    if (error is SignInException) return error.message;
    return 'We could not sign you in. Please try again.';
  }

  void _goToSignUp() {
    Navigator.pushReplacementNamed(context, AppRoutes.signUp);
  }

  void _handleForgotPassword() {
    if (widget.onForgotPassword != null) {
      widget.onForgotPassword!();
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Password reset flow coming soon.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = size.width > 520.0 ? 480.0 : size.width;

    return Scaffold(
      backgroundColor: AppColors.mistBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.page,
              vertical: AppSpacing.lg,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _IsangoWordmark(),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Welcome back!',
                      style: AppTextStyles.display,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Sign in to discover and follow campus events across UR.',
                      style: AppTextStyles.bodyMuted,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    if (_submissionError != null) ...[
                      _SubmissionErrorBanner(message: _submissionError!),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    AuthTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'student@ur.ac.rw',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: AuthValidators.email,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    AuthTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _handleSubmit(),
                      validator: AuthValidators.password,
                      suffix: IconButton(
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.mutedOperationalInk,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isSubmitting ? null : _handleForgotPassword,
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    AuthPrimaryButton(
                      label: 'Sign in',
                      isLoading: _isSubmitting,
                      onPressed: _handleSubmit,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: AppTextStyles.bodyMuted,
                        ),
                        TextButton(
                          onPressed: _isSubmitting ? null : _goToSignUp,
                          child: const Text('Sign up'),
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

class SignInException implements Exception {
  const SignInException(this.message);
  final String message;
  @override
  String toString() => 'SignInException: $message';
}

class _IsangoWordmark extends StatelessWidget {
  const _IsangoWordmark();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Container(
        //   width: 64,
        //   height: 64,
        //   decoration: BoxDecoration(
        //     color: AppColors.logisticsNavy,
        //     borderRadius: BorderRadius.circular(AppRadii.card),
        //   ),
        //   alignment: Alignment.center,
        //   child: const Icon(
        //     Icons.event_available,
        //     color: AppColors.cardWhite,
        //     size: 32,
        //   ),
        // ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Isango Login Portal',
          style: AppTextStyles.headline.copyWith(
            color: AppColors.logisticsNavy,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _SubmissionErrorBanner extends StatelessWidget {
  const _SubmissionErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('signInErrorBanner'),
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
