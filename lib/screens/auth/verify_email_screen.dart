import 'package:flutter/material.dart';
import 'package:isango_app/core/constants/app_routes.dart';
import 'package:isango_app/core/theme/app_colors.dart';
import 'package:isango_app/core/theme/app_radii.dart';
import 'package:isango_app/core/theme/app_spacing.dart';
import 'package:isango_app/core/theme/app_text_styles.dart';
import 'package:isango_app/widgets/auth/auth_primary_button.dart';

typedef ResendVerificationRequest = Future<void> Function();

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, this.onResend, this.email});

  final ResendVerificationRequest? onResend;
  final String? email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isResending = false;

  Future<void> _handleResend() async {
    setState(() => _isResending = true);
    try {
      final hook = widget.onResend ?? _defaultResendHook;
      await hook();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Verification email resent. Check your inbox.'),
          ),
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              "Couldn't resend the email. Please try again in a moment.",
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _defaultResendHook() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = size.width > 680.0 ? 640.0 : size.width;

    return Scaffold(
      backgroundColor: AppColors.mistBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: _VerifyTopBar(
          onBack: _isResending ? null : _handleBack,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StatusPanel(email: widget.email),
                  const SizedBox(height: AppSpacing.lg),
                  const _WhyItMattersPanel(),
                  const SizedBox(height: AppSpacing.xl),
                  AuthPrimaryButton(
                    label: 'Resend Verification Email',
                    isLoading: _isResending,
                    onPressed: _handleResend,
                    trailingIcon: Icons.send_outlined,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    "Can't find the email? Check your spam folder or try resending in 2 minutes.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMuted.copyWith(
                      color: AppColors.mutedOperationalInk,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VerifyTopBar extends StatelessWidget {
  const _VerifyTopBar({required this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        border: const Border(
          bottom: BorderSide(color: AppColors.softBorder),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
                _CircularBackButton(onPressed: onBack),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Verify Email',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.logisticsNavy,
                        letterSpacing: -0.2,
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

class _CircularBackButton extends StatelessWidget {
  const _CircularBackButton({required this.onPressed});

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

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    final description = email == null || email!.isEmpty
        ? "We've sent a verification link to your student email. "
            'Please check your inbox to activate your account.'
        : "We've sent a verification link to $email. "
            'Please check your inbox to activate your account.';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.softBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.paleSignalBlue,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.mark_email_unread,
              size: 32,
              color: AppColors.logisticsNavy,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Verification Pending',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.nearBlackInk,
              letterSpacing: -0.3,
              height: 1.33,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.mutedOperationalInk,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhyItMattersPanel extends StatelessWidget {
  const _WhyItMattersPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.verified,
              color: AppColors.commandBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Why verify your email?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.nearBlackInk,
                    height: 1.33,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Verification helps unlock trusted account capabilities like '
                  'RSVPing to exclusive events and receiving priority notifications. '
                  'Please note that event publishing is reserved for approved roles '
                  'such as staff, club executives, and class representatives.',
                  style: AppTextStyles.bodyMuted.copyWith(
                    fontSize: 14,
                    height: 1.43,
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
