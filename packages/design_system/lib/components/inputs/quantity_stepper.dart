import 'package:flutter/material.dart';

import '../../tokens/app_radii.dart';
import '../../tokens/app_spacing.dart';

/// An increment/decrement quantity control, per
/// docs/08_COMPONENT_LIBRARY.md §5 (`QuantityStepper`). Used in Cart line
/// items and the Admin Stock Adjustment dialog.
///
/// The decrement action is disabled at [min] and the increment action is
/// disabled at [max] (or when [enabled] is `false`), rather than clamping
/// silently, so the user always sees *why* a tap had no effect.
///
/// ```dart
/// AppQuantityStepper(
///   value: item.quantity,
///   min: 1,
///   max: item.availableStock,
///   onChanged: (qty) => bloc.add(CartQuantityChanged(item.id, qty)),
/// );
/// ```
class AppQuantityStepper extends StatelessWidget {
  const AppQuantityStepper({
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 99,
    this.enabled = true,
    super.key,
  }) : assert(min <= max, 'min must be <= max');

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final bool enabled;

  bool get _atMin => value <= min;
  bool get _atMax => value >= max;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline),
        borderRadius: AppRadii.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove,
            tooltip: 'Decrease quantity',
            onPressed: enabled && !_atMin ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          _StepButton(
            icon: Icons.add,
            tooltip: 'Increase quantity',
            onPressed: enabled && !_atMax ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 16),
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(AppSpacing.xs),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}
