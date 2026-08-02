import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../../tokens/app_spacing.dart';

/// A multi-step wizard progress indicator, per
/// docs/08_COMPONENT_LIBRARY.md §12 (`StepperHeader`). Used in Checkout.
///
/// Steps before [currentStep] render as completed (checkmark), the step at
/// [currentStep] is highlighted, and steps after render as pending.
///
/// ```dart
/// AppStepperHeader(steps: const ['Address', 'Shipping', 'Payment', 'Review'], currentStep: 1);
/// ```
class AppStepperHeader extends StatelessWidget {
  const AppStepperHeader({
    required this.steps,
    required this.currentStep,
    super.key,
  }) : assert(currentStep >= 0, 'currentStep must be >= 0'),
       assert(
         steps.length == 0 || currentStep < steps.length,
         'currentStep must be a valid index into steps',
       );

  final List<String> steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                color: i <= currentStep ? colorScheme.primary : semantic.border,
              ),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: i <= currentStep
                    ? colorScheme.primary
                    : semantic.disabled,
                child: i < currentStep
                    ? Icon(Icons.check, size: 16, color: colorScheme.onPrimary)
                    : Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: i == currentStep
                              ? colorScheme.onPrimary
                              : semantic.disabledForeground,
                        ),
                      ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(steps[i], style: textTheme.labelSmall),
            ],
          ),
        ],
      ],
    );
  }
}
