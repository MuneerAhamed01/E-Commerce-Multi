import 'package:flutter/material.dart';

/// Visual treatment of an [AppTextField]. See
/// docs/08_COMPONENT_LIBRARY.md §5.
enum AppTextFieldVariant { outlined, filled }

/// The platform's base text input, per docs/08_COMPONENT_LIBRARY.md §5
/// (`AppTextField`). Every form field in the app builds on this rather than
/// a bare Material `TextFormField` (docs/06_DEVELOPMENT_RULES.md Rule 9).
///
/// ```dart
/// AppTextField(
///   label: 'Email',
///   controller: emailController,
///   keyboardType: TextInputType.emailAddress,
///   validator: Validators.email,
/// );
/// ```
class AppTextField extends StatelessWidget {
  const AppTextField({
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.variant = AppTextFieldVariant.outlined,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.autofillHints,
    this.focusNode,
    super.key,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;

  /// Externally-supplied error text, shown in addition to/instead of
  /// [validator]'s result (useful for server-side validation errors a
  /// `Bloc` surfaces after submission).
  final String? errorText;

  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final AppTextFieldVariant variant;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFilled = variant == AppTextFieldVariant.filled;

    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: obscureText ? 1 : maxLines,
      autofillHints: autofillHints,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: isFilled,
        fillColor: isFilled ? colorScheme.surfaceContainerHighest : null,
      ),
    );
  }
}
