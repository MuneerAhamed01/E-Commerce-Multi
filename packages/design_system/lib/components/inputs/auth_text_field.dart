import 'package:flutter/material.dart';

import 'app_text_field.dart';

/// An [AppTextField] preset for authentication forms (login/register/
/// profile), per docs/08_COMPONENT_LIBRARY.md §5 (`AuthTextField`).
///
/// Identical to [AppTextField] except it always forwards [autofillHints],
/// so every auth-adjacent form gets consistent platform autofill behavior
/// (e.g. password managers, OS-suggested emails) without each screen
/// remembering to wire it up individually.
///
/// ```dart
/// AppAuthTextField(
///   label: 'Password',
///   controller: passwordController,
///   obscureText: true,
///   autofillHints: const [AutofillHints.password],
///   validator: Validators.passwordStrength,
/// );
/// ```
class AppAuthTextField extends StatelessWidget {
  const AppAuthTextField({
    required this.label,
    this.controller,
    this.hint,
    this.errorText,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.focusNode,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      hint: hint,
      errorText: errorText,
      validator: validator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      focusNode: focusNode,
    );
  }
}
