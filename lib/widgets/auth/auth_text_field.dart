import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isango_app/core/theme/app_colors.dart';
import 'package:isango_app/core/theme/app_radii.dart';
import 'package:isango_app/core/theme/app_text_styles.dart';

/// Reusable form text field used across the auth flow.
///
/// Validation is per-field and reactive:
///   * The inner [TextFormField] uses [AutovalidateMode.onUserInteraction] so
///     only fields the user has typed in show errors — submitting the form
///     does not paint untouched fields.
///   * The label colour and suffix error icon mirror the same per-field state.
///   * [revalidateOn] is an optional [Listenable] that lets a field re-run
///     its validator when an external value it depends on changes (e.g. the
///     confirm-password field passing the password controller, so it
///     re-validates the moment the password changes).
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffix,
    this.trailing,
    this.validator,
    this.inputFormatters,
    this.autofillHints,
    this.onFieldSubmitted,
    this.revalidateOn,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffix;
  final Widget? trailing;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;
  final Listenable? revalidateOn;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _userTyped = false;
  String? _liveError;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChange);
    widget.revalidateOn?.addListener(_handleRevalidate);
  }

  @override
  void didUpdateWidget(covariant AuthTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChange);
      widget.controller.addListener(_handleControllerChange);
    }
    if (oldWidget.revalidateOn != widget.revalidateOn) {
      oldWidget.revalidateOn?.removeListener(_handleRevalidate);
      widget.revalidateOn?.addListener(_handleRevalidate);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);
    widget.revalidateOn?.removeListener(_handleRevalidate);
    super.dispose();
  }

  void _handleControllerChange() {
    if (!mounted) return;
    final next = widget.validator?.call(widget.controller.text);
    if (_userTyped && next == _liveError) return;
    setState(() {
      _userTyped = true;
      _liveError = next;
    });
  }

  // Triggered by an external dependency (e.g. password controller) — only
  // updates the visible error if the user has already typed in this field.
  void _handleRevalidate() {
    if (!mounted || !_userTyped) return;
    final next = widget.validator?.call(widget.controller.text);
    if (next != _liveError) {
      setState(() => _liveError = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showError = _userTyped && _liveError != null;
    final labelColor =
        showError ? AppColors.criticalRed : AppColors.nearBlackInk;

    final labelStyle = AppTextStyles.label.copyWith(
      color: labelColor,
      fontWeight: FontWeight.w700,
      fontSize: 14,
    );

    final effectiveSuffix = showError && widget.suffix == null
        ? const Icon(Icons.error, color: AppColors.criticalRed)
        : widget.suffix;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Expanded(child: Text(widget.label, style: labelStyle)),
              ?widget.trailing,
            ],
          ),
        ),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          autofillHints: widget.autofillHints,
          validator: widget.validator,
          onFieldSubmitted: widget.onFieldSubmitted,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.bodyMuted,
            prefixIcon:
                Icon(widget.icon, color: AppColors.mutedOperationalInk),
            suffixIcon: effectiveSuffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.input),
            ),
          ),
        ),
      ],
    );
  }
}
