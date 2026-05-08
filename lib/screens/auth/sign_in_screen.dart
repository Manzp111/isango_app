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
    final maxWidth = size.width > 520.0 ? 460.0 : size.width;

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
              child: _SignInCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _IsangoWordmark(),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        'Welcome back!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.nearBlackInk,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Sign in to access your personalized campus events feed.',
                        style: AppTextStyles.bodyMuted.copyWith(fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Signing in gives you access to your saved events, RSVPs, and reminders.',
                        style: AppTextStyles.bodyMuted.copyWith(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      if (_submissionError != null) ...[
                        _SubmissionErrorBanner(message: _submissionError!),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      AuthTextField(
                        controller: _emailController,
                        label: 'Email Address',
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
                        hint: 'Enter your password',
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) => _handleSubmit(),
                        validator: AuthValidators.password,
                        trailing: GestureDetector(
                          onTap: _isSubmitting ? null : _handleForgotPassword,
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.commandBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
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
                      const SizedBox(height: AppSpacing.lg),

                      AuthPrimaryButton(
                        label: 'Sign In',
                        isLoading: _isSubmitting,
                        onPressed: _handleSubmit,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: AppTextStyles.bodyMuted.copyWith(
                              color: AppColors.nearBlackInk,
                              fontSize: 15,
                            ),
                          ),
                          GestureDetector(
                            onTap: _isSubmitting ? null : _goToSignUp,
                            child: const Text(
                              'Sign Up',
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

class _SignInCard extends StatelessWidget {
  const _SignInCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppRadii.card + 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _IsangoWordmark extends StatelessWidget {
  const _IsangoWordmark();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Isango',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: AppColors.deepNavy,
        // fontStyle: FontStyle.italic,
        letterSpacing: -0.5,
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
