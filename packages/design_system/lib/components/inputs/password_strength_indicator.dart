import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../../tokens/app_radii.dart';
import '../../tokens/app_spacing.dart';
import '../../tokens/app_typography.dart';

/// The three strength tiers an [AppPasswordStrengthIndicator] visualizes,
/// per docs/08_COMPONENT_LIBRARY.md §5.
enum AppPasswordStrength { weak, fair, strong }

/// A visual password-strength meter, per docs/08_COMPONENT_LIBRARY.md §5
/// (`PasswordStrengthIndicator`). Purely a presentation heuristic for
/// real-time feedback while typing - it is *not* the pass/fail validation
/// gate for form submission (that's `core`'s `Validators.passwordStrength`,
/// which every submit button's enablement should key off instead - see
/// docs/06_DEVELOPMENT_RULES.md Rule 20).
///
/// ```dart
/// AppPasswordStrengthIndicator(password: passwordController.text);
/// ```
class AppPasswordStrengthIndicator extends StatelessWidget {
  const AppPasswordStrengthIndicator({required this.password, super.key});

  final String password;

  /// Scores [password] into a coarse [AppPasswordStrength] tier for
  /// real-time visual feedback. Exposed as a static method so the scoring
  /// heuristic is independently unit-testable without pumping a widget.
  static AppPasswordStrength strengthOf(String password) {
    if (password.isEmpty) {
      return AppPasswordStrength.weak;
    }

    var score = 0;
    if (password.length >= 8) {
      score++;
    }
    if (password.length >= 12) {
      score++;
    }
    if (RegExp('[A-Z]').hasMatch(password)) {
      score++;
    }
    if (RegExp('[a-z]').hasMatch(password)) {
      score++;
    }
    if (RegExp('[0-9]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      score++;
    }

    if (score <= 2) {
      return AppPasswordStrength.weak;
    }
    if (score <= 4) {
      return AppPasswordStrength.fair;
    }
    return AppPasswordStrength.strong;
  }

  @override
  Widget build(BuildContext context) {
    final strength = strengthOf(password);
    final semantic = context.semanticColors;
    final (color, label) = switch (strength) {
      AppPasswordStrength.weak => (Theme.of(context).colorScheme.error, 'Weak'),
      AppPasswordStrength.fair => (semantic.warning, 'Fair'),
      AppPasswordStrength.strong => (semantic.success, 'Strong'),
    };
    final filledSegments = switch (strength) {
      AppPasswordStrength.weak => 1,
      AppPasswordStrength.fair => 2,
      AppPasswordStrength.strong => 3,
    };

    return Semantics(
      label: 'Password strength: $label',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(3, (index) {
              final isFilled = index < filledSegments;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 2 ? AppSpacing.xs : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isFilled ? color : semantic.disabled,
                    borderRadius: AppRadii.borderRadiusXs,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: AppTypography.labelMedium.copyWith(color: color)),
        ],
      ),
    );
  }
}
